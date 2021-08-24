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

enum AggregateVerifierType { single_id_verifier }

class TorusCredentials {
  final String publicAddress;
  final String privateKey;

  TorusCredentials(
    this.publicAddress,
    this.privateKey,
  );
}

class SubVerifierDetails {
  final TorusLogin typeOfLogin;
  final String verifier;
  final String clientId;
  final Map jwtParams;

  SubVerifierDetails({
    required this.typeOfLogin,
    required this.verifier,
    required this.clientId,
    this.jwtParams = const {},
  });

  Map<String, dynamic> toMap() {
    final String typeOfLoginString = typeOfLogin.toString();
    return <String, dynamic>{
      'typeOfLogin':
          typeOfLoginString.substring(typeOfLoginString.lastIndexOf('.') + 1),
      'verifier': verifier,
      'clientId': clientId,
      'jwtParams': jwtParams
    };
  }
}

class TorusSubVerifierInfo {
  final String verifier;
  final String idToken;

  TorusSubVerifierInfo({
    required this.verifier,
    required this.idToken,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'verifier': verifier,
      'idToken': idToken,
    };
  }
}

class UserCancelledException implements Exception {}

class NoAllowedBrowserFoundException implements Exception {}

class TorusDirect {
  static const MethodChannel _channel = const MethodChannel('torus_direct');

  static Future<void> init({
    required TorusNetwork network,
    required Uri redirectUri,
    Uri? browserRedirectUri,
  }) async {
    final String networkString = network.toString();
    final Uri mergedBrowserRedirectUri = browserRedirectUri ?? redirectUri;
    await _channel.invokeMethod('init', {
      'network': networkString.substring(networkString.lastIndexOf('.') + 1),
      'redirectUri': redirectUri.toString(),
      'browserRedirectUri': mergedBrowserRedirectUri.toString()
    });
  }

  static Future<TorusCredentials> triggerLogin({
    required TorusLogin typeOfLogin,
    required String verifier,
    required String clientId,
    Map jwtParams = const {},
  }) async {
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
        loginResponse['publicAddress'],
        loginResponse['privateKey'],
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

  static Future<TorusCredentials> triggerAggregateLogin({
    required AggregateVerifierType aggerateVerifierType,
    required String verifierIdentifier,
    required List<SubVerifierDetails> subVerifierDetailsArray,
  }) async {
    try {
      final String aggregateVerifierTypeString =
          aggerateVerifierType.toString();
      final Map loginResponse =
          await _channel.invokeMethod('triggerAggregateLogin', {
        'aggregateVerifierType': aggregateVerifierTypeString
            .substring(aggregateVerifierTypeString.lastIndexOf('.') + 1),
        'verifierIdentifier': verifierIdentifier,
        'subVerifierDetailsArray':
            subVerifierDetailsArray.map((e) => e.toMap()).toList(),
      });
      return TorusCredentials(
        loginResponse['publicAddress'],
        loginResponse['privateKey'],
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

  static Future<TorusCredentials> getTorusKey({
    required String verifier,
    required String verifierId,
    required String idToken,
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
    return TorusCredentials(
      getResponse['publicAddress'],
      getResponse['privateKey'],
    );
  }

  static Future<TorusCredentials> getAggregateTorusKey({
    required String verifier,
    required String verifierId,
    required List<TorusSubVerifierInfo> subVerifierInfoArray,
  }) async {
    final Map getResponse =
        await _channel.invokeMethod('getAggregateTorusKey', {
      'verifier': verifier,
      'verifierId': verifierId,
      'subVerifierInfoArray':
          subVerifierInfoArray.map((e) => e.toMap()).toList(),
    });
    return TorusCredentials(
      getResponse['publicAddress'],
      getResponse['privateKey'],
    );
  }
}
