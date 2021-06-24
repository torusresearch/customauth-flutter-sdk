import 'dart:async';
import 'package:flutter/material.dart';
import 'package:torus_direct/torus_direct.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _privateKey = '<empty>';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    await TorusDirect.init(
        network: TorusNetwork.testnet,
        redirectUri: Uri.parse(
            'torusapp://org.torusresearch.torusdirectexample/redirect'));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Torus CustomAuth Example'),
        ),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: _googleLogin, child: Text('Google Login')),
            ElevatedButton(
                onPressed: _facebookLogin, child: Text('Facebook Login')),
            ElevatedButton(
                onPressed: _redditLogin, child: Text('Reddit Login')),
            ElevatedButton(
                onPressed: _discordLogin, child: Text('Discord Login')),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Private key: $_privateKey'),
            )
          ],
        )),
      ),
    );
  }

  _googleLogin() async {
    print('Login.google');
  }

  _facebookLogin() async {
    print('Login.facebook');
  }

  _redditLogin() async {
    print('Login.reddit');
  }

  _discordLogin() async {
    print('Login.discord');
  }
}
