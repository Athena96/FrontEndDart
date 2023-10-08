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
  Settings? settings;
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
    // Use Simulation to get ScenarioData
    DateTime getScenarioDatastartTime = DateTime.now();
    var getScenarioDataRequest =
        Amplify.API.get('/getScenarioData', apiName: 'Endpoint');
    var getScenarioDataResponse = await getScenarioDataRequest.response;
    DateTime getScenarioDataendTime = DateTime.now();
    int getScenarioDataduration = getScenarioDataendTime
        .difference(getScenarioDatastartTime)
        .inMilliseconds;
    print('getScenarioData Duration: $getScenarioDataduration');
    var getScenarioDataJSON = getScenarioDataResponse.decodeBody();
    dynamic scenarioDataJSON = jsonDecode(getScenarioDataJSON);

    // Assets
    List<dynamic> assetJson = scenarioDataJSON['assets'];
    List<Asset> assets = assetJson.map((json) => Asset.fromJson(json)).toList();

    // One Time
    List<dynamic> onetimesJson = scenarioDataJSON['oneTimes'];
    List<OneTime> onetimes =
        onetimesJson.map((json) => OneTime.fromJson(json)).toList();

    // Recurrings
    List<dynamic> recurringsJson = scenarioDataJSON['recurrings'];
    List<Recurring> recurrings =
        recurringsJson.map((json) => Recurring.fromJson(json)).toList();

    // Settings
    dynamic sett = scenarioDataJSON['settings'];
    Settings settings = Settings.fromJson(sett);
    setState(() {
      this.settings = settings;
    });
    // comput starting balance
    double totalValue = Asset.computeTotalAssetValue(assets);
    var formatter = NumberFormat('#,##0.00', 'en_US');
    String formattedTotalValue = formatter.format(totalValue);
    String totalValueStr = '\$$formattedTotalValue';
    setState(() {
      startingBalanceStr = totalValueStr;
    });

    MonteCarloService monteCarloService =
        MonteCarloService(numberOfSimulations: 1000);
    MonteCarloServiceRequest request =
        getMonteCarloRequest(onetimes, recurrings, assets, settings);
    MonteCarloServiceResponse response =
        monteCarloService.getMonteCarloResponse(request: request);
    List<PricePoint> newlin = response.getMedian();
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
    if (successPercent != null && settings != null) {
      var age = calculateAge(settings!.birthday);

      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Align the card to the left
              Align(
                alignment: Alignment.centerLeft,
                child: Card(
                  elevation: 5,
                  margin: EdgeInsets.all(15),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Success: ${successPercent}%',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Starting Balance: ${startingBalanceStr ?? '...'}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              medinaLine.isNotEmpty
                  ? AspectRatio(
                      aspectRatio: 2,
                      child: LineChart(
                        LineChartData(
                          minY: 0.0,
                          lineBarsData: [
                            LineChartBarData(
                              spots: medinaLine
                                  .map(
                                      (point) => FlSpot(point.x + age, point.y))
                                  .toList(),
                              isCurved: false,
                            ),
                          ],
                        ),
                      ),
                    )
                  : Text('.....')
            ],
          ),
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
