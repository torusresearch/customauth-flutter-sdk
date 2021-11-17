import Flutter
import UIKit
import TorusSwiftDirectSDK
import FetchNodeDetails

struct TorusDirectArgs {
    let network: String;
    let browserRedirectUri: String;
    let redirectUri: String;
    
    var ethereumNetwork: EthereumNetwork {
        get {
            switch network {
            case "mainnet":
                return EthereumNetwork.MAINNET
            case "testnet":
                return EthereumNetwork.ROPSTEN
            default:
                return EthereumNetwork.ROPSTEN
            }
        }
    }
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
                let browserRedirectUri = args["browserRedirectUri"] as? String,
                let redirectUri = args["redirectUri"] as? String
            else {
                result(FlutterError(
                        code: "MISSING_ARGUMENTS",
                        message: "Missing init arguments",
                        details: nil))
                return
            }
            self.torusDirectArgs = TorusDirectArgs(
                network: network, browserRedirectUri: browserRedirectUri, redirectUri: redirectUri)
            print("TorusDirectPlugin#init: " +
                    "network=\(network), " +
                    "browserRedirectUri=\(redirectUri), redirectUri=\(redirectUri)")
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
                        code: "InvalidTypeOfLoginException",
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
                browserRedirectURL: initArgs.browserRedirectUri,
                extraQueryParams: [:],
                jwtParams: jwtParams ?? [:]
            )
            let torusDirectSdk = TorusSwiftDirectSDK(
                aggregateVerifierType: .singleLogin,
                aggregateVerifierName: verifier,
                subVerifierDetails: [subVerifierDetails],
                network: initArgs.ethereumNetwork
            )
            torusDirectSdk.triggerLogin(browserType: .external).done { data in
                result(data)
            }.catch { err in
                result(FlutterError(
                    code: "IosSdkError", message: "Error from iOS SDK: \(err.localizedDescription)", details: err.localizedDescription
                ))
            }
        case "triggerAggregateLogin":
            guard let initArgs = self.torusDirectArgs
            else {
                result(FlutterError(
                        code: "NotInitializedException",
                        message: "TorusDirect.init has to be called first",
                        details: nil))
                return
            }
            guard
                let aggregateVerifierType = args["aggregateVerifierType"] as? String,
                let verifierIdentifier = args["verifierIdentifier"] as? String,
                let subVerifierDetailsArray = args["subVerifierDetailsArray"] as? [Dictionary<String, Any>]
            else {
                result(FlutterError(
                        code: "MissingArgumentException",
                        message: "Missing triggerAggregateLogin arguments",
                        details: nil))
                return
            }
            var castedSubVerifierDetailsArray: [SubVerifierDetails] = []
            for details in subVerifierDetailsArray {
                guard let loginProvider = LoginProviders(
                    rawValue: details["typeOfLogin"] as! String
                ) else {
                    result(FlutterError(
                            code: "InvalidTypeOfLoginException",
                            message: "Invalid type of login",
                            details: nil))
                    return
                }
                let jwtParams = details["jwtParams"] as? Dictionary<String, String>
                castedSubVerifierDetailsArray.append(
                    SubVerifierDetails(
                        loginType: .web,
                        loginProvider: loginProvider,
                        clientId: details["clientId"] as! String,
                        verifierName: details["verifier"] as! String,
                        redirectURL: initArgs.redirectUri,
                        browserRedirectURL: initArgs.browserRedirectUri,
                        extraQueryParams: [:],
                        jwtParams: jwtParams ?? [:]
                    )
                )
                let torusDirectSdk = TorusSwiftDirectSDK(
                    aggregateVerifierType: verifierTypes(rawValue: aggregateVerifierType)!,
                    aggregateVerifierName: verifierIdentifier,
                    subVerifierDetails: castedSubVerifierDetailsArray,
                    network: initArgs.ethereumNetwork
                )
                torusDirectSdk.triggerLogin(browserType: .external).done { data in
                    result(data)
                }.catch { err in
                    result(FlutterError(
                        code: "IosSdkError", message: "Error from iOS SDK: \(err.localizedDescription)", details: err.localizedDescription
                    ))
                }
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
                        message: "Missing getTorusKey arguments",
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
                subVerifierDetails: [subVerifierDetails],
                network: initArgs.ethereumNetwork
            )
            torusDirectSdk.getTorusKey(verifier: verifier, verifierId: verifierId, idToken: idToken, userData: verifierParams).done { data in
                result(data)
            }.catch { err in
                result(FlutterError(
                    code: "IosSdkError", message: "Error from iOS SDK: \(err.localizedDescription)", details: err.localizedDescription
                ))
            }
        case "getAggregateTorusKey":
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
                let subVerifierInfoArray = args["subVerifierInfoArray"] as? [Dictionary<String, Any>]
            else {
                result(FlutterError(
                        code: "MissingArgumentException",
                        message: "Missing getAggregateTorusKey arguments",
                        details: nil))
                return
            }
            if subVerifierInfoArray.count != 1 {
                result(FlutterError(
                    code: "InvalidArgumentException",
                    message: "subVerifierInfoArray must have length of 1",
                    details: nil
                ))
                return
            }
            let sviaVerifier = subVerifierInfoArray[0]["verifier"] as! String
            let sviaIdToken = subVerifierInfoArray[0]["idToken"] as! String
            let subVerifierDetails = SubVerifierDetails(
                loginType: .web,
                loginProvider: .jwt,
                clientId: "<empty>",
                verifierName: sviaVerifier == "" ? verifier : sviaVerifier,
                redirectURL: initArgs.redirectUri,
                browserRedirectURL: "https://scripts.toruswallet.io/redirect.html",
                extraQueryParams: [:],
                jwtParams: [:]
            )
            let torusDirectSdk = TorusSwiftDirectSDK(
                aggregateVerifierType: .singleIdVerifier,
                aggregateVerifierName: verifier,
                subVerifierDetails: [subVerifierDetails],
                network: initArgs.ethereumNetwork
            )
            torusDirectSdk.getAggregateTorusKey(verifier: verifier, verifierId: verifierId, idToken: sviaIdToken, subVerifierDetails: subVerifierDetails).done { data in
                result(data)
            }.catch { err in
                result(FlutterError(
                    code: "IosSdkError", message: "Error from iOS SDK: \(err.localizedDescription)", details: err.localizedDescription
                ))
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
