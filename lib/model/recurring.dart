import 'charge_type.dart';
import 'line_item.dart';

class Recurring {
  final String scenarioDataId;
  final String type;
  final String id;
  final String title;
  final int startAge;
  final int endAge;
  final ChargeType chargeType;
  final List<LineItem> lineItems;

  Recurring(this.id, this.scenarioDataId, this.type, this.title, this.startAge,
      this.endAge, this.chargeType, this.lineItems);

  Recurring.fromJson(Map<String, dynamic> json)
      : scenarioDataId = json['scenarioDataId'].toString(),
        type = json['type'].split('#').first,
        id = json['id'].toString(),
        title = json['title'].toString(),
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
    return 'Recurring(id: $id, simulationId: $scenarioDataId, type: $type, title: $title, startAge: $startAge, endAge: $endAge, chargeType: $chargeType, lineItems: $lineItems)';
  }
}
