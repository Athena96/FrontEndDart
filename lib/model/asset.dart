class Asset {
  final String scenarioDataId;
  final String type;
  final String id;
  final String ticker;
  final double quantity;
  final double price;
  final int hasIndexData;

  Asset(this.id, this.scenarioDataId, this.type, this.ticker, this.quantity,
      this.price, this.hasIndexData);

  // Named constructor that initializes the object from a JSON map
  Asset.fromJson(Map<String, dynamic> json)
      : scenarioDataId = json['scenarioDataId'],
        type = json['type'].split('#').first,
        id = json['id'],
        ticker = json['ticker'],
        quantity = double.parse(json['quantity'].toString()),
        price = double.parse(json['price'].toString()),
        hasIndexData = int.parse(json['hasIndexData'].toString());

  static double computeTotalAssetValue(List<Asset> assets) {
    var total = 0.0;
    for (var asset in assets) {
      if (asset.hasIndexData == 1) {
        total += asset.quantity * asset.price;
      } else {
        total += asset.price;
      }
    }
    return total;
  }

  @override
  String toString() {
    return 'Asset(id: $id, simulationId: $scenarioDataId, type: $type, ticker: $ticker, quantity: $quantity, price: $price, hasIndexData: $hasIndexData)';
  }
}
