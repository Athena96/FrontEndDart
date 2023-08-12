import 'stock.dart';

class Asset {
  final String id;
  final String simulationId;
  final String email;
  final double value;

  Asset(this.id, this.simulationId, this.email, this.value);

  // Named constructor that initializes the object from a JSON map
  Asset.from(Stock stock, double price)
      : id = stock.id,
        simulationId = stock.simulationId,
        email = stock.email,
        value = stock.quantity * price;

  static double computeTotalAssetValue(List<Asset> assets) {
    return assets.fold(0.0, (sum, asset) => sum + asset.value);
  }

  @override
  String toString() {
    return 'Asset(id: $id, simulationId: $simulationId, email: $email, value: $value)';
  }
}
