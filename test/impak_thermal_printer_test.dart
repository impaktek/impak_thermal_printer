import 'package:flutter_test/flutter_test.dart';
import 'package:impak_thermal_printer/impak_thermal_printer.dart';
import 'package:impak_thermal_printer/impak_thermal_printer_method_channel.dart';
import 'package:impak_thermal_printer/impak_thermal_printer_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockImpakThermalPrinterPlatform
    with MockPlatformInterfaceMixin
    implements ImpakThermalPrinterPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final ImpakThermalPrinterPlatform initialPlatform =
      ImpakThermalPrinterPlatform.instance;

  test('$MethodChannelImpakThermalPrinter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelImpakThermalPrinter>());
  });

  test('getPlatformVersion', () async {
    ImpakThermalPrinter impakThermalPrinterPlugin = ImpakThermalPrinter();
    MockImpakThermalPrinterPlatform fakePlatform =
        MockImpakThermalPrinterPlatform();
    ImpakThermalPrinterPlatform.instance = fakePlatform;

    expect(await ImpakThermalPrinter.getPlatformVersion(), '42');
  });
}
