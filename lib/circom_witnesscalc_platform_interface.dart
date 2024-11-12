import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'circom_witnesscalc_method_channel.dart';

abstract class CircomWitnesscalcPlatform extends PlatformInterface {
  /// Constructs a CircomWitnesscalcPlatform.
  CircomWitnesscalcPlatform() : super(token: _token);

  static final Object _token = Object();

  static CircomWitnesscalcPlatform _instance = MethodChannelCircomWitnesscalc();

  /// The default instance of [CircomWitnesscalcPlatform] to use.
  ///
  /// Defaults to [MethodChannelCircomWitnesscalc].
  static CircomWitnesscalcPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CircomWitnesscalcPlatform] when
  /// they register themselves.
  static set instance(CircomWitnesscalcPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<Uint8List?> calculateWitness({
    required String inputs,
    required Uint8List graphData,
  }) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
