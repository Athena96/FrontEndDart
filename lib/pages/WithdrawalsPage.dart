import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moneyapp_flutter/model/charge_type.dart';
import 'package:moneyapp_flutter/model/recurring.dart';

class WithdrawalsPage extends StatefulWidget {
  const WithdrawalsPage({super.key});

  @override
  _WithdrawalsPageState createState() => _WithdrawalsPageState();
}

class _WithdrawalsPageState extends State<WithdrawalsPage> {
  List<Recurring> withdrawals = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
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

  @override
  Widget build(BuildContext context) {
    if (withdrawals.isEmpty) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        body: ListView(
          children: withdrawals.map((withdrawal) {
            String result =
                withdrawal.lineItems.map((item) => item.toString()).join(', ');
            return Card(
              child: ListTile(
                title: Text(
                    '${withdrawal.title} (${withdrawal.startAge} - ${withdrawal.endAge}), ${result}'),
                trailing: Icon(Icons.more_vert),
              ),
            );
          }).toList(),
        ),
      );
    }
  }
}
