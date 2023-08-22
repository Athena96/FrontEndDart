import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = DashboardPage();
        break;
      case 1:
        page = WithdrawalsPage();
        break;
      case 2:
        page = ContributionsPage();
        break;
      case 3:
        page = AssetsPage();
        break;
      case 4:
        page = SettingsPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.leaderboard),
                    label: Text('Dashboard'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.remove_circle_outline),
                    label: Text('Withdrawals'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.add_circle_outline),
                    label: Text('Contributions'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.local_atm),
                    label: Text('Assets'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings),
                    label: Text('Settings'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Scaffold(
                    appBar: AppBar(
                      title: Text('Money Tomorrow'),
                      actions: [
                        IconButton(
                          icon: Icon(Icons.logout),
                          onPressed: () async {
                            await Amplify.Auth.signOut();
                          },
                        ),
                      ],
                    ),
                    body: page),
              ),
            ),
          ],
        ),
      );
    });
  }
}
