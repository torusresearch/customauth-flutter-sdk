import 'dart:io';

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
  dynamic _torusLoginInfo;
  String _currentVerifier = "Google";
  String _privateKey = "Waiting for login...";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Torus Direct example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(
                  child: Text("Google Login"),
                  onPressed: _googleLogin,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(
                  child: Text("Facebook Login"),
                  onPressed: _facebookLogin,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(
                  child: Text("Reddit Login"),
                  onPressed: _redditLogin,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(
                  child: Text("Twitch Login"),
                  onPressed: _twitchLogin,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(
                  child: Text("Discord Login"),
                  onPressed: _discordLogin,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _currentVerifier + " key: " + _privateKey,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _googleLogin() async {
    bool success;
    if (Platform.isIOS) {
      success = await TorusDirect.setVerifierDetails(
          LoginType.installed.value,
          VerifierType.singleLogin.value,
          "samtwo-google",
          "360801018673-1tmrfbvc2og29c8lmoljpl16ptkc20b3.apps.googleusercontent.com",
          LoginProvider.google.value,
          "samtwo-google",
          "com.googleusercontent.apps.360801018673-1tmrfbvc2og29c8lmoljpl16ptkc20b3:/oauthredirect");
    } else {
      success = await TorusDirect.setVerifierDetails(
          LoginType.installed.value,
          VerifierType.singleLogin.value,
          "google-lrc",
          "221898609709-obfn3p63741l5333093430j3qeiinaa8.apps.googleusercontent.com",
          LoginProvider.google.value,
          "google-lrc",
          "com.googleusercontent.apps.221898609709-obfn3p63741l5333093430j3qeiinaa8:/oauthredirect");
    }

    print(success);

    Map<dynamic, dynamic> _torusLoginInfo;
    _torusLoginInfo = await TorusDirect.triggerLogin();

    setState(() {
      _privateKey = _torusLoginInfo['privateKey'];
      _currentVerifier = "Google";
    });
  }

  _facebookLogin() async {
    TorusDirect.setVerifierDetails(
        LoginType.installed.value,
        VerifierType.singleLogin.value,
        "facebook-shubs",
        "659561074900150",
        LoginProvider.facebook.value,
        "facebook-shubs",
        "flutter://flutter-ios/oauthCallback");
    _torusLoginInfo = await TorusDirect.triggerLogin();
    setState(() {
      _privateKey = _torusLoginInfo['privateKey'];
      _currentVerifier = "Facebook";
    });
  }

  _twitchLogin() async {
    TorusDirect.setVerifierDetails(
        LoginType.web.value,
        VerifierType.singleLogin.value,
        "twitch-shubs",
        "p560duf74b2bidzqu6uo0b3ot7qaao",
        LoginProvider.twitch.value,
        "twitch-shubs",
        "flutter://flutter-ios/oauthCallback");
    _torusLoginInfo = await TorusDirect.triggerLogin();
    setState(() {
      _currentVerifier = "Twitch";
      _privateKey = _torusLoginInfo['privateKey'];
    });
  }

  _redditLogin() async {
    TorusDirect.setVerifierDetails(
        LoginType.web.value,
        VerifierType.singleLogin.value,
        "reddit-shubs",
        "rXIp6g2y3h1wqg",
        LoginProvider.reddit.value,
        "reddit-shubs",
        "flutter://flutter-ios/oauthCallback");
    _torusLoginInfo = await TorusDirect.triggerLogin();
    setState(() {
      _currentVerifier = "Reddit";
      _privateKey = _torusLoginInfo['privateKey'];
    });
  }

  _discordLogin() async {
    TorusDirect.setVerifierDetails(
        LoginType.web.value,
        VerifierType.singleLogin.value,
        "discord-shubs",
        "700259843063152661",
        LoginProvider.discord.value,
        "discord-shubs",
        "flutter://flutter-ios/oauthCallback");

    Map<dynamic, dynamic> _torusLoginInfo = await TorusDirect.triggerLogin();

    setState(() {
      _currentVerifier = "Discord";
      _privateKey = _torusLoginInfo['privateKey'];
    });
  }
}
