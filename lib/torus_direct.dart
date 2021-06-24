import 'dart:async';
import 'package:flutter/services.dart';

enum TorusNetwork { mainnet, testnet }

enum TorusLogin {
  google,
  facebook,
  reddit,
  discord,
  twitch,
  github,
  apple,
  linkedin,
  twitter,
  line,
  email_password,
  jwt
}

class TorusCredentials {
  final String publicAddress;
  final String privateKey;
  TorusCredentials(
    this.publicAddress,
    this.privateKey,
  );
}

class UserCancelledException implements Exception {}

class NoAllowedBrowserFoundException implements Exception {}

class TorusDirect {
  static const MethodChannel _channel = const MethodChannel('torus_direct');

  static Future<void> init({network: TorusNetwork, redirectUri: Uri}) async {
    final String networkString = network.toString();
    await _channel.invokeMethod('init', {
      'network': networkString.substring(networkString.lastIndexOf('.') + 1),
      'redirectUri': redirectUri.toString()
    });
  }

  static Future<TorusCredentials> triggerLogin(
      {typeOfLogin: TorusLogin,
      verifier: String,
      clientId: String,
      jwtParams: Map}) async {
    try {
      final String typeOfLoginString = typeOfLogin.toString();
      final Map<dynamic, dynamic> loginResponse =
          await _channel.invokeMethod('triggerLogin', {
        'typeOfLogin':
            typeOfLoginString.substring(typeOfLoginString.lastIndexOf('.') + 1),
        'verifier': verifier,
        'clientId': clientId,
        'jwtParams': jwtParams
      });
      return TorusCredentials(
        loginResponse['publicAddress'],
        loginResponse['privateKey'],
      );
    } on PlatformException catch (e) {
      switch (e.code) {
        case "org.torusresearch.torusdirect.types.UserCancelledException":
          throw new UserCancelledException();
        case "org.torusresearch.torusdirect.types.NoAllowedBrowserFoundException":
          throw new NoAllowedBrowserFoundException();
        default:
          throw e;
      }
    }
  }
}
