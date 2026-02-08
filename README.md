<p align="center">
  <h1 align="center">Pulse Libre</h1>
  <p align="center">
    <strong>Open-source cross-platform controller for Pulsetto vagal nerve stimulator</strong><br>
    Control your Pulsetto device via Bluetooth - no account, no internet, no cloud required.
  </p>
  <p align="center">
    <a href="https://github.com/parallaxintelligencepartnership/pulse-libre/releases"><img src="https://img.shields.io/github/v/release/parallaxintelligencepartnership/pulse-libre?style=flat-square" alt="Release"></a>
    <a href="https://github.com/parallaxintelligencepartnership/pulse-libre/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-GLWTS-orange?style=flat-square" alt="License"></a>
    <img src="https://img.shields.io/badge/flutter-3.6%2B-blue?style=flat-square&logo=flutter" alt="Flutter 3.6+">
    <img src="https://img.shields.io/badge/platforms-Android%20%7C%20iOS%20%7C%20Windows-green?style=flat-square" alt="Platforms">
  </p>
</p>

---

Pulse Libre is a cross-platform Flutter app that controls the [Pulsetto](https://pulsetto.tech/) vagal nerve stimulator over Bluetooth Low Energy. No account required. No internet required. Just you and your device.

Based on the BLE protocol reverse engineering by [Juraj Bednar](https://github.com/jooray) ([original Python app](https://github.com/jooray/pulse-libre-desktop)), rebuilt as a cross-platform Flutter app by [Parallax Intelligence Partnership, LLC](https://parallaxintelligence.ai).

[parallaxintelligence.ai](https://parallaxintelligence.ai) | [parallaxintelligence.online](https://parallaxintelligence.online) | [GitHub](https://github.com/parallaxintelligencepartnership)

## Why?

The Pulsetto device is a vagal nerve stimulator that requires a mobile app with account creation and internet access to function. This is unnecessary - the device communicates over BLE with simple commands. Pulse Libre removes the cloud dependency entirely.

As the original author put it:

> *Why does an electric nerve stimulator need an account and access to the Internet?*

## Features

- **No Account Required** - Direct BLE communication, no cloud, no login
- **Auto-Discovery** - Scans and connects to Pulsetto devices automatically
- **Intensity Control** - Set strength levels from 1 to 9
- **Session Timer** - Configurable timer with progress indicator
- **Presets** - Quick-select presets for common session types (Stress, Sleep, Pain, Burnout)
- **Session History** - Track your past sessions with local SQLite storage
- **Battery Monitor** - Real-time battery level and charging status
- **Auto-Reconnect** - Reconnects automatically if the device disconnects mid-session
- **Cross-Platform** - Android, iOS, and Windows from a single Flutter codebase

## About the Pulsetto Device

The device's original app has multiple modes (Stress, Pain, Burnout, etc.), but they are all identical - just with different timer recommendations. The only thing that actually changes is the intensity level (1-9) and session duration. Pulse Libre gives you direct control over both, plus saves your session history locally.

Get a [Pulsetto device](https://pulsetto.tech/).

## Getting Started

### Option 1: Download (easiest)

Download the latest release for your platform from the [Releases page](https://github.com/parallaxintelligencepartnership/pulse-libre/releases/latest).

### Option 2: Build from source

**Prerequisites:** [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.6+

```bash
git clone https://github.com/parallaxintelligencepartnership/pulse-libre.git
cd pulse-libre
flutter pub get
flutter run
```

## Usage

1. Turn on your Pulsetto device
2. Launch Pulse Libre - it will scan for your device automatically
3. If not found, tap **Scan**
4. Once connected, select a preset or adjust intensity manually
5. Tap **Start** to begin a session
6. Tap **Stop** to end early, or wait for the timer to finish

## Platforms

| Platform | Status |
|----------|--------|
| Android | Supported |
| iOS | Supported |
| Windows | Supported |
| macOS | Planned |
| Linux | Planned |

## Architecture

```
lib/
  ble/
    connection.dart    # BLE scanning, connection, reconnection
    protocol.dart      # Pulsetto command protocol
  core/
    battery.dart       # Battery voltage calculation
    presets.dart        # Session preset definitions
    session.dart        # Session state management
  data/
    database.dart      # SQLite session history
  ui/
    home_screen.dart   # Main screen layout
    theme.dart         # Dark theme definition
    widgets/           # Reusable UI components
  constants.dart       # BLE UUIDs, colors, defaults
  main.dart            # App entry point
```

**Key packages**: flutter_blue_plus (BLE), provider (state management), sqflite (local storage), permission_handler (Bluetooth permissions)

## Attribution

Pulse Libre is based on the BLE protocol reverse engineering by **[Juraj Bednar](https://github.com/jooray)**:

- **[pulse-libre-desktop](https://github.com/jooray/pulse-libre-desktop)** - Original Python/Kivy desktop application
- **[PulseLibre](https://github.com/jooray/PulseLibre)** - Original mobile app and BLE protocol documentation

The BLE protocol was reverse-engineered by Juraj Bednar. Pulsetto is a trademark of its respective owner. This project is not affiliated with or endorsed by Pulsetto.

## Contributing

Contributions are welcome! Please open an issue first to discuss what you'd like to change.

## License

[GLWTS (Good Luck With That Shit)](LICENSE) - inherited from the original project.
