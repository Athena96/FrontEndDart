import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:moneyapp_flutter/data/price_point.dart';
import 'package:moneyapp_flutter/model/Recurring.dart';
import 'package:moneyapp_flutter/model/settings.dart';
import '../constants.dart';
import '../model/asset.dart';
import 'package:intl/intl.dart';

import '../model/one_time.dart';
import '../services/monte_carlo_service.dart';
import '../utils.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String? user;
  String? startingBalanceStr;
  String? successPercent;
  List<PricePoint> medinaLine = [];

  @override
  void initState() {
    super.initState();
    checkUser();
    getData();
  }

  Future<void> getData() async {
    List<Recurring> recurrings = await fetchRecurring();
    List<OneTime> oneTimes = await fetchOneTime();
    double startingBalance = await fetchAssets();
    Settings settings = await fetchSettings();
    double mean =
        (settings.annualAssetReturnPercent - settings.annualInflationPercent);
    MonteCarloService monteCarloService =
        MonteCarloService(numberOfSimulations: 1000);
    int currAge = calculateAge(settings.birthday);
    int period = endAge - currAge;
    DateTime now = DateTime.now();

    MonteCarloServiceRequest request = MonteCarloServiceRequest(
        oneTimes: oneTimes,
        recurrings: recurrings,
        period: period,
        startingBalance: startingBalance,
        currentDate: now,
        currentAge: currAge,
        mean: mean,
        variance: sp500Variance,
        fees: FEES,
        numberOfSimulations: 1000);
    MonteCarloServiceResponse response =
        monteCarloService.getMonteCarloResponse(request: request);
    List<PricePoint> newlin = response
        .getMedian()
        .map((e) => e.y > 10000000
            ? PricePoint(x: e.x, y: 10000000)
            : PricePoint(x: e.x, y: e.y))
        .toList();

    setState(() {
      successPercent = response.getSuccessPercent().toStringAsFixed(2);
      medinaLine = newlin;
    });
  }

  Future<void> checkUser() async {
    var userObj = await Amplify.Auth.getCurrentUser();
    var signInDetails = userObj.signInDetails.toJson();
    var email = signInDetails['username'].toString();
    setState(() {
      user = email;
    });
  }

  Future<List<Recurring>> fetchRecurring() async {
    var apiRequest = Amplify.API.get('/recurring', apiName: 'Endpoint');
    var apiResponse = await apiRequest.response;
    var jsonString = apiResponse.decodeBody();
    List<dynamic> jsonList = jsonDecode(jsonString);

    List<Recurring> recurrings = jsonList.map((json) {
      return Recurring.fromJson(json);
    }).toList();
    return recurrings;
  }

  Future<List<OneTime>> fetchOneTime() async {
    var apiRequest = Amplify.API.get('/onetime', apiName: 'Endpoint');
    var apiResponse = await apiRequest.response;
    var jsonString = apiResponse.decodeBody();
    List<dynamic> jsonList = jsonDecode(jsonString);
    List<OneTime> onetimes =
        jsonList.map((json) => OneTime.fromJson(json)).toList();
    return onetimes;
  }

  Future<double> fetchAssets() async {
    var apiRequest = Amplify.API.get('/assets', apiName: 'Endpoint');
    var apiResponse = await apiRequest.response;
    var jsonString = apiResponse.decodeBody();

    List<dynamic> jsonList = jsonDecode(jsonString);
    List<Asset> assets = jsonList.map((json) => Asset.fromJson(json)).toList();
    double totalValue = Asset.computeTotalAssetValue(assets);
    var formatter = NumberFormat('#,##0.00', 'en_US');
    String formattedTotalValue = formatter.format(totalValue);
    String totalValueStr = '\$$formattedTotalValue';
    setState(() {
      startingBalanceStr = totalValueStr;
    });
    return totalValue;
  }

  Future<Settings> fetchSettings() async {
    var apiRequest = Amplify.API.get('/settings', apiName: 'Endpoint');
    var apiResponse = await apiRequest.response;
    var jsonString = apiResponse.decodeBody();
    List<dynamic> jsonList = jsonDecode(jsonString);
    List<Settings> settings =
        jsonList.map((json) => Settings.fromJson(json)).toList();
    return settings[0];
  }

  Future<void> signOut() async {
    await Amplify.Auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    if (successPercent != null) {
      return Scaffold(
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('Hello, ${user ?? 'Anonymous'}!'),
            Text(''),
            Text('Starting Balance: ${startingBalanceStr ?? '...'}'),
            Text('Success: ${successPercent}'),
            Text(''),
            medinaLine.isNotEmpty
                ? AspectRatio(
                    aspectRatio: 2,
                    child: LineChart(
                      LineChartData(
                        maxY: 10000000.0,
                        minY: 0.0,
                        lineBarsData: [
                          LineChartBarData(
                            spots: medinaLine
                                .map((point) => FlSpot(point.x, point.y))
                                .toList(),
                            isCurved: false,
                          ),
                        ],
                      ),
                    ),
                  )
                : Text('.....'),
            ElevatedButton(
              onPressed: () {
                signOut();
              },
              child: Text('Sign Out'),
            )
          ]),
        ),
      );
    } else {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}
