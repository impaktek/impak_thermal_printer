# Changelog

All notable changes to the Impak Thermal Printer Plugin will be documented in this file.

## [0.0.1] - 2025-04-03

### Added
- Initial release of the Impak Thermal Printer Plugin
- Bluetooth thermal printer support for Android devices
- Core printing functionality:
  - Text printing with formatting options
  - Image printing support
  - QR code generation and printing
  - Barcode printing
  - Custom paper size configuration
- Bluetooth device management:
  - List paired Bluetooth devices
  - Connect to specific printers
  - Check connection status
  - Disconnect from printers
- Comprehensive error handling and logging
- Dynamic permission handling for Bluetooth operations
- Support for Android 12+ and older versions

### Technical Details
- Built with Flutter and Kotlin
- Uses `flutter_esc_pos_utils` for printer commands
- Implements proper coroutine-based async operations
- Follows Flutter plugin best practices
- Includes detailed documentation and examples

---
This changelog follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) format.
