/// BLE command encoding and notification response parsing.
///
/// All commands are plain ASCII terminated with newline.
/// Responses come as byte notifications on the TX characteristic.
import 'dart:convert';
import '../constants.dart';

enum ResponseType { battery, charging, strengthAck, startAck, stopAck, unknown }

class ParsedResponse {
  final ResponseType type;
  final dynamic value;
  final List<int> raw;

  const ParsedResponse({
    required this.type,
    this.value,
    this.raw = const [],
  });
}

// ── Command Encoding ─────────────────────────────────────────────────

List<int> encodeStart() => ascii.encode(cmdStart);
List<int> encodeStop() => ascii.encode(cmdStop);

List<int> encodeStrength(int level) {
  assert(level >= intensityMin && level <= intensityMax);
  return ascii.encode('$level\n');
}

List<int> encodeBatteryQuery() => ascii.encode(cmdBattery);
List<int> encodeChargingQuery() => ascii.encode(cmdCharging);

// ── Response Parsing ─────────────────────────────────────────────────

ParsedResponse parseNotification(List<int> data) {
  final text = ascii.decode(data, allowInvalid: true).trim();

  if (text.isEmpty) {
    return ParsedResponse(type: ResponseType.unknown, raw: data);
  }

  // Battery voltage: "Batt:3.72" or raw float like "3.72"
  var voltageText = text;
  if (text.startsWith('Batt:')) {
    voltageText = text.substring(5);
  }
  if (voltageText.contains('.')) {
    final voltage = double.tryParse(voltageText);
    if (voltage != null && voltage >= 0.0 && voltage <= 5.0) {
      return ParsedResponse(type: ResponseType.battery, value: voltage, raw: data);
    }
  }

  // Charging status: "0"
  if (text == '0') {
    return ParsedResponse(type: ResponseType.charging, value: 0, raw: data);
  }

  // Strength ack: single digit 1-9
  if (text.length == 1 && text.codeUnitAt(0) >= 0x31 && text.codeUnitAt(0) <= 0x39) {
    return ParsedResponse(
      type: ResponseType.strengthAck,
      value: int.parse(text),
      raw: data,
    );
  }

  // Start ack
  if (text == 'D') {
    return ParsedResponse(type: ResponseType.startAck, raw: data);
  }

  // Stop ack
  if (text == '-') {
    return ParsedResponse(type: ResponseType.stopAck, raw: data);
  }

  return ParsedResponse(type: ResponseType.unknown, value: text, raw: data);
}
