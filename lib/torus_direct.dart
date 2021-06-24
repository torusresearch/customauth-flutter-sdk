import 'dart:async';
import 'package:flutter/services.dart';

enum TorusNetwork { mainnet, testnet }

class TorusDirect {
  static const MethodChannel _channel = const MethodChannel('torus_direct');

  static Future<void> init({network: TorusNetwork, redirectUri: Uri}) async {
    final String networkString = network.toString();
    await _channel.invokeMethod('init', {
      'network': networkString.substring(networkString.lastIndexOf('.') + 1),
      'redirectUri': redirectUri.toString()
    });
  }
}
