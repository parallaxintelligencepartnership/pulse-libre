/// Toast notification overlay.
import 'dart:async';
import 'package:flutter/material.dart';
import '../../constants.dart';

enum ToastLevel { info, success, warning, error }

class ToastEntry {
  final String message;
  final ToastLevel level;
  final DateTime created;

  ToastEntry(this.message, this.level) : created = DateTime.now();
}

class ToastManager extends ChangeNotifier {
  final List<ToastEntry> _toasts = [];

  List<ToastEntry> get toasts => List.unmodifiable(_toasts);

  void info(String message) => _show(message, ToastLevel.info);
  void success(String message) => _show(message, ToastLevel.success);
  void warning(String message) => _show(message, ToastLevel.warning);
  void error(String message) => _show(message, ToastLevel.error);

  void _show(String message, ToastLevel level) {
    final entry = ToastEntry(message, level);
    _toasts.add(entry);
    notifyListeners();

    // Auto-dismiss after 4 seconds
    Timer(const Duration(seconds: 4), () {
      _toasts.remove(entry);
      notifyListeners();
    });
  }

  void dismiss(ToastEntry entry) {
    _toasts.remove(entry);
    notifyListeners();
  }
}

class ToastOverlay extends StatelessWidget {
  final ToastManager manager;

  const ToastOverlay({super.key, required this.manager});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: manager,
      builder: (context, _) {
        return Positioned(
          top: 8,
          left: 16,
          right: 16,
          child: Column(
            children: manager.toasts.map((entry) {
              return _ToastWidget(
                entry: entry,
                onDismiss: () => manager.dismiss(entry),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _ToastWidget extends StatelessWidget {
  final ToastEntry entry;
  final VoidCallback onDismiss;

  const _ToastWidget({required this.entry, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final color = _levelColor(entry.level);
    final icon = _levelIcon(entry.level);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: colorSurface,
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Color accent bar
              Container(
                width: 4,
                height: 44,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Icon
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 8),
              // Message
              Expanded(
                child: Text(
                  entry.message,
                  style: const TextStyle(color: colorText, fontSize: 13),
                ),
              ),
              // Dismiss
              IconButton(
                icon: const Icon(Icons.close, color: colorTextDim, size: 16),
                onPressed: onDismiss,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _levelColor(ToastLevel level) {
    switch (level) {
      case ToastLevel.info: return colorPrimary;
      case ToastLevel.success: return colorSuccess;
      case ToastLevel.warning: return colorWarning;
      case ToastLevel.error: return colorDanger;
    }
  }

  IconData _levelIcon(ToastLevel level) {
    switch (level) {
      case ToastLevel.info: return Icons.info_outline;
      case ToastLevel.success: return Icons.check;
      case ToastLevel.warning: return Icons.warning_amber;
      case ToastLevel.error: return Icons.error_outline;
    }
  }
}
