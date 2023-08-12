
class Asset {
  final String id;
  final String simulationId;
  final String email;
  final String ticker;
  final double quantity;
  final double price;
  final int hasIndexData;

  Asset(this.id, this.simulationId, this.email, this.ticker, this.quantity, this.price, this.hasIndexData);

  // Named constructor that initializes the object from a JSON map
  Asset.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        simulationId = json['simulationId'],
        email = json['email'],
        ticker = json['ticker'],
        quantity = double.parse(json['quantity'].toString()),
        price = double.parse(json['price'].toString()),
        hasIndexData = int.parse(json['hasIndexData'].toString());


  static double computeTotalAssetValue(List<Asset> assets) {
    return assets.fold(0.0, (sum, asset) => sum + (asset.quantity * asset.price));
  }

  @override
  String toString() {
    return 'Asset(id: $id, simulationId: $simulationId, email: $email, ticker: $ticker, quantity: $quantity, price: $price, hasIndexData: $hasIndexData)';
  }
}
