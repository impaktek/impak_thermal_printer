import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impak_thermal_printer/impak_thermal_printer_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelImpakThermalPrinter platform = MethodChannelImpakThermalPrinter();
  const MethodChannel channel = MethodChannel('impak_thermal_printer');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
