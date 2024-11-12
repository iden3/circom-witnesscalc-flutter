import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'circom_witnesscalc_platform_interface.dart';

/// An implementation of [CircomWitnesscalcPlatform] that uses method channels.
class MethodChannelCircomWitnesscalc extends CircomWitnesscalcPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('circom_witnesscalc');

  @override
  Future<Uint8List?> calculateWitness({
    required String inputs,
    required Uint8List graphData,
  }) async {
    final witness = await methodChannel.invokeMethod<Uint8List>(
      'calculateWitness',
      {
        'inputs': inputs,
        'graphData': graphData,
      },
    );

    return witness;
  }
}
