class Stock {
  final String id;
  final String simulationId;
  final String email;
  final String ticker;
  final double quantity;
  final int hasIndexData;

  Stock(this.id, this.simulationId, this.email, this.ticker, this.quantity,
      this.hasIndexData);

  // Named constructor that initializes the object from a JSON map
  Stock.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        simulationId = json['simulationId'],
        email = json['email'],
        ticker = json['ticker'],
        quantity = double.parse(json['quantity'].toString()),
        hasIndexData = int.parse(json['hasIndexData'].toString());

  @override
  String toString() {
    return 'Stock(id: $id, simulationId: $simulationId, email: $email, ticker: $ticker, quantity: $quantity, hasIndexData: $hasIndexData)';
  }
}
