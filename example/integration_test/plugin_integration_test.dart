// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:circom_witnesscalc/circom_witnesscalc.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final CircomWitnesscalc plugin = CircomWitnesscalc();

  // TODO Test this
  testWidgets('authV2 test', (WidgetTester tester) async {
    final Uint8List? witness = await plugin.calculateWitness(
      inputs: "",
      graphData: Uint8List(0),
    );
    // The version string depends on the host platform running the test, so
    // just assert that some non-empty string is returned.
    expect(witness?.isNotEmpty, true);
  });
}
