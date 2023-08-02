import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
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
    var apiRequest = Amplify.API.post('/ping',
        body: HttpPayload.json({'num1': '2', 'num2': '3'}),
        apiName: 'Endpoint');
    var apiResponse = await apiRequest.response;
    var jsonString = apiResponse.decodeBody();
    Map<String, dynamic> jsonData = json.decode(jsonString);
    String resultValue = jsonData['result'];

    print('The value is: $resultValue');

    setState(() {
      result = resultValue;
    });
  }

  Future<void> signOut() async {
    print('signOut');
    await Amplify.Auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
