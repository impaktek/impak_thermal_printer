import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'impak_thermal_printer_platform_interface.dart';

/// An implementation of [ImpakThermalPrinterPlatform] that uses method channels.
class MethodChannelImpakThermalPrinter extends ImpakThermalPrinterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('impak_thermal_printer');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
