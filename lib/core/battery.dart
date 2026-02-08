/// Battery voltage to percentage conversion.
import '../constants.dart';

int voltageToPercent(double voltage) {
  if (voltage <= batteryMinVoltage) return 0;
  if (voltage >= batteryMaxVoltage) return 100;
  return ((voltage - batteryMinVoltage) /
          (batteryMaxVoltage - batteryMinVoltage) *
          100)
      .round();
}

String percentToLabel(int percent) {
  if (percent >= 75) return 'Good';
  if (percent >= 40) return 'OK';
  if (percent >= 15) return 'Low';
  return 'Critical';
}
