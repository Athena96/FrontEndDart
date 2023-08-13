import 'charge_type.dart';
import 'line_item.dart';

class OneTime {
  final String id;
      final  String simulationId;
       final String title;
       final int age;
       final ChargeType chargeType;
       final LineItem lineItem;

  OneTime(this.id, this.simulationId, this.title, this.age, this.chargeType, this.lineItem);

  OneTime.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        simulationId = json['simulationId'],
        title = json['title'],
        age = json['age'],
        chargeType = json['chargeType'].toString() == 'EXPENSE' ? ChargeType.EXPENSE : ChargeType.INCOME,
        lineItem = LineItem.fromJson(json['lineItem']);
}
