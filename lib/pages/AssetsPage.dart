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

  List<Text> getAssetText(List<Asset> assets) {
    List<Text> assetText = [];
    for (var asset in assets) {
      assetText.add(Text('${asset.toString()}'));
    }
    return assetText;
  }

  @override
  Widget build(BuildContext context) {
    if (assets.isEmpty) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        body: ListView(
          children: assets.map((item) {
            var formatter = NumberFormat('#,##0.00', 'en_US');
            String formattedTotalValue = formatter.format(item.price);
            String totalValueStr = '\$$formattedTotalValue';
            return Card(
              child: ListTile(
                title: Text(
                    '${item.ticker} (price: ${totalValueStr}, quantity: ${item.quantity})'),
                trailing: Icon(Icons.more_vert),
              ),
            );
          }).toList(),
        ),
      );
    }
  }
}
