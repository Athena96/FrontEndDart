import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:moneyapp_flutter/model/settings.dart';

class SettingsPage extends StatefulWidget {
  final String? scenarioId;
  final String? email;
  const SettingsPage(
      {super.key, required this.scenarioId, required this.email});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String email = "";
  String scenarioId = "";
  String scenarioDataId = "";

  TextEditingController scenarioDataIdController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  TextEditingController annualAssetReturnPercentController =
      TextEditingController();
  TextEditingController annualInflationPercentController =
      TextEditingController();
  DateTime selectedDate = DateTime.now();
  @override
  void initState() {
    super.initState();
    if (widget.scenarioId == null || widget.email == null) {
      throw Exception("scenarioId is required");
    }
    email = widget.email!;
    scenarioId = widget.scenarioId!;
    scenarioDataId = "$email#$scenarioId";
    getSettings();
  }

  Future<Settings> getSettings() async {
    // Get One Time Data
    var getOneTimeData = Amplify.API.get('/getSettings',
        apiName: 'Endpoint', queryParameters: {"scenarioId": this.scenarioId});
    var listOneTimeResponse = await getOneTimeData.response;
    var getScenarioOneTimeDataJSON = listOneTimeResponse.decodeBody();
    dynamic settingss = jsonDecode(getScenarioOneTimeDataJSON);

    // Settings
    Settings sett = Settings.fromJson(settingss);
    return sett;
  }

  @override
  void dispose() {
    scenarioDataIdController.dispose();
    typeController.dispose();
    annualAssetReturnPercentController.dispose();
    annualInflationPercentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: getSettings(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (snapshot.hasError) {
              return Scaffold(
                body: Center(
                    child: Center(child: Text('Error: ...'))),
              );
            } else if (!snapshot.hasData) {
              return Scaffold(
                body: Center(child: Center(child: Text('No Data'))),
              );
            } else {
              // Initialize the controllers and DateTime variable here
              Settings settings = snapshot.data!;
              scenarioDataIdController.text = settings.scenarioDataId;
              typeController.text = settings.type;
              annualAssetReturnPercentController.text =
                  settings.annualAssetReturnPercent.toString();
              annualInflationPercentController.text =
                  settings.annualInflationPercent.toString();
              selectedDate = settings.birthday;
              return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextField(
                          controller: typeController,
                          decoration: InputDecoration(labelText: 'Type'),
                        ),
                        TextField(
                          controller: annualAssetReturnPercentController,
                          decoration: InputDecoration(
                              labelText: 'Annual Asset Return Percent'),
                        ),
                        TextField(
                          controller: annualInflationPercentController,
                          decoration: InputDecoration(
                              labelText: 'Annual Inflation Percent'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            selectedDate = (await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2101),
                            ))!;

                            setState(() {});
                          },
                          child: Text('Pick Birthday'),
                        ),
                        if (selectedDate != null)
                          Text("Selected Date: $selectedDate"),
                      ]));
            }
          }),
    );
  }
}
