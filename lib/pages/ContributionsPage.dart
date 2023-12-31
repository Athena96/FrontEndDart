import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:moneyapp_flutter/model/one_time.dart';
import 'package:moneyapp_flutter/model/recurring.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:moneyapp_flutter/model/charge_type.dart';

class ContributionsPage extends StatefulWidget {
  final String scenarioId;
  final String email;
  const ContributionsPage(
      {super.key, required this.scenarioId, required this.email});

  @override
  _ContributionsPageState createState() => _ContributionsPageState();
}

class _ContributionsPageState extends State<ContributionsPage> {
  String email = "";
  String scenarioId = "";
  String scenarioDataId = "";

  List<Recurring>? contributions;
  List<OneTime>? oneTimeContributions;

  bool isRecurringExpanded = false;
  bool isOneTimeExpanded = false;

  @override
  void initState() {
    super.initState();
    // if (widget.scenarioId == null || widget.email == null) {
    //   throw Exception("scenarioId is required");
    // }
    email = widget.email;
    scenarioId = widget.scenarioId;
    scenarioDataId = "$email#$scenarioId";
    getRecurring();
    getOneTime();
  }

  Future<void> getRecurring() async {
    var getRecurringData = Amplify.API.get('/listRecurring',
        apiName: 'Endpoint', queryParameters: {"scenarioId": this.scenarioId});
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

  Future<void> getOneTime() async {
    // Get One Time Data
    var getOneTimeData = Amplify.API.get('/listOneTime',
        apiName: 'Endpoint', queryParameters: {"scenarioId": this.scenarioId});
    var listOneTimeResponse = await getOneTimeData.response;
    var getScenarioOneTimeDataJSON = listOneTimeResponse.decodeBody();
    List<dynamic> scenarioOneTimeDataJSON =
        jsonDecode(getScenarioOneTimeDataJSON);

    // Assets
    List<OneTime> oneTimes =
        scenarioOneTimeDataJSON.map((json) => OneTime.fromJson(json)).toList();

    List<OneTime> oneTimesDta = oneTimes
        .where((oneTime) => oneTime.chargeType == ChargeType.INCOME)
        .toList();

    setState(() {
      this.oneTimeContributions = oneTimesDta;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (contributions != null && oneTimeContributions != null) {
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
                      title: Text('Recurring Contributions'),
                    );
                  },
                  body: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: contributions!.length,
                    itemBuilder: (context, index) {
                      Recurring contribution = contributions![index];
                      // Existing logic for building Recurring list items

                      String result = contribution.lineItems
                          .map((item) => item.toString())
                          .join(', ');
                      return Card(
                        child: ListTile(
                          title: Text(
                              '${contribution.title} (${contribution.startAge} - ${contribution.endAge}), ${result}'),
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
                      title: Text('One-Time Contributions'),
                    );
                  },
                  body: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: oneTimeContributions!.length,
                    itemBuilder: (context, index) {
                      OneTime oneTimeContribution =
                          oneTimeContributions![index];

                      return Card(
                        child: ListTile(
                          title: Text(
                              '${oneTimeContribution.title} (${oneTimeContribution.age}), \$${oneTimeContribution.amount}'),
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
    } else {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}
