import 'dart:async';
import 'package:flutter/services.dart';

class TorusDirect {
  static const MethodChannel _channel = const MethodChannel('torus_direct');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<void> init() async {
    print('TorusDirect.init');
  }
}
