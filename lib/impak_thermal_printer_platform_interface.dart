import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'impak_thermal_printer_method_channel.dart';

abstract class ImpakThermalPrinterPlatform extends PlatformInterface {
  /// Constructs a ImpakThermalPrinterPlatform.
  ImpakThermalPrinterPlatform() : super(token: _token);

  static final Object _token = Object();

  static ImpakThermalPrinterPlatform _instance = MethodChannelImpakThermalPrinter();

  /// The default instance of [ImpakThermalPrinterPlatform] to use.
  ///
  /// Defaults to [MethodChannelImpakThermalPrinter].
  static ImpakThermalPrinterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ImpakThermalPrinterPlatform] when
  /// they register themselves.
  static set instance(ImpakThermalPrinterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
