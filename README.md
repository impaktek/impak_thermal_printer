# Impak Thermal Printer Plugin for Flutter

A Flutter plugin for printing via Bluetooth thermal printers on Android. This plugin provides a simple and efficient way to connect and print to thermal printers using Bluetooth connectivity.

## Features

- 🔌 Connect to Bluetooth thermal printers
- 📝 Print text and raw bytes
- 🔍 Get list of paired Bluetooth devices
- 🔄 Check connection status
- 🔒 Proper permission handling for Android
- 🛠️ Support for both Android 12+ and older versions

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  impak_thermal_printer: ^0.0.1
```

## Usage

### 1. Import the package

```dart
import 'package:impak_thermal_printer/impak_thermal_printer.dart';
```

### 2. Get Paired Bluetooth Devices

```dart
try {
  List<BluetoothDevice> devices = await ImpakThermalPrinter.pairedDevices;
  for (var device in devices) {
    print('Device Name: ${device.name}');
    print('Device Address: ${device.ddress}');
  }
} catch (e) {
  print('Error getting paired devices: $e');
}
```

### 3. Connect to a Printer

```dart
try {
  //BluetoothDevice device = BluetoothDevice(name: 'Printer Name', address: '00:11:22:33:44:55');
  bool connected = await ImpakThermalPrinter.connectBluetooth(device.address);
  if (connected) {
    print('Successfully connected to printer');
  }
} catch (e) {
  print('Error connecting to printer: $e');
}
```

### 4. Print data

```dart
Future<void> printTest() async {
  if (!isConnected) {
    debugPrint('Cannot print: No printer connected');
    return;
  }

  try {
    bool result = await ImpakThermalPrinter.print((generator, bytes) async {
      final ByteData data = await rootBundle.load('assets/image.png');
      final Uint8List bytesImg = data.buffer.asUint8List();
      img.Image? image = img.decodeImage(bytesImg);

      if (image != null) {
        final resizedImage = img.copyResize(image,
            width: min(100, image.width),
            height: min(100, image.height),
            interpolation: img.Interpolation.nearest);
        final bytesImg = Uint8List.fromList(img.encodeJpg(resizedImage));
        image = img.decodeImage(bytesImg) ?? image;
        debugPrint(image.width.toString());
        bytes += generator.image(image);
      }

      bytes += generator.text(
        "HEADING",
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size1,
          fontType: PosFontType.fontB,
        ),
      );
      bytes += generator.text("Subheading",
          styles: const PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
            fontType: PosFontType.fontA,
          ),
          linesAfter: 1);
      bytes += generator.row([
        PosColumn(
            text: "Name",
            width: 2,
            styles: const PosStyles(align: PosAlign.left)),
        PosColumn(width: 1, styles: const PosStyles(align: PosAlign.center)),
        PosColumn(
            text: "Impaktek Solutions",
            width: 9,
            styles: const PosStyles(align: PosAlign.right))
      ]);
      bytes += generator.row([
        PosColumn(
            text: "Email",
            width: 3,
            styles: const PosStyles(align: PosAlign.left)),
        PosColumn(
            text: "impaktek@gmail.com",
            width: 9,
            styles: const PosStyles(align: PosAlign.right))
      ]);
      bytes += generator.qrcode("www.example.com");
      final List<int> barData = [0, 2, 1, 2, 5, 6, 0, 8, 2, 0, 5];
      bytes += generator.barcode(Barcode.upcA(barData));
      bytes += generator.feed(3);
      return bytes;
    });
    if (result) {
      debugPrint('Successfully printed test message $result');
    }
  } catch (e) {
    debugPrint('Error printing: $e');
  }
}
```

### 5. Check Connection Status

```dart
try {
  bool isConnected = await ImpakThermalPrinter.connectionStatus();
  if (isConnected) {
    print('Printer is connected');
  } else {
    print('Printer is not connected');
  }
} catch (e) {
  print('Error checking connection status: $e');
}
```

### 6. Disconnect from Printer

```dart
try {
  bool success = await ImpakThermalPrinter.disconnect();
  if (success) {
    print('Successfully disconnected from printer');
  }
} catch (e) {
  print('Error disconnecting from printer: $e');
}
```

## Android Permissions

The plugin requires the following permissions in your Android app:

```xml
<!-- For Android 12+ -->
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />

<!-- For older Android versions -->
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
```

## Error Handling

The plugin throws exceptions with descriptive messages for various error conditions:

- `PERMISSION_DENIED`: When Bluetooth permissions are not granted
- `BLUETOOTH_NOT_AVAILABLE`: When Bluetooth is not available on the device
- `NOT_CONNECTED`: When trying to print without an active connection
- `CONNECTION_ERROR`: When there's an error during connection
- `PRINT_ERROR`: When there's an error during printing

## Example

Check out the [example](https://github.com/impaktek/impak_thermal_printer) directory for a complete example of how to use this plugin.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

# impak_thermal_printer
