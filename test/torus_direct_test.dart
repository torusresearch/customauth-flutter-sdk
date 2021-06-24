import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:torus_direct/torus_direct.dart';

void main() {
  const MethodChannel channel = MethodChannel('torus_direct');

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
    await TorusDirect.init();
  });
}
