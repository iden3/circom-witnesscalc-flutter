import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:circom_witnesscalc/circom_witnesscalc.dart';
import 'package:circom_witnesscalc/circom_witnesscalc_platform_interface.dart';
import 'package:circom_witnesscalc/circom_witnesscalc_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockCircomWitnesscalcPlatform
    with MockPlatformInterfaceMixin
    implements CircomWitnesscalcPlatform {
  @override
  Future<Uint8List?> calculateWitness({
    required String inputs,
    required Uint8List graphData,
  }) {
    return Future.value(Uint8List(0));
  }
}

void main() {
  final CircomWitnesscalcPlatform initialPlatform =
      CircomWitnesscalcPlatform.instance;

  test('$MethodChannelCircomWitnesscalc is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelCircomWitnesscalc>());
  });

  test('calculateWitness', () async {
    CircomWitnesscalc circomWitnesscalcPlugin = CircomWitnesscalc();
    MockCircomWitnesscalcPlatform fakePlatform =
        MockCircomWitnesscalcPlatform();
    CircomWitnesscalcPlatform.instance = fakePlatform;

    expect(
      await circomWitnesscalcPlugin.calculateWitness(
        inputs: "",
        graphData: Uint8List(0),
      ),
      Uint8List(0),
    );
  });
}
