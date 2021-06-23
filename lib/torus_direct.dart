library torus_direct;
import 'package:flutter/services.dart';

class TorusDirect {
  static const _channel = const MethodChannel('torus.flutter.dev/torus-direct');

  // Set your verifier options for your logins.

  static Future<bool> setVerifierDetails(
      String loginType,
      String verifierType,
      String verifierName,
      String clientId,
      String loginProvider,
      String verifier,
      String redirectURL) async {
    try {
      return await _channel.invokeMethod('setVerifierDetails', {
        "loginType": loginType,
        "verifierType": verifierType,
        "verifierName": verifierName,
        "clientId": clientId,
        "loginProvider": loginProvider,
        "verifier": verifier,
        "redirectURL": redirectURL
      });
    } on PlatformException catch (e) {
      print(e);
      return false;
    }
  }


  // Trigger the Torus Login.
  static Future<Map<dynamic, dynamic>> triggerLogin() async {
    try {
      return await _channel.invokeMethod('triggerLogin');
    } on PlatformException catch (e) {
      print(e);
      throw e;
    }
  }
}

enum VerifierType {
  singleLogin,
  singleIdVerifier,
  andAggregateVerifier,
  orAggregateVerifier
}

enum LoginType { web, installed }

enum LoginProvider { google, facebook, twitch, reddit, discord, auth0 }

extension LoginTypeExtension on LoginType {
  String get value {
    switch (this) {
      case LoginType.web:
        return "web";
        break;
      case LoginType.installed:
        return "installed";
        break;
      default:
        return "web";
    }
  }
}

extension VerifierExtension on VerifierType {
  String get value {
    switch (this) {
      case VerifierType.singleLogin:
        return "single_login";
        break;
      case VerifierType.singleIdVerifier:
        return "single_id_verifier";
        break;
      case VerifierType.andAggregateVerifier:
        return "and_aggregate_verifier";
        break;
      case VerifierType.orAggregateVerifier:
        return "or_aggregate_verifier";
        break;
      default:
        return "single_login";
    }
  }
}

extension LoginProviderExtension on LoginProvider {
  String get value {
    switch (this) {
      case LoginProvider.google:
        return "google";
        break;
      case LoginProvider.facebook:
        return "facebook";
        break;
      case LoginProvider.twitch:
        return "twitch";
        break;
      case LoginProvider.reddit:
        return "reddit";
        break;
      case LoginProvider.discord:
        return "discord";
        break;
      case LoginProvider.auth0:
        return "auth0";
        break;
      default:
        return "google";
    }
  }
}
