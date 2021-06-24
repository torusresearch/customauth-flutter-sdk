# torus_direct

Torus CustomAuth SDK for Flutter applications.

## Get started

Checkout [`example/`](/example).

## Usage

Add `torus_direct` package to your pubspec and import the package:

```dart
import 'package:torus_direct/torus_direct.dart';
```

Decide which OAuth provider you'll being using. See [Torus CustomAuth supported OAuth providers](https://docs.tor.us/customauth/supported-authenticators-verifiers).

Go to [Torus Developer](https://developer.tor.us) and create your verifier for your OAuth provider of choice with corresponding configuration.

Initialize the package:

```dart
await TorusDirect.init(
    network: TorusNetwork.testnet,
    redirectUri: Uri.parse(
        'torusapp://org.torusresearch.torusdirectandroid/redirect')); // Replace with your app URL
```

Trigger login while your user is interacting with your application:

```dart
TorusDirect.triggerLogin(
    typeOfLogin: TorusLogin.google,
    verifier: 'google-lrc',
    clientId:
        '221898609709-obfn3p63741l5333093430j3qeiinaa8.apps.googleusercontent.com',
    jwtParams: {});
```

### Android-specific configuration

Add custom URL schemes to your app by adding the following to your app `android/app/build.gradle`:

```groovy
manifestPlaceholders = [
    'torusRedirectScheme': 'torusapp',
    'torusRedirectHost': 'org.torusresearch.torusdirectandroid',
    'torusRedirectPathPrefix': '/redirect'
]
```

### iOS-specific configuration

Open the project in XCode (open `ios/Runner.xcworkspace`) and add a custom URL types.

Add the following to `ios/Runner/AppDelegate.swift` to handle redirect URL:

```swift
import UIKit
import Flutter
import TorusSwiftDirectSDK

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
  // Handle redirect URL and send to Torus Direct instance
  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    TorusSwiftDirectSDK.handle(url: url)
    return true
  }
}

```