package io.iden3.circom_witnesscalc

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.iden3.circomwitnesscalc.*
import android.os.Handler
import android.os.Looper
import java.util.concurrent.Executors
import java.util.concurrent.ExecutorService

/** CircomWitnesscalcPlugin */
class CircomWitnesscalcPlugin: FlutterPlugin, MethodCallHandler {
  // Thread pool for heavy witness calculations (uses cached thread pool to avoid excessive threads)
  private val executor: ExecutorService = Executors.newCachedThreadPool()
  private val mainHandler = Handler(Looper.getMainLooper())

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
    executor.shutdown()
  }

  private fun handleCalculateWitness(call: MethodCall, result: Result) {
    val arguments: Map<String, Any> = call.arguments<Map<String, Any>>()!!

    val inputs = arguments["inputs"] as String
    val graphData = arguments["graphData"] as ByteArray

    if (inputs == null || graphData == null) {
      result.error("CIRCOM_WITNESSCALC_ERROR", "Missing inputs or graphData", null)
      return
    }

    // Run heavy calculation off the main thread
    executor.execute {
      try {
        val witness = calculateWitness(
          inputs,
          graphData,
        )
        // Post result back to main thread
        mainHandler.post { result.success(witness) }
      } catch (e: Exception) { // Catch any calculation error
        mainHandler.post { result.error("CIRCOM_WITNESSCALC_ERROR", e.message ?: "Unknown error", null) }
      }
    }
  }
}
