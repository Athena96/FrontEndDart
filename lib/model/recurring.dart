import 'charge_type.dart';
import 'line_item.dart';

class Recurring {
  final String id;
  final String simulationId;
  final String title;
  final String email;
  final int startAge;
  final int endAge;
  final ChargeType chargeType;
  final List<LineItem> lineItems;

  Recurring(this.id, this.simulationId, this.title, this.email, this.startAge,
      this.endAge, this.chargeType, this.lineItems);

  Recurring.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        simulationId = json['simulationId'],
        title = json['title'],
        email = json['email'],
        startAge = int.parse(json['startAge'].toString()),
        endAge = int.parse(json['endAge'].toString()),
        chargeType = json['chargeType'] == "EXPENSE"
            ? ChargeType.EXPENSE
            : ChargeType.INCOME,
        lineItems = (json['lineItems'] as List)
            .map((item) => LineItem.fromJson(item))
            .toList();

  @override
  String toString() {
    return 'Recurring(id: $id, simulationId: $simulationId, title: $title, email: $email, startAge: $startAge, endAge: $endAge, chargeType: $chargeType, lineItems: $lineItems)';
  }
}
