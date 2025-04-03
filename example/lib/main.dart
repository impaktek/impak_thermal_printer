import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:impak_thermal_printer/BluetoothDevice.dart';
import 'package:impak_thermal_printer/impak_printer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<BluetoothDevice> pairedDevices = [];
  BluetoothDevice? selectedDeviceAddress;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    fetchPairedDevices();
  }

  Future<void> fetchPairedDevices() async {
    try {
      List<BluetoothDevice> devices = await ImpakThermalPrinter.pairedDevices;
      setState(() {
        pairedDevices = devices;
      });
      debugPrint('Successfully fetched ${devices.length} paired devices');
    } catch (e, s) {
      debugPrint('Error fetching devices: $e->$s');
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      bool connected =
          await ImpakThermalPrinter.connectBluetooth(device.address);
      setState(() {
        selectedDeviceAddress = device;
        isConnected = connected;
      });
      if (connected) {
        debugPrint(
            'Successfully connected to printer at address: ${device.address}');
      }
    } catch (e) {
      debugPrint('Error connecting to printer: $e');
    }
  }

  Future<void> printTest() async {
    if (!isConnected) {
      debugPrint('Cannot print: No printer connected');
      return;
    }

    try {
      bool result = await ImpakThermalPrinter.print((generator, bytes) async {
        final ByteData data = await rootBundle.load('assets/etranzact.png');
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
          "Government of Cross River",
          styles: const PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size2,
            width: PosTextSize.size1,
            fontType: PosFontType.fontB,
          ),
        );
        bytes += generator.text("Internal Revenue Service",
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
              text: "Joseph Ofem Eteng Onen",
              width: 9,
              styles: const PosStyles(align: PosAlign.right))
        ]);
        bytes += generator.row([
          PosColumn(
              text: "Name",
              width: 2,
              styles: const PosStyles(align: PosAlign.left)),
          PosColumn(width: 1),
          PosColumn(
              text: "Joseph Ofem",
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

  Future<void> disconnect() async {
    try {
      bool success = await ImpakThermalPrinter.disconnect();
      setState(() {
        selectedDeviceAddress = null;
        isConnected = false;
      });
      if (success) {
        debugPrint('Successfully disconnected from printer');
      }
    } catch (e) {
      debugPrint('Error disconnecting: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Thermal Printer Example'),
          actions: [
            if (isConnected)
              IconButton(
                icon: const Icon(Icons.print),
                onPressed: printTest,
                tooltip: 'Print Test',
              ),
            if (isConnected)
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: disconnect,
                tooltip: 'Disconnect',
              ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: fetchPairedDevices,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Devices'),
                  ),
                  if (isConnected)
                    Text(
                      'Connected to: ${pairedDevices.firstWhere((device) => device == selectedDeviceAddress).name}',
                      style: const TextStyle(color: Colors.green),
                    ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: pairedDevices.length,
                itemBuilder: (context, index) {
                  final device = pairedDevices[index];
                  final isSelected = device == selectedDeviceAddress;
                  return ListTile(
                    title: Text(device.name),
                    subtitle: Text(device.address),
                    trailing: ElevatedButton(
                      onPressed:
                          isSelected ? null : () => connectToDevice(device),
                      child: Text(isSelected ? 'Connected' : 'Connect'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
