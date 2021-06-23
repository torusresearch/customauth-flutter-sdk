# torus_direct

Torus CustomAuth SDK for Flutter applications.

## Usage 

Import the package:

```
import 'package:torus_direct/torus_direct.dart';
```

Set the verifier details for TorusDirect depending on the login you require:

```
 TorusDirect.setVerifierDetails(
        LoginType.installed.value,
        VerifierType.singleLogin.value,
        verifierName,
        <your-client-id>,
        LoginProvider.google.value,
        google,
        <your-redirect-url>);
```
Logins are dependent on verifier scripts/verifiers. There are other verifiers including singleIdVerifier, andAggregateVerifier, orAggregateVerifier and singleLogin of which you may need to use depending on your required logins. To get your application's verifier script setup, do reach out to hello@tor.us or to read more about verifiers do checkout the docs.

After setting your verifier, you can use TorusDirect to trigger a login:

```
torusLoginInfo = await TorusDirect.triggerLogin();
```

After this you're good to go, go to [Torus Developer](https://developer.tor.us) nad get your verifier spun up today!

