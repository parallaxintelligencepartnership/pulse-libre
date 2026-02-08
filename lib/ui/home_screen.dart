/// Main screen composing all widgets and wiring BLE + session logic.
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ble/connection.dart' as ble;
import '../constants.dart';
import '../core/battery.dart';
import '../core/presets.dart';
import '../core/session.dart';
import '../data/database.dart';
import 'widgets/action_button.dart';
import 'widgets/intensity_card.dart';
import 'widgets/preset_selector.dart';
import 'widgets/session_history.dart';
import 'widgets/status_bar.dart';
import 'widgets/timer_card.dart';
import 'widgets/toast.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _ble = ble.BleConnection();
  final _session = SessionManager();
  final _presetMgr = PresetManager();
  final _db = SessionDatabase();
  final _toast = ToastManager();

  int _intensity = intensityDefault;
  int _durationMinutes = durationDefaultMinutes;
  int _batteryPercent = -1;
  String _batteryLabel = '';
  bool _isCharging = false;
  List<SessionRecord> _sessions = [];
  int _reconnectAttempt = 0;
  int _reconnectMax = 0;
  DateTime? _sessionStartTime;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _presetMgr.load().then((_) => setState(() {}));
    _refreshHistory();
    _wireCallbacks();
  }

  void _wireCallbacks() {
    // BLE callbacks
    _ble.onDeviceFound = (name) {
      _toast.success('Connected to $name');
      _session.startStatusPolling();
    };
    _ble.onError = (msg) {
      _toast.error(msg);
    };
    _ble.onBatteryUpdated = (voltage) {
      setState(() {
        _batteryPercent = voltageToPercent(voltage);
        _batteryLabel = percentToLabel(_batteryPercent);
      });
    };
    _ble.onChargingUpdated = (charging) {
      setState(() => _isCharging = charging);
    };
    _ble.onUnexpectedDisconnect = () {
      _toast.warning('Connection lost - reconnecting...');
      if (_session.isActive) {
        _session.stopStatusPolling();
      }
      _ble.autoReconnect().then((ok) {
        if (ok) {
          _toast.success('Reconnected!');
          if (_session.isActive) {
            _ble.sendStart();
            _ble.sendStrength(_session.intensity);
            _session.startStatusPolling();
          }
        }
        setState(() {
          _reconnectAttempt = 0;
          _reconnectMax = 0;
        });
      });
    };
    _ble.onReconnectFailed = () {
      _toast.error('Device not found - reconnection failed');
      if (_session.isActive) {
        _stopSession(completed: false);
      }
    };
    _ble.onReconnectProgress = (attempt, max) {
      setState(() {
        _reconnectAttempt = attempt;
        _reconnectMax = max;
      });
    };

    // BLE state changes trigger rebuild
    _ble.addListener(() => setState(() {}));

    // Session callbacks
    _session.onTick = (remaining, total) => setState(() {});
    _session.onSessionFinished = (sessionId, completed) {
      _onSessionFinished(completed);
    };
    _session.onKeepaliveDue = () {
      if (_ble.isConnected) _ble.sendStrength(_session.intensity);
    };
    _session.onStatusPollDue = () {
      if (_ble.isConnected) {
        _ble.queryBattery();
        _ble.queryCharging();
      }
    };
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _intensity = prefs.getInt('last_intensity') ?? intensityDefault;
      _durationMinutes = prefs.getInt('last_duration_minutes') ?? durationDefaultMinutes;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_intensity', _intensity);
    await prefs.setInt('last_duration_minutes', _durationMinutes);
  }

  Future<void> _refreshHistory() async {
    final sessions = await _db.recent();
    setState(() => _sessions = sessions);
  }

  // ── Actions ──────────────────────────────────────────────────────

  void _onActionPressed() {
    if (_ble.state == ble.ConnectionState.disconnected) {
      _toast.info('Scanning for device...');
      _ble.scanAndConnect();
    } else if (_session.isActive) {
      _stopSession(completed: false);
    } else if (_ble.isConnected) {
      _startSession();
    }
  }

  void _startSession() {
    _session.start(_durationMinutes, _intensity);
    _sessionStartTime = DateTime.now();
    _ble.sendStart();
    _ble.sendStrength(_intensity);
    _saveSettings();
    _toast.info('Session started - ${_durationMinutes}min at level $_intensity');
  }

  void _stopSession({required bool completed}) {
    final duration = _sessionStartTime != null
        ? DateTime.now().difference(_sessionStartTime!).inSeconds
        : 0;
    _session.stop(completed: completed);
    _ble.sendStop();
    if (!completed) _toast.warning('Session stopped');
    // Save to DB
    _db.insert(SessionRecord(
      startTime: _sessionStartTime ?? DateTime.now(),
      endTime: DateTime.now(),
      durationSeconds: duration,
      targetDurationSeconds: _durationMinutes * 60,
      intensity: _intensity,
      completed: completed,
    ));
    _sessionStartTime = null;
    _refreshHistory();
  }

  void _onSessionFinished(bool completed) {
    if (completed) {
      final duration = _sessionStartTime != null
          ? DateTime.now().difference(_sessionStartTime!).inSeconds
          : _durationMinutes * 60;
      _toast.success('Session completed!');
      _db.insert(SessionRecord(
        startTime: _sessionStartTime ?? DateTime.now(),
        endTime: DateTime.now(),
        durationSeconds: duration,
        targetDurationSeconds: _durationMinutes * 60,
        intensity: _intensity,
        completed: true,
      ));
      _sessionStartTime = null;
      if (_ble.isConnected) _ble.sendStop();
      _refreshHistory();
    }
    setState(() {});
  }

  void _onIntensityChanged(int value) {
    setState(() => _intensity = value);
    _session.setIntensity(value);
    if (_session.isActive && _ble.isConnected) {
      _ble.sendStrength(value);
    }
  }

  void _onDurationChanged(int value) {
    setState(() => _durationMinutes = value.clamp(durationMinMinutes, durationMaxMinutes));
  }

  void _onPresetSelected(Preset preset) {
    setState(() {
      _intensity = preset.intensity;
      _durationMinutes = preset.durationMinutes;
    });
    _toast.info('Preset: ${preset.name}');
  }

  void _onPresetSave(String name, int intensity, int duration) {
    _presetMgr.add(Preset(
      name: name,
      intensity: intensity,
      durationMinutes: duration,
    ));
    setState(() {});
    _toast.success('Preset "$name" saved');
  }

  void _onPresetDelete(String name) {
    _presetMgr.remove(name);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main scrollable content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  StatusBar(
                    connectionState: _ble.state,
                    batteryPercent: _batteryPercent,
                    batteryLabel: _batteryLabel,
                    isCharging: _isCharging,
                    deviceName: _ble.deviceName,
                    reconnectAttempt: _reconnectAttempt,
                    reconnectMax: _reconnectMax,
                  ),
                  TimerCard(
                    remainingSeconds: _session.remainingSeconds,
                    totalSeconds: _session.totalSeconds,
                    durationMinutes: _durationMinutes,
                    controlsEnabled: !_session.isActive,
                    onDurationChanged: _onDurationChanged,
                  ),
                  IntensityCard(
                    value: _intensity,
                    onChanged: _onIntensityChanged,
                  ),
                  PresetSelector(
                    presets: _presetMgr.presets,
                    currentIntensity: _intensity,
                    currentDuration: _durationMinutes,
                    onSelected: _onPresetSelected,
                    onSave: _onPresetSave,
                    onDelete: _onPresetDelete,
                  ),
                  const SizedBox(height: 16),
                  ActionButton(
                    connectionState: _ble.state,
                    sessionActive: _session.isActive,
                    onPressed: _onActionPressed,
                  ),
                  const SizedBox(height: 16),
                  SessionHistory(sessions: _sessions),
                ],
              ),
            ),
          ),
          // Toast overlay
          ToastOverlay(manager: _toast),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _session.stopStatusPolling();
    _ble.disconnect();
    _ble.dispose();
    _session.dispose();
    _db.close();
    super.dispose();
  }
}
