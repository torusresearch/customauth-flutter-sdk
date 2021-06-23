import Flutter
import UIKit
import SafariServices

public class SwiftTorusDirectPlugin: NSObject, FlutterPlugin {
    var torusSwiftDirectSDK: TorusSwiftDirectSDK? = nil
    var subVerifierDetails: SubVerifierDetails? =  nil
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "torus.flutter.dev/torus-direct", binaryMessenger: registrar.messenger())
    let instance = SwiftTorusDirectPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
        case "setVerifierDetails": 
            guard let args = call.arguments as? Dictionary<String, String> else {
              result("iOS could not recognize flutter arguments in method: (sendParams)") 
              break
            }
            let verifierTypeString : String  =  args["verifierType"]! as String
            let loginProviderString : String =  args["loginProvider"]! as String
            let clientId : String  =  args["clientId"]! as String
            let verifierName : String  = args["verifierName"]! as String
            let redirectURL : String =  args["redirectURL"]! as String
            let loginType : String = args["loginType"]! as String
          

            subVerifierDetails = SubVerifierDetails(loginType: SubVerifierType(rawValue:loginType)!,
                                                    loginProvider: LoginProviders(rawValue:loginProviderString)!,
                                                    clientId: clientId,
                                                    verifierName: verifierName,
                                                    redirectURL: redirectURL)
            self.torusSwiftDirectSDK = TorusSwiftDirectSDK(aggregateVerifierType: verifierTypes(rawValue: verifierTypeString)!, 
                                                            aggregateVerifierName: verifierName, 
                                                            subVerifierDetails: [subVerifierDetails!], loglevel: .trace)
            result(true)

        case "triggerLogin":
            self.torusSwiftDirectSDK!.triggerLogin(browserType: .external).done
            { 
              data in print("private key rebuild", data)
              result(data)
            }   
        default:
            result(FlutterMethodNotImplemented)
        }
    } 
  }


