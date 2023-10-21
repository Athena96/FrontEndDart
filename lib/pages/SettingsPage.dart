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
    fetchInitialValues();
  }

  Future<void> fetchInitialValues() async {
    // Get One Time Data
    var getOneTimeData = Amplify.API.get('/getSettings',
        apiName: 'Endpoint', queryParameters: {"scenarioId": this.scenarioId});
    var listOneTimeResponse = await getOneTimeData.response;
    var getScenarioOneTimeDataJSON = listOneTimeResponse.decodeBody();
    dynamic settingss = jsonDecode(getScenarioOneTimeDataJSON);

    // Settings
    Settings sett = Settings.fromJson(settingss);
    setState(() {
      annualAssetReturnPercentController.text =
          sett.annualAssetReturnPercent.toString();
      annualInflationPercentController.text =
          sett.annualInflationPercent.toString();
      selectedDate = sett.birthday;
    });

    // final response = await http.get(Uri.parse('https://api.example.com/settings'));
    // if (response.statusCode == 200) {
    //   final Map<String, dynamic> data = json.decode(response.body);
    //   setState(() {
    //     annualAssetReturnPercentController.text = data['annualAssetReturnPercent'].toString();
    //     annualInflationPercentController.text = data['annualInflationPercent'].toString();
    //     selectedDate = DateTime.parse(data['birthday']);
    //   });
    // } else {
    //   throw Exception('Failed to load initial values');
    // }
  }

  @override
  void dispose() {
    annualAssetReturnPercentController.dispose();
    annualInflationPercentController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900, 1),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> updateSettings() async {
    var call = Amplify.API.put(
      '/updateSettings',
      apiName: 'Endpoint',
      queryParameters: {"scenarioId": scenarioId},
      body: HttpPayload.json({
        'birthday': selectedDate.toIso8601String(),
        'annualAssetReturnPercent': annualAssetReturnPercentController.text,
        'annualInflationPercent': annualInflationPercentController.text,
      }),
    );
    await call.response;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      body: annualAssetReturnPercentController.text.isEmpty &&
              annualInflationPercentController.text.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: isDesktop
                      ? const EdgeInsets.symmetric(horizontal: 200.0)
                      : const EdgeInsets.all(0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  "${selectedDate.toLocal()}".split(' ')[0],
                                ),
                                ElevatedButton(
                                  onPressed: () => _selectDate(context),
                                  child: Text("Select Birthday"),
                                ),
                              ],
                            ),
                            TextFormField(
                              controller: annualAssetReturnPercentController,
                              decoration: InputDecoration(
                                  labelText: 'Annual Asset Return Percent'),
                              keyboardType: TextInputType.number,
                            ),
                            TextFormField(
                              controller: annualInflationPercentController,
                              decoration: InputDecoration(
                                  labelText: 'Annual Inflation Percent'),
                              keyboardType: TextInputType.number,
                            ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed:
                                  updateSettings, // Updated to call updateSettings
                              child: Text('Update Settings'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
