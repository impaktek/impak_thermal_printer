import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:impak_thermal_printer/BluetoothDevice.dart';

class ImpakThermalPrinter {
  static const MethodChannel _channel = MethodChannel('impak_thermal_printer');
  static PaperSize _paperSize = PaperSize.mm58;

  /// Gets a list of paired Bluetooth devices
  ///
  /// Returns a List of Maps containing device names and addresses
  /// Each Map has two keys: 'name' and 'address'
  static Future<List<BluetoothDevice>> get pairedDevices async {
    try {
      final List result = await _channel.invokeMethod('GET_PAIRED_DEVICES');
      List<BluetoothDevice> devices = [];
      for (String device in result) {
        final item = device.split("#");
        devices.add(BluetoothDevice(name: item.first, address: item.last));
      }
      return devices;
    } on PlatformException catch (e, s) {
      debugPrint("$e\n$s");
      return [];
    }
  }

  /// Set the paper size of the printer
  /// ///[size] is the paper size of the printer
  static setPaperSize(PaperSize size) {
    _paperSize = size;
  }

  /// Connects to a Bluetooth thermal printer
  ///
  /// [address] is the Bluetooth address of the printer
  /// Returns true if connection is successful, throws an exception otherwise
  static Future<bool> connectBluetooth(String address) async {
    try {
      final bool result = await _channel.invokeMethod('CONNECT_BLUETOOTH', {
        'address': address,
      });
      return result;
    } on PlatformException catch (e) {
      debugPrint('Failed to connect to Bluetooth printer: ${e.message}');
      return false;
    }
  }

  static Future<bool> get isConnected async {
    try {
      final bool result = await _channel.invokeMethod('CONNECTION_STATUS');
      return result;
    } on PlatformException catch (e) {
      debugPrint("Connection Check error: '${e.message}'.");
      return false;
    }
  }

  static Future<bool> print(
      Future<List<int>> Function(Generator, List<int>) builder,
      [String printerSize = "58 mm"]) async {
    try {
      final profile = await CapabilityProfile.load();
      final generator = Generator(_paperSize, profile);
      List<int> bytes = [];
      bytes += generator.reset();
      final result = await builder(generator, bytes);
      debugPrint('$bytes\n$result');
      return await _channel.invokeMethod('PRINT', {"bytes": result});
    } on PlatformException catch (e) {
      debugPrint("Failed to write bytes: '${e.message}'.");
      return false;
    }
  }

  /// Disconnects from the currently connected printer
  ///
  /// Returns true if disconnection is successful, throws an exception otherwise
  static Future<bool> disconnect() async {
    try {
      final bool result = await _channel.invokeMethod('DISCONNECT_BLUETOOTH');
      return result;
    } on PlatformException catch (e) {
      throw Exception('Failed to disconnect printer: ${e.message}');
    }
  }

  /// Gets the platform version
  static Future<String> getPlatformVersion() async {
    try {
      final String version =
          await _channel.invokeMethod('GET_PLATFORM_VERSION');
      return version;
    } on PlatformException catch (e) {
      throw Exception('Failed to get platform version: ${e.message}');
    }
  }
}
