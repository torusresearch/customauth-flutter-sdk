import Flutter
import UIKit

struct TorusDirectArgs {
    let network: String;
    let redirectUri: String;
}

public class SwiftTorusDirectPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "torus_direct", binaryMessenger: registrar.messenger())
    let instance = SwiftTorusDirectPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
    
  var torusDirectArgs: TorusDirectArgs? = nil

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? Dictionary<String, Any> else {
      result(FlutterError(
                code: "INVALID_ARGUMENTS",
                message: "Invalid Flutter iOS plugin method arguments",
                details: nil))
      return
    }
    
    switch call.method {
    case "init":
        guard
            let network = args["network"] as? String,
            let redirectUri = args["redirectUri"] as? String
        else {
            result(FlutterError(
                code: "MISSING_ARGUMENTS",
                message: "Missing init arguments",
                details: nil))
            return
        }
        self.torusDirectArgs = TorusDirectArgs(network: network, redirectUri: redirectUri)
        print("init: network=\(network), redirectUri=\(redirectUri)")
        result(nil)
    case "triggerLogin":
        guard
            let typeOfLogin = args["typeOfLogin"] as? String,
            let verifier = args["verifier"] as? String,
            let clientId = args["clientId"] as? String
        else {
            result(FlutterError(
                code: "MISSING_ARGUMENTS",
                message: "Missing triggerLogin arguments",
                details: nil))
            return
        }
        let jwtParams = args["jwtParams"] as? Dictionary<String, Any>
        print("triggerLogin: typeOfLogin=\(typeOfLogin), verifier=\(verifier), clientId=\(clientId)")
        result([
            "publicAddress": "<public address>",
            "privateKey": "<privateKey"
        ])
    default:
        result(FlutterMethodNotImplemented)
    }
  }
}
