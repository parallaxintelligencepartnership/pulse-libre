/// Large pill button with Scan / Start / Stop states.
import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../ble/connection.dart' as ble;

class ActionButton extends StatelessWidget {
  final ble.ConnectionState connectionState;
  final bool sessionActive;
  final VoidCallback onPressed;

  const ActionButton({
    super.key,
    required this.connectionState,
    required this.sessionActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final (label, color, enabled) = _buttonState();
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        disabledBackgroundColor: color.withOpacity(0.5),
      ),
      child: Text(label),
    );
  }

  (String, Color, bool) _buttonState() {
    switch (connectionState) {
      case ble.ConnectionState.disconnected:
        return ('Scan for Device', colorPrimary, true);
      case ble.ConnectionState.scanning:
      case ble.ConnectionState.connecting:
      case ble.ConnectionState.reconnecting:
        return ('Scanning...', colorWarning, false);
      case ble.ConnectionState.connected:
        if (sessionActive) {
          return ('Stop Session', colorDanger, true);
        }
        return ('Start Session', colorPrimary, true);
      case ble.ConnectionState.sessionActive:
        return ('Stop Session', colorDanger, true);
    }
  }
}
