import 'dart:async';

import 'package:flutter/material.dart';
import 'package:customauth_flutter/customauth.dart';

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
    await CustomAuth.init(
        network: TorusNetwork.testnet,
        browserRedirectUri:
            Uri.parse('https://scripts.toruswallet.io/redirect.html'),
        redirectUri: Uri.parse(
            'torus://org.torusresearch.sample/redirect'));
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
            ElevatedButton(
                onPressed: _login(_withAggregate), child: Text('Aggregate')),
            ElevatedButton(
                onPressed: _login(_withGetTorusKey), child: Text('Get Torus Key')),
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
    return CustomAuth.triggerLogin(
        typeOfLogin: TorusLogin.google,
        verifier: 'google-lrc',
        clientId:
            '221898609709-obfn3p63741l5333093430j3qeiinaa8.apps.googleusercontent.com');
  }

  Future<TorusCredentials> _withFacebook() {
    return CustomAuth.triggerLogin(
        typeOfLogin: TorusLogin.facebook,
        verifier: 'facebook-lrc',
        clientId: '617201755556395');
  }

  Future<TorusCredentials> _withReddit() {
    return CustomAuth.triggerLogin(
        typeOfLogin: TorusLogin.reddit,
        verifier: 'torus-reddit-test',
        clientId: 'YNsv1YtA_o66fA');
  }

  Future<TorusCredentials> _withDiscord() {
    return CustomAuth.triggerLogin(
        typeOfLogin: TorusLogin.discord,
        verifier: 'discord-lrc',
        clientId: '682533837464666198');
  }


  Future<TorusCredentials> _withAggregate() {
    return CustomAuth.triggerAggregateLogin(
      aggerateVerifierType: TorusAggregateVerifierType.single_id_verifier,
      verifierIdentifier: 'chai-google-aggregate-test',
      subVerifierDetailsArray: <TorusSubVerifierDetails>[
        TorusSubVerifierDetails(
          typeOfLogin: TorusLogin.google,
          verifier: 'google-chai',
          clientId:
              '884454361223-nnlp6vtt0me9jdsm2ptg4d1dh8i0tu74.apps.googleusercontent.com',
        ),
      ],
    );
  }

  Future<TorusCredentials> _withGetTorusKey() {
    return CustomAuth.getTorusKey(
      verifier: 'weact-email-password-ic-verifier',
      verifierId: 'flutteryfi@gmail.com',
      idToken: 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImZLSVduR3NVNnA4ZTZ6R1lyaXBHeiJ9.eyJuaWNrbmFtZSI6ImZsdXR0ZXJ5ZmkiLCJuYW1lIjoiZmx1dHRlcnlmaUBnbWFpbC5jb20iLCJwaWN0dXJlIjoiaHR0cHM6Ly9zLmdyYXZhdGFyLmNvbS9hdmF0YXIvMDAwYzNhZWE1YzFiYzhiOTRlMmRhOThhN2RmYzA2YWI_cz00ODAmcj1wZyZkPWh0dHBzJTNBJTJGJTJGY2RuLmF1dGgwLmNvbSUyRmF2YXRhcnMlMkZmbC5wbmciLCJ1cGRhdGVkX2F0IjoiMjAyMS0xMC0xM1QwNjoyMzowNS4wMDFaIiwiZW1haWwiOiJmbHV0dGVyeWZpQGdtYWlsLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJpc3MiOiJodHRwczovL2Rldi1qMG4tcHR6MS5ldS5hdXRoMC5jb20vIiwic3ViIjoiYXV0aDB8NjE0NjQzZDE5OGJjYmQwMDY4MmU2OGNhIiwiYXVkIjoiZ3o0cWlsUThNQ3ptcFlRWGc3VVIxUFRtOVVkdEQyd3kiLCJpYXQiOjE2MzQxNDI2OTUsImV4cCI6MTYzNDE3ODY5NSwiYXV0aF90aW1lIjoxNjM0MTA2MTg1fQ.XvsSckgGL8URNGzXexl8wzMNwo7bn9ppwLGwMgMFy73zFt-NbvVuj3ZP7x6erBsjNtqhB0aPmXvR3gNZBU6i-ouV_6Td2ECOsZ21e9qYef4MsUovLCWpmyU5oVxtgXcYPnOC-QxdUwgMcfE0pFcxGM3BCg37-kEUk9HEOViGt_cV0X97E-zI6g1HvrWrgq3nK405bD6yrTLmEUlXyI1hLgHFKRi4iRY1vPEcY43XryfnZRO9I0T8wIVTL4RjF6eHjNs9jPy1paR6XP5YhG8L5vhArc7fkog0o3c7QID2om5q_hRPILw39nzmn046af2H_lSV-o1F-iBS5IyN12uH3w',

    );
  }
}
