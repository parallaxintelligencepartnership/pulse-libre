/// BLE connection state machine using flutter_blue_plus.
///
/// States: DISCONNECTED → SCANNING → CONNECTING → CONNECTED → SESSION_ACTIVE
/// Reconnection uses exponential backoff.
import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' hide FlutterBluePlus;
import 'package:flutter_blue_plus_windows/flutter_blue_plus_windows.dart';
import '../constants.dart';
import 'protocol.dart';

enum ConnectionState {
  disconnected,
  scanning,
  connecting,
  connected,
  sessionActive,
  reconnecting,
}

class BleConnection extends ChangeNotifier {
  ConnectionState _state = ConnectionState.disconnected;
  BluetoothDevice? _device;
  BluetoothCharacteristic? _rxChar;
  BluetoothCharacteristic? _txChar;
  StreamSubscription? _notifySub;
  StreamSubscription? _connectionSub;
  int _reconnectAttempts = 0;
  bool _userDisconnect = false;
  bool _reconnecting = false;
  ResponseType? _pendingResponse;

  // ── Callbacks (set by whoever wires the app) ─────────────────────
  void Function(double voltage)? onBatteryUpdated;
  void Function(bool charging)? onChargingUpdated;
  void Function(int level)? onStrengthAck;
  void Function(String name)? onDeviceFound;
  void Function(String msg)? onError;
  void Function()? onUnexpectedDisconnect;
  void Function()? onReconnectFailed;
  void Function(int attempt, int maxAttempts)? onReconnectProgress;

  // ── Properties ───────────────────────────────────────────────────
  ConnectionState get state => _state;

  bool get isConnected =>
      _state == ConnectionState.connected ||
      _state == ConnectionState.sessionActive;

  String get deviceName => _device?.platformName ?? '';

  // ── Public API ───────────────────────────────────────────────────

  Future<bool> scanAndConnect() async {
    _setState(ConnectionState.scanning);
    try {
      // Start scanning
      await FlutterBluePlus.startScan(
        timeout: scanTimeout,
        withNames: [deviceNamePrefix],
      );

      BluetoothDevice? found;
      // Listen for scan results
      await for (final results in FlutterBluePlus.scanResults) {
        for (final r in results) {
          if (r.device.platformName.startsWith(deviceNamePrefix)) {
            found = r.device;
            break;
          }
        }
        if (found != null) break;
      }

      await FlutterBluePlus.stopScan();

      if (found == null) {
        _setState(ConnectionState.disconnected);
        onError?.call('No device found');
        return false;
      }

      _device = found;
      final ok = await _connect(found);
      if (ok) {
        onDeviceFound?.call(found.platformName);
      }
      return ok;
    } catch (e) {
      _setState(ConnectionState.disconnected);
      onError?.call(e.toString());
      return false;
    }
  }

  Future<void> disconnect() async {
    _userDisconnect = true;
    _reconnecting = false;
    _notifySub?.cancel();
    _connectionSub?.cancel();
    try {
      await _device?.disconnect();
    } catch (_) {}
    _device = null;
    _rxChar = null;
    _txChar = null;
    _setState(ConnectionState.disconnected);
    _reconnectAttempts = 0;
    _userDisconnect = false;
  }

  Future<void> sendStart() async {
    await _write(encodeStart());
    _setState(ConnectionState.sessionActive);
  }

  Future<void> sendStop() async {
    await _write(encodeStop());
    if (_state == ConnectionState.sessionActive) {
      _setState(ConnectionState.connected);
    }
  }

  Future<void> sendStrength(int level) async {
    _pendingResponse = ResponseType.strengthAck;
    await _write(encodeStrength(level));
  }

  Future<void> queryBattery() async {
    _pendingResponse = ResponseType.battery;
    await _write(encodeBatteryQuery());
  }

  Future<void> queryCharging() async {
    _pendingResponse = ResponseType.charging;
    await _write(encodeChargingQuery());
  }

  Future<bool> autoReconnect() async {
    _reconnecting = true;
    _reconnectAttempts = 0;
    _setState(ConnectionState.reconnecting);

    while (_reconnecting && _reconnectAttempts < maxReconnectAttempts) {
      final attempt = _reconnectAttempts + 1;
      final delay = Duration(
        milliseconds: min(
          reconnectBaseDelay.inMilliseconds * pow(2, _reconnectAttempts).toInt(),
          reconnectMaxDelay.inMilliseconds,
        ),
      );

      debugPrint('Reconnect attempt $attempt/$maxReconnectAttempts, '
          'waiting ${delay.inMilliseconds}ms');
      onReconnectProgress?.call(attempt, maxReconnectAttempts);
      await Future.delayed(delay);
      _reconnectAttempts++;

      if (_device != null) {
        final ok = await _connectQuiet(_device!);
        if (ok) {
          _reconnecting = false;
          _reconnectAttempts = 0;
          return true;
        }
      }
    }

    _reconnecting = false;
    _reconnectAttempts = 0;
    _setState(ConnectionState.disconnected);
    onReconnectFailed?.call();
    return false;
  }

  // ── Private ──────────────────────────────────────────────────────

  Future<bool> _connect(BluetoothDevice device) async {
    _setState(ConnectionState.connecting);
    try {
      await device.connect(autoConnect: false);
      await _setupCharacteristics(device);
      _listenForDisconnect(device);
      _setState(ConnectionState.connected);
      debugPrint('Connected to ${device.platformName}');
      return true;
    } catch (e) {
      debugPrint('Connection failed: $e');
      _setState(ConnectionState.disconnected);
      onError?.call('Connection failed: $e');
      return false;
    }
  }

  Future<bool> _connectQuiet(BluetoothDevice device) async {
    try {
      await device.connect(autoConnect: false);
      await _setupCharacteristics(device);
      _listenForDisconnect(device);
      _setState(ConnectionState.connected);
      debugPrint('Reconnected to ${device.platformName}');
      return true;
    } catch (e) {
      debugPrint('Reconnect attempt failed: $e');
      return false;
    }
  }

  Future<void> _setupCharacteristics(BluetoothDevice device) async {
    final services = await device.discoverServices();
    for (final service in services) {
      if (service.uuid.toString().toLowerCase() == serviceUuid) {
        for (final char in service.characteristics) {
          final uuid = char.uuid.toString().toLowerCase();
          if (uuid == rxCharUuid) _rxChar = char;
          if (uuid == txCharUuid) _txChar = char;
        }
      }
    }

    if (_txChar == null || _rxChar == null) {
      throw Exception('UART service characteristics not found');
    }

    // Subscribe to notifications
    await _txChar!.setNotifyValue(true);
    _notifySub?.cancel();
    _notifySub = _txChar!.onValueReceived.listen(_onNotification);
  }

  void _listenForDisconnect(BluetoothDevice device) {
    _connectionSub?.cancel();
    _connectionSub = device.connectionState.listen((state) {
      if (state == BluetoothConnectionState.disconnected) {
        if (_userDisconnect || _reconnecting) return;
        debugPrint('Unexpected device disconnection');
        _setState(ConnectionState.disconnected);
        onUnexpectedDisconnect?.call();
      }
    });
  }

  Future<void> _write(List<int> data) async {
    if (_rxChar == null || !isConnected) {
      onError?.call('Not connected');
      return;
    }
    try {
      await _rxChar!.write(data, withoutResponse: false);
    } catch (e) {
      debugPrint('Write failed: $e');
      onError?.call('Write failed: $e');
    }
  }

  void _onNotification(List<int> data) {
    final parsed = parseNotification(data);

    // Disambiguate charging "1" vs strength ack "1"
    if (_pendingResponse == ResponseType.charging &&
        parsed.type == ResponseType.strengthAck &&
        parsed.value == 1) {
      onChargingUpdated?.call(true);
      _pendingResponse = null;
      return;
    }

    switch (parsed.type) {
      case ResponseType.battery:
        onBatteryUpdated?.call(parsed.value as double);
        break;
      case ResponseType.charging:
        onChargingUpdated?.call(parsed.value != 0);
        break;
      case ResponseType.strengthAck:
        onStrengthAck?.call(parsed.value as int);
        break;
      case ResponseType.startAck:
      case ResponseType.stopAck:
        break;
      case ResponseType.unknown:
        debugPrint('Unknown notification: ${parsed.raw}');
        break;
    }
    _pendingResponse = null;
  }

  void _setState(ConnectionState newState) {
    if (newState != _state) {
      debugPrint('BLE State: ${_state.name} → ${newState.name}');
      _state = newState;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _notifySub?.cancel();
    _connectionSub?.cancel();
    super.dispose();
  }
}
