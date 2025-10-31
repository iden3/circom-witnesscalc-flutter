import Flutter
import UIKit

import CircomWitnesscalc

public class CircomWitnesscalcPlugin: NSObject, FlutterPlugin {
  // Dedicated concurrent background queue for heavy witness calculations
  private let workerQueue = DispatchQueue(
    label: "com.iden3.circomWitnesscalc.queue",
    qos: .userInitiated,
    attributes: .concurrent
  )

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

    let inputsData = (args["inputs"] as! String).data(using: .utf8)!
    let graphData = (args["graphData"] as! FlutterStandardTypedData).data

    // Perform heavy calculation off the main thread.
    workerQueue.async { [weak self] in
        guard self != nil else { return }
        do {
            let witness = try calculateWitness(
                inputs: inputsData,
                graph: graphData
            )
            // Return to main thread for delivering the result (UI safety / consistency)
            DispatchQueue.main.async {
                result(witness)
            }
        } catch let error as WitnessCalcError {
            DispatchQueue.main.async {
                result(FlutterError(code: "calculateWitness", message: "Witness calculation error", details: String(describing: error)))
            }
        } catch {
            DispatchQueue.main.async {
                result(FlutterError(code: "calculateWitness", message: "Unknown error", details: String(describing: error)))
            }
        }
    }
  }
}
