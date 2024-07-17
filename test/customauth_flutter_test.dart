import 'package:customauth_flutter/customauth_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const MethodChannel channel = MethodChannel('customauth');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '<empty>';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('init', () async {
    await CustomAuth.init(
        network: Web3AuthNetwork.aqua,
        clientid: "YOUR_CLIENT_ID",
        browserRedirectUri:
            Uri.parse('https://scripts.toruswallet.io/redirect.html'),
        redirectUri: Uri.parse(
            'torusapp://org.torusresearch.torusdirectandroid/redirect'));
  });
}
