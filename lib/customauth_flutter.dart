import 'dart:async';

import 'package:flutter/services.dart';

enum Web3AuthNetwork { mainnet, testnet, cyan, aqua, celeste }

enum Web3AuthLogin {
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

enum Web3AuthAggregateVerifierType { single_id_verifier }

class Web3AuthCredentials {
  final String publicAddress;
  final String privateKey;
  final List<Web3AuthUserInfo> userInfo;

  Web3AuthCredentials(
    this.publicAddress,
    this.privateKey,
    this.userInfo,
  );
}

class Web3AuthUserInfo {
  final String? email;
  final String? name;
  final String? profileImage;
  final String? verifier;
  final String? verifierId;
  final String? typeOfLogin;
  final String? accessToken;
  final String? idToken;

  const Web3AuthUserInfo({
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

class Web3AuthSubVerifierDetails {
  final Web3AuthLogin typeOfLogin;
  final String verifier;
  final String clientId;
  final Map jwtParams;

  Web3AuthSubVerifierDetails({
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

class Web3AuthSubVerifierInfo {
  final String verifier;
  final String idToken;

  Web3AuthSubVerifierInfo({
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

  static Future<void> init({required Web3AuthNetwork network,
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

  static Future<Web3AuthCredentials> triggerLogin({
    required Web3AuthLogin typeOfLogin,
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
      return Web3AuthCredentials(
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

  static Future<Web3AuthCredentials> triggerAggregateLogin({
    required Web3AuthAggregateVerifierType aggerateVerifierType,
    required String verifierIdentifier,
    required List<Web3AuthSubVerifierDetails> subVerifierDetailsArray,
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
      return Web3AuthCredentials(
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

  static Future<Web3AuthCredentials> getTorusKey({
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
    return Web3AuthCredentials(
        getResponse['publicAddress'], getResponse['privateKey'], []);
  }

  static Future<Web3AuthCredentials> getAggregateTorusKey({
    required String verifier,
    required String verifierId,
    required List<Web3AuthSubVerifierInfo> subVerifierInfoArray,
  }) async {
    final Map getResponse =
        await _channel.invokeMethod('getAggregateTorusKey', {
      'verifier': verifier,
      'verifierId': verifierId,
      'subVerifierInfoArray':
          subVerifierInfoArray.map((e) => e.toMap()).toList(),
    });
    return Web3AuthCredentials(
        getResponse['publicAddress'], getResponse['privateKey'], []);
  }

  static List<Web3AuthUserInfo> _convertUserInfo(dynamic obj) {
    if (obj == null) {
      return [];
    }
    if (obj is List<dynamic>) {
      return obj
          .whereType<Map>()
          .map((e) => Web3AuthUserInfo(
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
        Web3AuthUserInfo(
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
