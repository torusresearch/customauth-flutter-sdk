import 'dart:async';

import 'package:flutter/services.dart';

enum TorusNetwork { mainnet, testnet, cyan, aqua, celeste }

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

enum TorusAggregateVerifierType { single_id_verifier }

class TorusCredentials {
  final String publicAddress;
  final String privateKey;
  final List<TorusUserInfo> userInfo;

  TorusCredentials(
    this.publicAddress,
    this.privateKey,
    this.userInfo,
  );
}

class TorusUserInfo {
  final String? email;
  final String? name;
  final String? profileImage;
  final String? verifier;
  final String? verifierId;
  final String? typeOfLogin;
  final String? accessToken;
  final String? idToken;

  const TorusUserInfo({
    required this.email,
    required this.name,
    required this.profileImage,
    required this.verifier,
    required this.verifierId,
    required this.typeOfLogin,
    required this.accessToken,
    required this.idToken,
  });
}

class TorusSubVerifierDetails {
  final TorusLogin typeOfLogin;
  final String verifier;
  final String clientId;
  final Map jwtParams;

  TorusSubVerifierDetails({
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

class CustomAuth {
  static const MethodChannel _channel = MethodChannel('customauth');

  static Future<void> init(
      {required TorusNetwork network,
      required Uri redirectUri,
      required String clientid,
      Uri? browserRedirectUri,
      bool? enableOneKey,
      String? networkUrl}) async {
    final String networkString = network.toString();
    final Uri mergedBrowserRedirectUri = browserRedirectUri ?? redirectUri;
    await _channel.invokeMethod('init', {
      'network': networkString.substring(networkString.lastIndexOf('.') + 1),
      'redirectUri': redirectUri.toString(),
      'clientid': clientid,
      'browserRedirectUri': mergedBrowserRedirectUri.toString(),
      'enableOneKey': enableOneKey ?? false,
      'networkUrl': networkUrl ?? '',
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
        _convertUserInfo(loginResponse['userInfo']),
      );
    } on PlatformException catch (e) {
      switch (e.code) {
        case "UserCancelledException":
          throw UserCancelledException();
        case "NoAllowedBrowserFoundException":
          throw NoAllowedBrowserFoundException();
        default:
          rethrow;
      }
    }
  }

  static Future<TorusCredentials> triggerAggregateLogin({
    required TorusAggregateVerifierType aggerateVerifierType,
    required String verifierIdentifier,
    required List<TorusSubVerifierDetails> subVerifierDetailsArray,
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
        _convertUserInfo(loginResponse['userInfo']),
      );
    } on PlatformException catch (e) {
      switch (e.code) {
        case "UserCancelledException":
          throw UserCancelledException();
        case "NoAllowedBrowserFoundException":
          throw NoAllowedBrowserFoundException();
        default:
          rethrow;
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
        getResponse['publicAddress'], getResponse['privateKey'], []);
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
        getResponse['publicAddress'], getResponse['privateKey'], []);
  }

  static List<TorusUserInfo> _convertUserInfo(dynamic obj) {
    if (obj == null) {
      return [];
    }
    if (obj is List<dynamic>) {
      return obj
          .whereType<Map>()
          .map((e) => TorusUserInfo(
                email: e['email'],
                name: e['name'],
                profileImage: e['profileImage'],
                verifier: e['verifier'],
                verifierId: e['verifierId'],
                typeOfLogin: e['typeOfLogin'],
                accessToken: e['accessToken'],
                idToken: e['idToken'],
              ))
          .toList();
    }
    if (obj is Map) {
      final Map e = obj;
      return [
        TorusUserInfo(
          email: e['email'],
          name: e['name'],
          profileImage: e['profileImage'],
          verifier: e['verifier'],
          verifierId: e['verifierId'],
          typeOfLogin: e['typeOfLogin'],
          accessToken: e['accessToken'],
          idToken: e['idToken'],
        )
      ];
    }
    throw Exception("incorrect userInfo format");
  }
}
