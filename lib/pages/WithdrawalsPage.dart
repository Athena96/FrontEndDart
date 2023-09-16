import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moneyapp_flutter/model/charge_type.dart';
import 'package:moneyapp_flutter/model/one_time.dart';
import 'package:moneyapp_flutter/model/recurring.dart';

class WithdrawalsPage extends StatefulWidget {
  const WithdrawalsPage({super.key});

  @override
  _WithdrawalsPageState createState() => _WithdrawalsPageState();
}

class _WithdrawalsPageState extends State<WithdrawalsPage> {
  List<Recurring> withdrawals = [];
  List<OneTime> oneTimeWithdrawals = [];

  bool isRecurringExpanded = false;
  bool isOneTimeExpanded = false;

  @override
  void initState() {
    super.initState();
    getRecurring();
    getOneTime();
  }

  Future<void> getRecurring() async {
    var getRecurringData = Amplify.API.get('/listRecurring',
        apiName: 'Endpoint', queryParameters: {"scenarioId": "s1"});
    var listRecurringResponse = await getRecurringData.response;
    var getScenarioDataJSON = listRecurringResponse.decodeBody();
    List<dynamic> scenarioDataJSON = jsonDecode(getScenarioDataJSON);

    // Assets
    List<Recurring> recurrings =
        scenarioDataJSON.map((json) => Recurring.fromJson(json)).toList();

    List<Recurring> withdrawals = recurrings
        .where((recurring) => recurring.chargeType == ChargeType.EXPENSE)
        .toList();
    setState(() {
      this.withdrawals = withdrawals;
    });
  }

  Future<void> getOneTime() async {
    // Get One Time Data
    var getOneTimeData = Amplify.API.get('/listOneTime',
        apiName: 'Endpoint', queryParameters: {"scenarioId": "s1"});
    var listOneTimeResponse = await getOneTimeData.response;
    var getScenarioOneTimeDataJSON = listOneTimeResponse.decodeBody();
    List<dynamic> scenarioOneTimeDataJSON =
        jsonDecode(getScenarioOneTimeDataJSON);

    // Assets
    List<OneTime> oneTimes =
        scenarioOneTimeDataJSON.map((json) => OneTime.fromJson(json)).toList();

    List<OneTime> oneTimesDta = oneTimes
        .where((oneTime) => oneTime.chargeType == ChargeType.EXPENSE)
        .toList();

    setState(() {
      this.oneTimeWithdrawals = oneTimesDta;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (withdrawals.isEmpty && oneTimeWithdrawals.isEmpty) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(30.0),
          children: [
            ExpansionPanelList(
              expandedHeaderPadding: EdgeInsets.all(8),
              expansionCallback: (int index, bool isExpanded) {
                setState(() {
                  if (index == 0) {
                    this.isRecurringExpanded = !this.isRecurringExpanded;
                  } else if (index == 1) {
                    this.isOneTimeExpanded = !this.isOneTimeExpanded;
                  }
                });
              },
              children: [
                ExpansionPanel(
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return ListTile(
                      title: Text('Recurring Withdrawals'),
                    );
                  },
                  body: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: withdrawals.length,
                    itemBuilder: (context, index) {
                      Recurring withdrawal = withdrawals[index];
                      String result = withdrawal.lineItems
                          .map((item) => item.toString())
                          .join(', ');
                      return Card(
                        child: ListTile(
                          title: Text(
                              '${withdrawal.title} (${withdrawal.startAge} - ${withdrawal.endAge}), ${result}'),
                          trailing: Icon(Icons.more_vert),
                        ),
                      );
                    },
                  ),
                  isExpanded: isRecurringExpanded,
                ),
                ExpansionPanel(
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return ListTile(
                      title: Text('One-Time Withdrawals'),
                    );
                  },
                  body: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: oneTimeWithdrawals.length,
                    itemBuilder: (context, index) {
                      OneTime oneTimeWithdrawal = oneTimeWithdrawals[index];
                      // Logic for building OneTime list items

                      return Card(
                        child: ListTile(
                          title: Text(
                              '${oneTimeWithdrawal.title} (${oneTimeWithdrawal.age}), \$${oneTimeWithdrawal.amount}'),
                          trailing: Icon(Icons.more_vert),
                        ),
                      );
                    },
                  ),
                  isExpanded: isOneTimeExpanded,
                ),
              ],
            ),
          ],
        ),
      );
    }
  }
}
