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
    final TorusCredentials credentials = await TorusDirect.triggerLogin(
        typeOfLogin: TorusLogin.google,
        verifier: 'google-lrc',
        clientId:
            '221898609709-obfn3p63741l5333093430j3qeiinaa8.apps.googleusercontent.com',
        jwtParams: {});
    setState(() {
      _privateKey = credentials.privateKey;
    });
  }

  _facebookLogin() async {
    final TorusCredentials credentials = await TorusDirect.triggerLogin(
        typeOfLogin: TorusLogin.facebook,
        verifier: 'facebook-lrc',
        clientId: '617201755556395',
        jwtParams: {});
    setState(() {
      _privateKey = credentials.privateKey;
    });
  }

  _redditLogin() async {
    final TorusCredentials credentials = await TorusDirect.triggerLogin(
        typeOfLogin: TorusLogin.reddit,
        verifier: 'torus-reddit-test',
        clientId: 'YNsv1YtA_o66fA',
        jwtParams: {});
    setState(() {
      _privateKey = credentials.privateKey;
    });
  }

  _discordLogin() async {
    final TorusCredentials credentials = await TorusDirect.triggerLogin(
        typeOfLogin: TorusLogin.discord,
        verifier: 'discord-lrc',
        clientId: '682533837464666198',
        jwtParams: {});
    setState(() {
      _privateKey = credentials.privateKey;
    });
  }
}
