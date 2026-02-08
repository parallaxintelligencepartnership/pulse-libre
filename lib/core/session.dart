/// Session timer, keepalive scheduling, and lifecycle management.
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../constants.dart';

class SessionManager extends ChangeNotifier {
  Timer? _tickTimer;
  Timer? _keepaliveTimer;
  Timer? _statusPollTimer;

  int _remainingSeconds = 0;
  int _totalSeconds = 0;
  int _intensity = intensityDefault;
  bool _active = false;
  int? _sessionId;

  // ── Callbacks ────────────────────────────────────────────────────
  void Function(int remaining, int total)? onTick;
  void Function(int? sessionId, bool completed)? onSessionFinished;
  void Function()? onKeepaliveDue;
  void Function()? onStatusPollDue;

  // ── Properties ───────────────────────────────────────────────────
  bool get isActive => _active;
  int get intensity => _intensity;
  int get remainingSeconds => _remainingSeconds;
  int get totalSeconds => _totalSeconds;
  double get progress =>
      _totalSeconds > 0 ? 1.0 - (_remainingSeconds / _totalSeconds) : 0.0;

  // ── Public API ───────────────────────────────────────────────────

  void start(int durationMinutes, int intensity) {
    _totalSeconds = durationMinutes * 60;
    _remainingSeconds = _totalSeconds;
    _intensity = intensity;
    _active = true;

    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());

    _keepaliveTimer?.cancel();
    _keepaliveTimer = Timer.periodic(keepaliveInterval, (_) {
      onKeepaliveDue?.call();
    });

    notifyListeners();
  }

  void stop({required bool completed, int? sessionId}) {
    _active = false;
    _tickTimer?.cancel();
    _keepaliveTimer?.cancel();
    _sessionId = sessionId;
    onSessionFinished?.call(sessionId, completed);
    notifyListeners();
  }

  void setIntensity(int level) {
    _intensity = level;
  }

  void startStatusPolling() {
    _statusPollTimer?.cancel();
    _statusPollTimer = Timer.periodic(statusPollInterval, (_) {
      onStatusPollDue?.call();
    });
    // Also poll immediately
    onStatusPollDue?.call();
  }

  void stopStatusPolling() {
    _statusPollTimer?.cancel();
  }

  void reset() {
    _remainingSeconds = 0;
    _totalSeconds = 0;
    notifyListeners();
  }

  // ── Private ──────────────────────────────────────────────────────

  void _onTick() {
    if (_remainingSeconds > 0) {
      _remainingSeconds--;
      onTick?.call(_remainingSeconds, _totalSeconds);
      notifyListeners();

      if (_remainingSeconds <= 0) {
        stop(completed: true);
      }
    }
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _keepaliveTimer?.cancel();
    _statusPollTimer?.cancel();
    super.dispose();
  }
}
