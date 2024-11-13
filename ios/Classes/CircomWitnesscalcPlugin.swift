import Flutter
import UIKit

import CircomWitnesscalc

public class CircomWitnesscalcPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "circom_witnesscalc", binaryMessenger: registrar.messenger())
    let instance = CircomWitnesscalcPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "calculateWitness":
        handleCalculateWitness(call, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func handleCalculateWitness(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as! Dictionary<String, Any>

    let inputs = args["inputs"] as! String
    let graphData = (args["graphData"] as! FlutterStandardTypedData).data

    do {
        let witness = try calculateWitness(
            inputs: inputs.data(using: .utf8)!,
            graph: graphData
        )

        result(witness)
    } catch is WitnessCalcError {
        result(FlutterError(code: "calculateWitness", message: "Witness calculation error", details: nil))
    } catch {
        result(FlutterError(code: "calculateWitness", message: "Unknown error", details: nil))
    }
  }
}
