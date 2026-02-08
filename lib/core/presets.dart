/// Named preset management with persistence.
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

class Preset {
  final String name;
  final int intensity;
  final int durationMinutes;

  const Preset({
    required this.name,
    required this.intensity,
    required this.durationMinutes,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'intensity': intensity,
        'duration_minutes': durationMinutes,
      };

  factory Preset.fromJson(Map<String, dynamic> json) => Preset(
        name: json['name'] as String,
        intensity: json['intensity'] as int,
        durationMinutes: json['duration_minutes'] as int,
      );
}

class PresetManager {
  static const _key = 'presets';
  List<Preset> _presets = [];

  List<Preset> get presets => List.unmodifiable(_presets);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      _presets = list.map((e) => Preset.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      // Load defaults
      _presets = defaultPresets
          .map((e) => Preset.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      await _save();
    }
  }

  Future<void> add(Preset preset) async {
    _presets.add(preset);
    await _save();
  }

  Future<void> remove(String name) async {
    _presets.removeWhere((p) => p.name == name);
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_presets.map((p) => p.toJson()).toList());
    await prefs.setString(_key, json);
  }
}
