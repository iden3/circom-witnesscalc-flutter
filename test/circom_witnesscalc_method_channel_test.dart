import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:circom_witnesscalc/circom_witnesscalc_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelCircomWitnesscalc platform = MethodChannelCircomWitnesscalc();
  const MethodChannel channel = MethodChannel('circom_witnesscalc');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return Uint8List(0);
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('calculateWitness', () async {
    expect(
      await platform.calculateWitness(inputs: "", graphData: Uint8List(0)),
      Uint8List(0),
    );
  });
}
