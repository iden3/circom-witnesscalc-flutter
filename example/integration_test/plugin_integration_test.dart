// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_rapidsnark/flutter_rapidsnark.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:circom_witnesscalc/circom_witnesscalc.dart';
import 'package:path_provider/path_provider.dart';

const zkeyAsset = 'assets/authV2.zkey';
const inputsAsset = 'assets/authV2_inputs.json';
const wcdAsset = 'assets/authV2.wcd';
const vkAsset = 'assets/authV2_verification_key.json';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final plugin = CircomWitnesscalc();
  final rapidsnark = Rapidsnark();

  String zkeyPath = "";
  String inputs = '';
  Uint8List witnessGraph = Uint8List(0);
  String verificationKey = '';

  setUpAll(() async {
    final cacheDir = await getTemporaryDirectory();
    zkeyPath = '${cacheDir.path}/authV2.zkey';
    final bytes = await rootBundle.load(zkeyAsset);
    await File(zkeyPath).writeAsBytes(bytes.buffer.asUint8List());

    inputs = await rootBundle.loadString(inputsAsset);
    witnessGraph = (await rootBundle.load(wcdAsset)).buffer.asUint8List();
    verificationKey = await rootBundle.loadString(vkAsset);
  });

  testWidgets('Test witness calculation', (tester) async {
    final Uint8List? witness = await plugin.calculateWitness(
      inputs: inputs,
      graphData: witnessGraph,
    );

    expect(witness, isNotNull);
    expect(witness?.isNotEmpty, true);

    final proof = await rapidsnark.groth16Prove(
      zkeyPath: zkeyPath,
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
