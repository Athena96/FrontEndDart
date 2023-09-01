import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:moneyapp_flutter/model/recurring.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:moneyapp_flutter/model/charge_type.dart';

class ContributionsPage extends StatefulWidget {
  const ContributionsPage({super.key});

  @override
  _ContributionsPageState createState() => _ContributionsPageState();
}

class _ContributionsPageState extends State<ContributionsPage> {
  List<Recurring> contributions = [];

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

    List<Recurring> contributions = recurrings
        .where((recurring) => recurring.chargeType == ChargeType.INCOME)
        .toList();

    setState(() {
      this.contributions = contributions;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (contributions.isEmpty) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        body: ListView(
          children: contributions.map((withdrawal) {
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
