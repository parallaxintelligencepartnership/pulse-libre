/// Connection status dot + battery + charging indicator.
import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../ble/connection.dart' as ble;

class StatusBar extends StatelessWidget {
  final ble.ConnectionState connectionState;
  final int batteryPercent;
  final String batteryLabel;
  final bool isCharging;
  final String deviceName;
  final int reconnectAttempt;
  final int reconnectMax;

  const StatusBar({
    super.key,
    required this.connectionState,
    this.batteryPercent = -1,
    this.batteryLabel = '',
    this.isCharging = false,
    this.deviceName = '',
    this.reconnectAttempt = 0,
    this.reconnectMax = 0,
  });

  @override
  Widget build(BuildContext context) {
    final (dotColor, label) = _stateInfo();
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Status dot
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            // Connection label
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: connectionState == ble.ConnectionState.connected ||
                          connectionState == ble.ConnectionState.sessionActive
                      ? colorText
                      : colorTextDim,
                  fontSize: 14,
                ),
              ),
            ),
            // Battery
            if (batteryPercent >= 0) ...[
              Text(
                '$batteryPercent% ($batteryLabel)',
                style: const TextStyle(color: colorText, fontSize: 13),
              ),
              if (isCharging) ...[
                const SizedBox(width: 6),
                const Icon(Icons.bolt, color: colorWarning, size: 16),
              ],
            ],
          ],
        ),
      ),
    );
  }

  (Color, String) _stateInfo() {
    switch (connectionState) {
      case ble.ConnectionState.disconnected:
        return (colorDanger, 'Disconnected');
      case ble.ConnectionState.scanning:
        return (colorWarning, 'Scanning...');
      case ble.ConnectionState.connecting:
        return (colorWarning, 'Connecting...');
      case ble.ConnectionState.connected:
      case ble.ConnectionState.sessionActive:
        return (colorSuccess, deviceName.isNotEmpty ? deviceName : 'Connected');
      case ble.ConnectionState.reconnecting:
        if (reconnectMax > 0) {
          return (colorWarning, 'Reconnecting... ($reconnectAttempt/$reconnectMax)');
        }
        return (colorWarning, 'Reconnecting...');
    }
  }
}
