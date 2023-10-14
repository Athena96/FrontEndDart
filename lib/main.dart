import 'dart:convert';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:moneyapp_flutter/model/scenario.dart';
import 'amplifyconfiguration.dart';

import 'package:flutter/material.dart';
import 'pages/AssetsPage.dart';
import 'pages/ContributionsPage.dart';
import 'pages/DashboardPage.dart';

import 'package:moneyapp_flutter/utils.dart';

import 'pages/SettingsPage.dart';
import 'pages/WithdrawalsPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureAmplify();
  runApp(MyApp());
}

Future<void> _configureAmplify() async {
  await Amplify.addPlugins([AmplifyAuthCognito(), AmplifyAPI()]);
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
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch:
              createMaterialColor(Color.fromARGB(255, 123, 206, 173)),
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
  var selectedIndex = 0;
  String? user;
  String? activeScenarioId;

  Future<void> fetchUserData() async {
    var userObj = await Amplify.Auth.getCurrentUser();
    var signInDetails = userObj.signInDetails.toJson();
    var email = signInDetails['username'].toString();
    if (email == null) {
      throw Exception("User not found");
    }

    setState(() {
      user = email;
    });
    // Call getActiveScenarioId after user is set
    getActiveScenarioId(user!).then((scenarioId) {
      setState(() {
        activeScenarioId = scenarioId;
      });
    });
  }

  Future<void> _signOut() async {
    try {
      await Amplify.Auth.signOut();
      // Redirect to login screen or perform other actions after signing out
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  Future<String> getActiveScenarioId(String email) async {
    var getScenarios = Amplify.API.get('/listScenarios',
        apiName: 'Endpoint', queryParameters: {"email": email});
    var listScenariosResponse = await getScenarios.response;
    var getScenarioDataJSON = listScenariosResponse.decodeBody();
    List<dynamic> scenarioDataJSON = jsonDecode(getScenarioDataJSON);
    // convert to list of Scenario objects
    List<Scenario> scenarios =
        scenarioDataJSON.map((json) => Scenario.fromJson(json)).toList();

    // get active scenario
    Scenario activeScenario = Scenario.getActiveScenario(scenarios);
    return activeScenario.scenarioId;
  }

  List<Widget> _widgetOptions() {
    if (user == null || activeScenarioId == null) {
      return [];
    }
    return <Widget>[
      DashboardPage(
        scenarioId: activeScenarioId,
        email: user,
      ),
      WithdrawalsPage(
        scenarioId: activeScenarioId,
        email: user,
      ),
      ContributionsPage(
        scenarioId: activeScenarioId,
        email: user,
      ),
      AssetsPage(scenarioId: activeScenarioId, email: user),
      SettingsPage(scenarioId: activeScenarioId, email: user),
    ];
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (this.user == null || this.activeScenarioId == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Money Tomorrow'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _signOut(),
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions()[selectedIndex],
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Text(
                user!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            ListTile(
              title: const Text('Dashboard'),
              selected: selectedIndex == 0,
              onTap: () {
                // Update the state of the app
                _onItemTapped(0);
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Withdrawals'),
              selected: selectedIndex == 1,
              onTap: () {
                // Update the state of the app
                _onItemTapped(1);
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Contributions'),
              selected: selectedIndex == 2,
              onTap: () {
                // Update the state of the app
                _onItemTapped(2);
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Assets'),
              selected: selectedIndex == 3,
              onTap: () {
                // Update the state of the app
                _onItemTapped(3);
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Settings'),
              selected: selectedIndex == 4,
              onTap: () {
                // Update the state of the app
                _onItemTapped(4);
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
