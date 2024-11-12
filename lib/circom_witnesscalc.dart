import 'dart:typed_data';

import 'circom_witnesscalc_platform_interface.dart';

class CircomWitnesscalc {
  Future<Uint8List?> calculateWitness({
    required String inputs,
    required Uint8List graphData,
  }) {
    return CircomWitnesscalcPlatform.instance.calculateWitness(
      inputs: inputs,
      graphData: graphData,
    );
  }
}
