import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'amplifyconfiguration.dart';

//

import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureAmplify();
  runApp(MyApp());
}

Future<void> _configureAmplify() async {
  await Amplify.addPlugins([
    AmplifyAuthCognito(
      secureStorageFactory: AmplifySecureStorage.factoryFrom(
        macOSOptions:
            // ignore: invalid_use_of_visible_for_testing_member
            MacOSSecureStorageOptions(useDataProtection: false),
      ),
    ),
    AmplifyAPI()
  ]);
  try {
    await Amplify.configure(amplifyconfig);
  } on AmplifyAlreadyConfiguredException {
    print(
        "Tried to reconfigure Amplify; this can occur when your app restarts on Android.");
  } catch (e) {
    print("An error occurred while configuring Amplify: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Authenticator(
      child: MaterialApp(
        title: 'Money Tomorrow',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        builder: Authenticator.builder(),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? user;
  String? result;

  @override
  void initState() {
    super.initState();
    checkUser();
    fetchResult();
  }

  Future<void> checkUser() async {
    print("fetching current signed in user");
    var userObj = await Amplify.Auth.getCurrentUser();
    var signInDetails = userObj.signInDetails.toJson();
    var email = signInDetails['username'].toString();
    print("email: $email");
    setState(() {
      user = email;
    });
  }

  Future<void> fetchResult() async {
    print("fetching data from API");
    var apiRequest = Amplify.API.post('/router',
        body: HttpPayload.json({'key1': '2', 'key2': '3'}),
        apiName: 'Endpoint');
    var apiResponse = await apiRequest.response;
    print("response: ${apiResponse.decodeBody()}");
    setState(() {
      result = apiResponse.decodeBody();
    });
  }

  Future<void> signOut() async {
    print('signOut');
    await Amplify.Auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Money Tomorrow'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Hello, ${user ?? 'Anonymous'}!'),
            Text('2 + 3 = ${result ?? 'Unknown'}'),
            ElevatedButton(
              onPressed: () {
                signOut();
              },
              child: Text('Sign Out'),
            )
          ],
        ),
      ),
    );
  }
}
