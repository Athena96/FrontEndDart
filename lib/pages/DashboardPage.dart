import 'dart:convert';
import 'dart:math';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:yahoo_finance_data_reader/yahoo_finance_data_reader.dart';

import '../model/asset.dart';
import '../model/stock.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String? user;
  String? recurring;
  String? onetime;
  String? assetsStr;
  String? settings;

  @override
  void initState() {
    super.initState();
    checkUser();
    fetchRecurring();
    fetchOneTime();
    fetchAssets();
    fetchSettings();
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

    // Converting the list of JSON maps to a list of Asset objects
    List<Stock> stocks = jsonList.map((json) => Stock.fromJson(json)).toList();

    List<Asset> assets = [];
    for (Stock stock in stocks) {
      try {
        print('Stock:  ${stock.ticker}');
        YahooFinanceResponse response = await YahooFinanceDailyReader()
            .getDailyDTOs(stock.ticker,
                startDate: DateTime.now().subtract(Duration(days: 1)));

        for (YahooFinanceCandleData stockData in response.candlesData) {
          print(stockData);
          var closePrice = stockData.close;
          var asset = Asset.from(stock, closePrice);
          assets.add(asset);
        }
      } catch (e) {
        print('Error');
        print(e);
      }
    }

    String totalValue = Asset.computeTotalAssetValue(assets).toStringAsFixed(2);
    String totalValueStr = 'Total Value: \$$totalValue';
    print(totalValueStr);
    print(assets);
    // List<String> assetStrings = assets.map((asset) => asset.toString()).toList();
    // You can now use the assetStrings list, or join them into a single string
    // String combinedString = assetStrings.join('\n');
    setState(() {
      assetsStr = totalValueStr;
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
            Text('Recurring: ${recurring ?? 'Unknown'}'),
            Text(''),
            Text('Assets: ${assetsStr ?? 'Unknown'}'),
            Text(''),
            Text('One Time: ${onetime ?? 'Unknown'}'),
            Text(''),
            Text('Settings: ${settings ?? 'Unknown'}'),
            Text(''),
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
