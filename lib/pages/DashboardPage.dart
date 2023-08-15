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

  MonteCarloServiceRequest getMonteCarloRequest(List<OneTime> oneTimes,
      List<Recurring> recurrings, List<Asset> assets, Settings settings) {
    double mean =
        (settings.annualAssetReturnPercent - settings.annualInflationPercent);
    int currAge = calculateAge(settings.birthday);
    int period = endAge - currAge;
    DateTime now = DateTime.now();
    double startingBalance = Asset.computeTotalAssetValue(assets);

    return MonteCarloServiceRequest(
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
  }

  Future<void> getData() async {
    var recurringRequest =
        Amplify.API.get('/recurring', apiName: 'Endpoint').response;
    var oneTimeRequest =
        Amplify.API.get('/onetime', apiName: 'Endpoint').response;
    var assetsRequest =
        Amplify.API.get('/assets', apiName: 'Endpoint').response;
    var settingsRequest =
        Amplify.API.get('/settings', apiName: 'Endpoint').response;
    final responses = await Future.wait(
        [recurringRequest, oneTimeRequest, assetsRequest, settingsRequest]);

    // Recurring request
    List<dynamic> recurringJson = jsonDecode(responses[0].decodeBody());
    List<Recurring> recurrings = recurringJson.map((json) {
      return Recurring.fromJson(json);
    }).toList();

    // One Time request
    List<dynamic> oneTimeJson = jsonDecode(responses[1].decodeBody());
    List<OneTime> oneTimes =
        oneTimeJson.map((json) => OneTime.fromJson(json)).toList();

    // Assets request
    List<dynamic> assetJson = jsonDecode(responses[2].decodeBody());
    List<Asset> assets = assetJson.map((json) => Asset.fromJson(json)).toList();
    double totalValue = Asset.computeTotalAssetValue(assets);
    var formatter = NumberFormat('#,##0.00', 'en_US');
    String formattedTotalValue = formatter.format(totalValue);
    String totalValueStr = '\$$formattedTotalValue';
    setState(() {
      startingBalanceStr = totalValueStr;
    });

    // Settings request
    List<dynamic> settingJson = jsonDecode(responses[3].decodeBody());
    List<Settings> allsettings =
        settingJson.map((json) => Settings.fromJson(json)).toList();
    Settings settings = allsettings[0];

    MonteCarloService monteCarloService =
        MonteCarloService(numberOfSimulations: 1000);
    MonteCarloServiceRequest request =
        getMonteCarloRequest(oneTimes, recurrings, assets, settings);
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
