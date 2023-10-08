import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:intl/intl.dart';
import 'package:moneyapp_flutter/model/asset.dart';

class AssetsPage extends StatefulWidget {
  const AssetsPage({super.key});

  @override
  _AssetsPageState createState() => _AssetsPageState();
}

class _AssetsPageState extends State<AssetsPage> {
  List<Asset> assets = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    var getAssetsData = Amplify.API.get('/listAssets',
        apiName: 'Endpoint', queryParameters: {"scenarioId": "s1"});
    var listAssetsResponse = await getAssetsData.response;
    var getScenarioDataJSON = listAssetsResponse.decodeBody();
    List<dynamic> scenarioDataJSON = jsonDecode(getScenarioDataJSON);

    // Assets
    List<Asset> assets =
        scenarioDataJSON.map((json) => Asset.fromJson(json)).toList();

    setState(() {
      this.assets = assets;
    });
  }

  Future<void> showAddAssetDialog(BuildContext context, bool isAdd, int? idx,
      {Asset? assetToEdit}) async {
    TextEditingController tickerController =
        TextEditingController(text: assetToEdit?.ticker ?? '');
    TextEditingController quantityController =
        TextEditingController(text: assetToEdit?.quantity.toString() ?? '');
    bool hasIndexData = assetToEdit?.hasIndexData == 1 ? true : false;
    String title = isAdd ? 'Add Asset' : 'Edit Asset';
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(title),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: tickerController,
                    decoration: InputDecoration(labelText: 'Ticker'),
                  ),
                  TextField(
                    controller: quantityController,
                    decoration: InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                  ),
                  CheckboxListTile(
                    title: Text('Has Index Data'),
                    value: hasIndexData,
                    onChanged: (bool? value) {
                      setState(() {
                        hasIndexData = value ?? false;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    isAdd
                        ? addAsset(
                            tickerController.text,
                            double.parse(quantityController.text),
                            hasIndexData,
                          )
                        : editAsset(
                            assetToEdit!,
                            tickerController.text,
                            double.parse(quantityController.text),
                            hasIndexData,
                            idx!);
                    Navigator.pop(context);
                  },
                  child: Text(title),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String getID() {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String timestampString = timestamp.toString();
    return timestampString;
  }

  Future<void> addAsset(
      String ticker, double quantity, bool hasIndexData) async {
    // Dummy Asset for demonstration
    String scenarioDataId = "s1";
    String assetId = "jaredfranzone@gmail.com#${scenarioDataId}";
    Asset newAsset = Asset(assetId, scenarioDataId, 'Assets#${getID()}', ticker,
        quantity, 1.0, hasIndexData ? 1 : 0);

    // // Add to local state
    setState(() {
      assets.add(newAsset);
    });

    // // Make API call to add to backend
    var call = Amplify.API.post(
      '/addAsset',
      apiName: 'Endpoint',
      queryParameters: {"scenarioId": "s1"},
      body: HttpPayload.json({
        'ticker': ticker,
        'quantity': quantity,
        'hasIndexData': hasIndexData ? 1 : 0
      }),
    );
    await call.response;
  }

  Future<void> editAsset(Asset assetToEdit, String ticker, double quantity,
      bool hasIndexData, int idx) async {
    Asset a = assets[idx];
    a.ticker = ticker;
    a.quantity = quantity;
    a.hasIndexData = hasIndexData ? 1 : 0;
    setState(() {
      assets[idx] = a;
    });

    String scenarioDataId = "jaredfranzone@gmail.com#s1";
    // // Make API call to add to backend
    var call = Amplify.API.put(
      '/updateAsset',
      apiName: 'Endpoint',
      queryParameters: {"scenarioId": "s1"},
      body: HttpPayload.json({
        'scenarioDataId': scenarioDataId,
        'typeId': assetToEdit.id,
        'ticker': ticker,
        'quantity': quantity,
        'hasIndexData': hasIndexData ? 1 : 0
      }),
    );
    await call.response;
  }

  Future<void> deleteAsset(Asset asset) async {
    String fullType = "${asset.type}#${asset.id}";
    setState(() {
      assets.remove(asset);
    });

    // // Make API call to add to backend
    var call = Amplify.API.delete(
      '/deleteAsset',
      apiName: 'Endpoint',
      queryParameters: {"scenarioId": "s1"},
      body: HttpPayload.json({
        'scenarioDataId': asset.scenarioDataId,
        'type': fullType,
      }),
    );
    await call.response;
  }

  List<Text> getAssetText(List<Asset> assets) {
    List<Text> assetText = [];
    for (var asset in assets) {
      assetText.add(Text('${asset.toString()}'));
    }
    return assetText;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity, // makes the button expand width-wise
              child: ElevatedButton(
                onPressed: () => showAddAssetDialog(context, true, null),
                child: Text("Add Asset"),
              ),
            ),
          ),
          Expanded(
            child: assets.isEmpty
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView(
                    children: assets.asMap().entries.map((entry) {
                      int idx = entry.key;
                      Asset item = entry.value;
                      var formatter = NumberFormat('#,##0.00', 'en_US');
                      String formattedTotalValue = formatter.format(item.price);
                      String totalValueStr = '\$$formattedTotalValue';
                      return Card(
                          child: ListTile(
                        title: Text(
                            '${item.ticker} (price: ${totalValueStr}, quantity: ${item.quantity})'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (String result) {
                            if (result == 'Edit') {
                              showAddAssetDialog(context, false, idx,
                                  assetToEdit: item);
                            } else if (result == 'Delete') {
                              deleteAsset(item);
                            }
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'Edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'Delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ));
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
