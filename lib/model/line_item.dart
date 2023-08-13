class LineItem {
  final String title;
  final double amount;

  LineItem(this.title, this.amount);

  LineItem.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        amount = double.parse(json['amount'].toString());
}
