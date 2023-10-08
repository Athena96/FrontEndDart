import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:moneyapp_flutter/model/asset.dart';

Future<List<Asset>> listAssets(String scenarioId) async {
  var getAssetsData = Amplify.API.get('/listAssets',
      apiName: 'Endpoint', queryParameters: {"scenarioId": scenarioId});
  var listAssetsResponse = await getAssetsData.response;
  var getScenarioDataJSON = listAssetsResponse.decodeBody();
  List<dynamic> scenarioDataJSON = jsonDecode(getScenarioDataJSON);
  List<Asset> assets =
      scenarioDataJSON.map((json) => Asset.fromJson(json)).toList();
  return assets;
}

Future<void> createAsset(String scenarioId, String ticker, double quantity,
    bool hasIndexData) async {
  var call = Amplify.API.post(
    '/addAsset',
    apiName: 'Endpoint',
    queryParameters: {"scenarioId": scenarioId},
    body: HttpPayload.json({
      'ticker': ticker,
      'quantity': quantity,
      'hasIndexData': hasIndexData ? 1 : 0
    }),
  );
  await call.response;
}

Future<void> updateAsset(String scenarioId, String scenarioDataId,
    String typeId, String ticker, double quantity, bool hasIndexData) async {
  var call = Amplify.API.put(
    '/updateAsset',
    apiName: 'Endpoint',
    queryParameters: {"scenarioId": scenarioId},
    body: HttpPayload.json({
      'scenarioDataId': scenarioDataId,
      'typeId': typeId,
      'ticker': ticker,
      'quantity': quantity,
      'hasIndexData': hasIndexData ? 1 : 0
    }),
  );
  await call.response;
}

Future<void> deleteAsset(
    String scenarioId, String scenarioDataId, String type) async {
  var call = Amplify.API.delete(
    '/deleteAsset',
    apiName: 'Endpoint',
    queryParameters: {"scenarioId": scenarioId},
    body: HttpPayload.json({
      'scenarioDataId': scenarioDataId,
      'type': type,
    }),
  );
  await call.response;
}
