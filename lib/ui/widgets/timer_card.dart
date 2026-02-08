/// Timer display with MM:SS, progress bar, and +/- duration controls.
import 'package:flutter/material.dart';
import '../../constants.dart';

class TimerCard extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;
  final int durationMinutes;
  final bool controlsEnabled;
  final ValueChanged<int> onDurationChanged;

  const TimerCard({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.durationMinutes,
    required this.controlsEnabled,
    required this.onDurationChanged,
  });

  @override
  Widget build(BuildContext context) {
    final displaySeconds = totalSeconds > 0 ? remainingSeconds : durationMinutes * 60;
    final mm = (displaySeconds ~/ 60).toString().padLeft(2, '0');
    final ss = (displaySeconds % 60).toString().padLeft(2, '0');
    final progress = totalSeconds > 0
        ? 1.0 - (remainingSeconds / totalSeconds)
        : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // MM:SS display
            Text(
              '$mm:$ss',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                color: colorText,
              ),
            ),
            const SizedBox(height: 12),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 16),
            // Duration controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StepperButton(
                  icon: Icons.remove,
                  enabled: controlsEnabled && durationMinutes > durationMinMinutes,
                  onTap: () => onDurationChanged(durationMinutes - 1),
                ),
                const SizedBox(width: 16),
                Text(
                  '$durationMinutes min',
                  style: const TextStyle(color: colorTextDim, fontSize: 14),
                ),
                const SizedBox(width: 16),
                _StepperButton(
                  icon: Icons.add,
                  enabled: controlsEnabled && durationMinutes < durationMaxMinutes,
                  onTap: () => onDurationChanged(durationMinutes + 1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _StepperButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colorSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: colorBorder),
      ),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            color: enabled ? colorText : colorTextDim,
            size: 20,
          ),
        ),
      ),
    );
  }
}
