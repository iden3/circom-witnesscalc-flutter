// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_rapidsnark/flutter_rapidsnark.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:circom_witnesscalc/circom_witnesscalc.dart';

const zkeyPath = 'assets/authV2.zkey';
const inputsPath = 'assets/authV2_inputs.json';
const wcdPath = 'assets/authV2.wcd';
const vkPath = 'assets/authV2_verification_key.json';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final plugin = CircomWitnesscalc();
  final rapidsnark = Rapidsnark();

  Uint8List zkey = Uint8List(0);
  String inputs = '';
  Uint8List witnessGraph = Uint8List(0);
  String verificationKey = '';

  setUpAll(() async {
    zkey = (await rootBundle.load(zkeyPath)).buffer.asUint8List();
    inputs = await rootBundle.loadString(inputsPath);
    witnessGraph = (await rootBundle.load(wcdPath)).buffer.asUint8List();
    verificationKey = await rootBundle.loadString(vkPath);
  });

  testWidgets('Test witness calculation', (tester) async {
    final Uint8List? witness = await plugin.calculateWitness(
      inputs: inputs,
      graphData: witnessGraph,
    );

    expect(witness, isNotNull);
    expect(witness?.isNotEmpty, true);

    final proof = await rapidsnark.groth16Prove(
      zkey: zkey,
      witness: witness!,
    );

    expect(proof.proof, isNotEmpty);
    expect(proof.publicSignals, isNotEmpty);

    final verify = await rapidsnark.groth16Verify(
      proof: proof.proof,
      inputs: proof.publicSignals,
      verificationKey: verificationKey,
    );

    expect(verify, isTrue);
  });
}
