# customauth-flutter-sdk

Torus CustomAuth SDK for Flutter applications.

## Installation

Install from

```
https://pub.dev/packages/customauth_flutter
```

## 🩹 Examples

Checkout the example of `CustomAuth Flutter SDK` in our
[examples directory.](https://github.com/torusresearch/customauth-flutter-sdk/tree/master/example)

## Usage

Add `customauth` package to your pubspec and import the package:

```dart
import 'package:customauth/customauth.dart';
```

Decide which OAuth provider you'll being using. See
[Torus CustomAuth supported OAuth providers](https://docs.tor.us/customauth/supported-authenticators-verifiers).

Go to [Torus Developer](https://developer.tor.us) and create your verifier for
your OAuth provider of choice with corresponding configuration.

Initialize the package:

```dart
await TorusDirect.init(
    network: TorusNetwork.testnet,
    browserRedirectUri:
        Uri.parse('https://scripts.toruswallet.io/redirect.html'),
    redirectUri: Uri.parse(
        'torusapp://org.torusresearch.torusdirectandroid/redirect')); // Replace with your app URL
```

`browserRedirectUri` is where you host your callback/redirect URL from OAuth
provider (Google, Facebook, Twitter, etc), some of these providers do not accept
custom scheme (only accept https), in these cases, you'll need a browser URL the
proxy the OAuth result to your app custom scheme.

If you don't supply `browserRedirectUri`, it will be default to `redirectUri`.

Trigger login while your user is interacting with your application:

```dart
await TorusDirect.triggerLogin(
    typeOfLogin: TorusLogin.google,
    verifier: 'google-lrc',
    clientId:
        'GOOGLE_CLIENT_ID');
```

Or get Torus key directly if you're using JWT verifier:

```dart
await TorusDirect.getTorusKey(
    verifier: 'acme-jwt',
    verifierId: idToken.sub,
    idToken: idToken.jwt);
```

### Android-specific configuration

Add custom URL schemes to your app by adding the following to your app
`android/app/build.gradle`:

```groovy
manifestPlaceholders = [
    'torusRedirectScheme': 'torusapp',
    'torusRedirectHost': 'org.torusresearch.torusdirectandroid',
    'torusRedirectPathPrefix': '/redirect'
]
```

### iOS-specific configuration

Open the project in XCode (open `ios/Runner.xcworkspace`) and add a custom URL
types.

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

## 💬 Troubleshooting and Discussions

- Have a look at our
  [GitHub Discussions](https://github.com/Web3Auth/Web3Auth/discussions?discussions_q=sort%3Atop)
  to see if anyone has any questions or issues you might be having.
- Checkout our
  [Troubleshooting Documentation Page](https://web3auth.io/docs/troubleshooting)
  to know the common issues and solutions
- Join our [Discord](https://discord.gg/web3auth) to join our community and get
  private integration support or help with your integration.
