import Flutter
import UIKit
import TorusSwiftDirectSDK

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
        print("TorusDirectPlugin#init: network=\(network), redirectUri=\(redirectUri)")
        result(nil)
    case "triggerLogin":
        guard let initArgs = self.torusDirectArgs
        else {
            result(FlutterError(
                code: "NotInitializedException",
                message: "TorusDirect.init has to be called first",
                details: nil))
            return
        }
        guard
            let typeOfLogin = args["typeOfLogin"] as? String,
            let verifier = args["verifier"] as? String,
            let clientId = args["clientId"] as? String
        else {
            result(FlutterError(
                code: "MissingArgumentException",
                message: "Missing triggerLogin arguments",
                details: nil))
            return
        }
        guard let loginProvider = LoginProviders(rawValue: typeOfLogin) else {
            result(FlutterError(
                code: "InvalidTypeOfLogin",
                message: "Invalid type of login",
                details: nil))
            return
        }
        
        let jwtParams = args["jwtParams"] as? Dictionary<String, String>
        let subVerifierDetails = SubVerifierDetails(
            loginType: .web,
            loginProvider: loginProvider,
            clientId: clientId,
            verifierName: verifier,
            redirectURL: initArgs.redirectUri,
            browserRedirectURL: "https://scripts.toruswallet.io/redirect.html",
            extraQueryParams: [:],
            jwtParams: jwtParams ?? [:]
        )
        let torusDirectSdk = TorusSwiftDirectSDK(
            aggregateVerifierType: .singleLogin,
            aggregateVerifierName: verifier,
            subVerifierDetails: [subVerifierDetails]
        )
        torusDirectSdk.triggerLogin(browserType: .external).done { data in
            result(data)
        }.catch { err in
            result(FlutterError())
        }
    case "getTorusKey":
        guard let initArgs = self.torusDirectArgs
        else {
            result(FlutterError(
                code: "NotInitializedException",
                message: "TorusDirect.init has to be called first",
                details: nil))
            return
        }
        guard
            let verifier = args["verifier"] as? String,
            let verifierId = args["verifierId"] as? String,
            let idToken = args["idToken"] as? String,
            let verifierParams = args["verifierParams"] as? Dictionary<String, String>
        else {
            result(FlutterError(
                code: "MissingArgumentException",
                message: "Missing triggerLogin arguments",
                details: nil))
            return
        }
        let subVerifierDetails = SubVerifierDetails(
            loginType: .web,
            loginProvider: .jwt,
            clientId: "<empty>",
            verifierName: verifier,
            redirectURL: initArgs.redirectUri,
            browserRedirectURL: "https://scripts.toruswallet.io/redirect.html",
            extraQueryParams: [:],
            jwtParams: [:]
        )
        let torusDirectSdk = TorusSwiftDirectSDK(
            aggregateVerifierType: .singleLogin,
            aggregateVerifierName: verifier,
            subVerifierDetails: [subVerifierDetails]
        )
        torusDirectSdk.getTorusKey(verifier: verifier, verifierId: verifierId, idToken: idToken, userData: verifierParams).done { data in
            result(data)
        }.catch { err in
            result(FlutterError())
        }
    default:
        result(FlutterMethodNotImplemented)
    }
  }
}
