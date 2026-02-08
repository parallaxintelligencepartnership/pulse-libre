/// Intensity slider with badge and +/- buttons.
import 'package:flutter/material.dart';
import '../../constants.dart';

class IntensityCard extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const IntensityCard({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Intensity',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: colorText,
              ),
            ),
            const SizedBox(height: 12),
            // Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: colorPrimary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '$value',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Slider
            Slider(
              value: value.toDouble(),
              min: intensityMin.toDouble(),
              max: intensityMax.toDouble(),
              divisions: intensityMax - intensityMin,
              onChanged: (v) => onChanged(v.round()),
            ),
            // +/- buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$intensityMin', style: const TextStyle(color: colorTextDim, fontSize: 12)),
                Text('$intensityMax', style: const TextStyle(color: colorTextDim, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
