import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:moneyapp_flutter/data/price_point.dart';
import '../model/asset.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String? user;
  String? recurring;
  String? onetime;
  String? startingBalance;
  String? settings;

  @override
  void initState() {
    super.initState();
    checkUser();
    // fetchRecurring();
    // fetchOneTime();
    fetchAssets();
    // fetchSettings();
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

  Future<void> fetchRecurring() async {
    print("fetchRecurring data from API");

    var apiRequest = Amplify.API.get('/recurring', apiName: 'Endpoint');
    var apiResponse = await apiRequest.response;
    var jsonString = apiResponse.decodeBody();
    print("Recurring: ");
    print(jsonString);
    setState(() {
      recurring = jsonString;
    });
  }

  Future<void> fetchOneTime() async {
    print("fetchOneTime data from API");
    var apiRequest = Amplify.API.get('/onetime', apiName: 'Endpoint');
    var apiResponse = await apiRequest.response;
    var jsonString = apiResponse.decodeBody();
    print("One Time: ");
    print(jsonString);
    setState(() {
      onetime = jsonString;
    });
  }

  Future<void> fetchAssets() async {
    print("fetchAssets data from API");

    var apiRequest = Amplify.API.get('/assets', apiName: 'Endpoint');
    var apiResponse = await apiRequest.response;
    var jsonString = apiResponse.decodeBody();

    List<dynamic> jsonList = jsonDecode(jsonString);
    List<Asset> assets = jsonList.map((json) => Asset.fromJson(json)).toList();
    double totalValue = Asset.computeTotalAssetValue(assets);
    var formatter = NumberFormat('#,##0.00', 'en_US');
    String formattedTotalValue = formatter.format(totalValue);
    String totalValueStr = '\$$formattedTotalValue';
    print(totalValueStr);
    print(assets);
    setState(() {
      startingBalance = totalValueStr;
    });
  }

  Future<void> fetchSettings() async {
    print("fetchSettings data from API");
    var apiRequest = Amplify.API.get('/settings', apiName: 'Endpoint');
    var apiResponse = await apiRequest.response;
    var jsonString = apiResponse.decodeBody();
    print("Settings: ");
    print(jsonString);
    setState(() {
      settings = jsonString;
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
            Text(''),
            // Text('Recurring: ${recurring ?? 'Unknown'}'),
            // Text(''),
            Text('Starting Balance: ${startingBalance ?? '...'}'),
            // Text(''),
            // Text('One Time: ${onetime ?? 'Unknown'}'),
            // Text(''),
            // Text('Settings: ${settings ?? 'Unknown'}'),
            Text(''),
            AspectRatio(
              aspectRatio: 2,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: pricePoints
                          .map((point) => FlSpot(point.x, point.y))
                          .toList(),
                      isCurved: false,
                      // dotData: FlDotData(
                      //   show: false,
                      // ),
                    ),
                  ],
                ),
              ),
            ),
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
