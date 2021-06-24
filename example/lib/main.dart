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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Login with'),
            ),
            ElevatedButton(
                onPressed: _login(_withGoogle), child: Text('Google')),
            ElevatedButton(
                onPressed: _login(_withFacebook), child: Text('Facebook')),
            ElevatedButton(
                onPressed: _login(_withReddit), child: Text('Reddit ')),
            ElevatedButton(
                onPressed: _login(_withDiscord), child: Text('Discord')),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Private key: $_privateKey'),
            )
          ],
        )),
      ),
    );
  }

  VoidCallback _login(Future<TorusCredentials> Function() method) {
    return () async {
      try {
        final TorusCredentials credentials = await method();
        setState(() {
          _privateKey = credentials.privateKey;
        });
      } on UserCancelledException {
        print("User cancelled.");
      } on NoAllowedBrowserFoundException {
        print("No allowed browser found.");
      }
    };
  }

  Future<TorusCredentials> _withGoogle() {
    return TorusDirect.triggerLogin(
        typeOfLogin: TorusLogin.google,
        verifier: 'google-lrc',
        clientId:
            '221898609709-obfn3p63741l5333093430j3qeiinaa8.apps.googleusercontent.com',
        jwtParams: {});
  }

  Future<TorusCredentials> _withFacebook() {
    return TorusDirect.triggerLogin(
        typeOfLogin: TorusLogin.facebook,
        verifier: 'facebook-lrc',
        clientId: '617201755556395',
        jwtParams: {});
  }

  Future<TorusCredentials> _withReddit() {
    return TorusDirect.triggerLogin(
        typeOfLogin: TorusLogin.reddit,
        verifier: 'torus-reddit-test',
        clientId: 'YNsv1YtA_o66fA',
        jwtParams: {});
  }

  Future<TorusCredentials> _withDiscord() {
    return TorusDirect.triggerLogin(
        typeOfLogin: TorusLogin.discord,
        verifier: 'discord-lrc',
        clientId: '682533837464666198',
        jwtParams: {});
  }
}
