import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:intl/intl.dart';
import 'package:moneyapp_flutter/model/asset.dart';
import 'package:moneyapp_flutter/services/asset_service.dart';

class AssetsPage extends StatefulWidget {
  final String? scenarioId;
  final String? email;
  const AssetsPage({Key? key, required this.scenarioId, required this.email})
      : super(key: key);

  @override
  _AssetsPageState createState() => _AssetsPageState();
}

class _AssetsPageState extends State<AssetsPage> {
  String email = "";
  String scenarioId = "";
  String scenarioDataId = "";

  List<Asset>? assets;

  @override
  void initState() {
    super.initState();
    if (widget.scenarioId == null || widget.email == null) {
      throw Exception("scenarioId is required");
    }
    email = widget.email!;
    scenarioId = widget.scenarioId!;
    scenarioDataId = "$email#$scenarioId";
    fetchAssets(scenarioId);
  }

  Future<void> fetchAssets(String scenarioId) async {
    List<Asset> assets = await listAssets(scenarioId);
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
                            scenarioId,
                            tickerController.text,
                            double.parse(quantityController.text),
                            hasIndexData,
                          )
                        : editAsset(
                            scenarioId,
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

  Future<void> addAsset(String scenarioId, String ticker, double quantity,
      bool hasIndexData) async {
    String assetId = getID();
    String type = "Assets#$assetId";
    Asset newAsset = Asset(assetId, scenarioDataId, type, ticker, quantity, 1.0,
        hasIndexData ? 1 : 0);
    setState(() {
      assets!.add(newAsset);
    });

    await createAsset(scenarioId, ticker, quantity, hasIndexData);
  }

  Future<void> editAsset(String scenarioId, Asset assetToEdit, String ticker,
      double quantity, bool hasIndexData, int idx) async {
    Asset a = assets![idx];
    a.ticker = ticker;
    a.quantity = quantity;
    a.hasIndexData = hasIndexData ? 1 : 0;
    setState(() {
      assets![idx] = a;
    });

    String type = "Assets#${assetToEdit.id}";
    await updateAsset(
        scenarioId, scenarioDataId, type, ticker, quantity, hasIndexData);
  }

  Future<void> removeAsset(String scenarioId, Asset asset) async {
    setState(() {
      assets!.remove(asset);
    });

    String type = "Assets#${asset.id}";
    await deleteAsset(scenarioId, scenarioDataId, type);
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
            child: assets == null
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView(
                    children: assets!.asMap().entries.map((entry) {
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
                              removeAsset(scenarioId, item);
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
