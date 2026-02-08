/// Preset dropdown with save/delete actions.
import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../core/presets.dart';

class PresetSelector extends StatelessWidget {
  final List<Preset> presets;
  final int currentIntensity;
  final int currentDuration;
  final void Function(Preset preset) onSelected;
  final void Function(String name, int intensity, int duration) onSave;
  final void Function(String name) onDelete;

  const PresetSelector({
    super.key,
    required this.presets,
    required this.currentIntensity,
    required this.currentDuration,
    required this.onSelected,
    required this.onSave,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Presets',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colorText,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: colorPrimary, size: 20),
                  tooltip: 'Save current as preset',
                  onPressed: () => _showSaveDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: presets.map((preset) {
                final isActive = preset.intensity == currentIntensity &&
                    preset.durationMinutes == currentDuration;
                return GestureDetector(
                  onLongPress: () => _showDeleteDialog(context, preset),
                  child: ActionChip(
                    label: Text(preset.name),
                    backgroundColor: isActive ? colorPrimary : colorSurface,
                    labelStyle: TextStyle(
                      color: isActive ? Colors.white : colorText,
                      fontSize: 13,
                    ),
                    side: BorderSide(
                      color: isActive ? colorPrimary : colorBorder,
                    ),
                    onPressed: () => onSelected(preset),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showSaveDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorSurface,
        title: const Text('Save Preset'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Preset name',
            hintStyle: TextStyle(color: colorTextDim),
          ),
          style: const TextStyle(color: colorText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                onSave(name, currentIntensity, currentDuration);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Preset preset) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorSurface,
        title: const Text('Delete Preset'),
        content: Text('Delete "${preset.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onDelete(preset.name);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: colorDanger)),
          ),
        ],
      ),
    );
  }
}
