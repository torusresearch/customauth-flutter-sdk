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

class TorusKey {
  final String publicAddress;
  final String privateKey;
  TorusKey(
    this.publicAddress,
    this.privateKey,
  );
}

class TorusCredentials {
  final String email;
  final String name;
  final String profileImage;
  final TorusKey torusKey;

  TorusCredentials(
    this.email,
    this.name,
    this.profileImage,
    this.torusKey,
  );
}

class UserCancelledException implements Exception {}

class NoAllowedBrowserFoundException implements Exception {}

class TorusDirect {
  static const MethodChannel _channel = const MethodChannel('torus_direct');

  static Future<void> init(
      {network: TorusNetwork,
      redirectUri: Uri,
      Uri? browserRedirectUri}) async {
    final String networkString = network.toString();
    final Uri mergedBrowserRedirectUri = browserRedirectUri ?? redirectUri;
    await _channel.invokeMethod('init', {
      'network': networkString.substring(networkString.lastIndexOf('.') + 1),
      'redirectUri': redirectUri.toString(),
      'browserRedirectUri': mergedBrowserRedirectUri.toString()
    });
  }

  static Future<TorusCredentials> triggerLogin(
      {typeOfLogin: TorusLogin,
      verifier: String,
      clientId: String,
      Map jwtParams = const {}}) async {
    try {
      final String typeOfLoginString = typeOfLogin.toString();
      final Map loginResponse = await _channel.invokeMethod('triggerLogin', {
        'typeOfLogin':
            typeOfLoginString.substring(typeOfLoginString.lastIndexOf('.') + 1),
        'verifier': verifier,
        'clientId': clientId,
        'jwtParams': jwtParams
      });
      return TorusCredentials(
        loginResponse['userInfo']['email'] ?? '',
        loginResponse['userInfo']['name'] ?? '',
        loginResponse['userInfo']['profileImage'] ?? '',
        TorusKey(loginResponse['publicAddress'] ?? '',
            loginResponse['privateKey'] ?? ''),
      );
    } on PlatformException catch (e) {
      switch (e.code) {
        case "UserCancelledException":
          throw new UserCancelledException();
        case "NoAllowedBrowserFoundException":
          throw new NoAllowedBrowserFoundException();
        default:
          throw e;
      }
    }
  }

  static Future<TorusKey> getTorusKey({
    verifier: String,
    verifierId: String,
    idToken: String,
    Map verifierParams = const {},
  }) async {
    final Map mergedVerfierParams = {
      ...{'verifier_id': verifierId},
      ...verifierParams
    };
    final Map getResponse = await _channel.invokeMethod('getTorusKey', {
      'verifier': verifier,
      'verifierId': verifierId,
      'idToken': idToken,
      'verifierParams': mergedVerfierParams
    });
    return TorusKey(
      getResponse['publicAddress'],
      getResponse['privateKey'],
    );
  }
}
