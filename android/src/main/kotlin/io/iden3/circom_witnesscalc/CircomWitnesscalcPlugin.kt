package io.iden3.circom_witnesscalc

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.iden3.circomwitnesscalc.*

/** CircomWitnesscalcPlugin */
class CircomWitnesscalcPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "circom_witnesscalc")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "calculateWitness") {
      handleCalculateWitness(call, result)
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private fun handleCalculateWitness(call: MethodCall, result: Result) {
    val arguments: Map<String, Any> = call.arguments<Map<String, Any>>()!!

    val inputs = arguments["inputs"] as String
    val graphData = arguments["graphData"] as ByteArray

    val witness = calculateWitness(
      inputs,
      graphData,
    )

    result.success(witness)
  }
}
