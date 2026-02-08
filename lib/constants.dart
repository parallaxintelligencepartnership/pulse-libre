/// BLE UUIDs, voltage constants, colors, and application defaults.
import 'package:flutter/material.dart';

// ── BLE Nordic UART Service ──────────────────────────────────────────
const serviceUuid = '6e400001-b5a3-f393-e0a9-e50e24dcca9e';
const rxCharUuid = '6e400002-b5a3-f393-e0a9-e50e24dcca9e'; // Write TO device
const txCharUuid = '6e400003-b5a3-f393-e0a9-e50e24dcca9e'; // Read FROM device

// ── BLE Commands ─────────────────────────────────────────────────────
const cmdStart = 'D\n';
const cmdStop = '-\n';
const cmdBattery = 'Q\n';
const cmdCharging = 'u\n';

// ── Battery Voltage Mapping ──────────────────────────────────────────
const batteryMinVoltage = 2.5;
const batteryMaxVoltage = 3.95;

// ── Timing ───────────────────────────────────────────────────────────
const keepaliveInterval = Duration(seconds: 10);
const statusPollInterval = Duration(seconds: 30);
const scanTimeout = Duration(seconds: 10);
const reconnectBaseDelay = Duration(seconds: 1);
const reconnectMaxDelay = Duration(seconds: 30);
const maxReconnectAttempts = 5;

// ── Intensity ────────────────────────────────────────────────────────
const intensityMin = 1;
const intensityMax = 9;
const intensityDefault = 5;

// ── Duration ─────────────────────────────────────────────────────────
const durationMinMinutes = 1;
const durationMaxMinutes = 60;
const durationDefaultMinutes = 10;

// ── UI Colors (Catppuccin-Mocha inspired) ────────────────────────────
const colorPrimary = Color(0xFF6C63FF);
const colorPrimaryHover = Color(0xFF5A52E0);
const colorSuccess = Color(0xFF4CAF50);
const colorWarning = Color(0xFFFF9800);
const colorDanger = Color(0xFFF44336);
const colorSurface = Color(0xFF1E1E2E);
const colorBackground = Color(0xFF11111B);
const colorText = Color(0xFFCDD6F4);
const colorTextDim = Color(0xFF6C7086);
const colorBorder = Color(0xFF313244);

// ── Device Name ──────────────────────────────────────────────────────
const deviceNamePrefix = 'Pulsetto';

// ── Default Presets ──────────────────────────────────────────────────
const defaultPresets = [
  {'name': 'Quick Calm', 'intensity': 5, 'duration_minutes': 4},
  {'name': 'Deep Session', 'intensity': 7, 'duration_minutes': 20},
  {'name': 'Gentle', 'intensity': 3, 'duration_minutes': 10},
];
