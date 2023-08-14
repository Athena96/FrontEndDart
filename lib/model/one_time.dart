import 'charge_type.dart';
import 'line_item.dart';

class OneTime {
  final String id;
  final String simulationId;
  final String title;
  final int age;
  final ChargeType chargeType;
  final LineItem lineItem;

  OneTime(this.id, this.simulationId, this.title, this.age, this.chargeType,
      this.lineItem);

  OneTime.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        simulationId = json['simulationId'],
        title = json['title'],
        age = json['age'],
        chargeType = json['chargeType'].toString() == 'EXPENSE'
            ? ChargeType.EXPENSE
            : ChargeType.INCOME,
        lineItem = LineItem.fromJson(json['lineItem']);

  static Map<int, double> convertOneTimesToMap(List<OneTime> oneTimes) {
    final Map<int, double> m = {};
    for (final oneTime in oneTimes) {
      if (oneTime.chargeType == ChargeType.EXPENSE) {
        m[oneTime.age] = (m[oneTime.age] ?? 0.0) - oneTime.lineItem.amount;
      } else {
        m[oneTime.age] = (m[oneTime.age] ?? 0.0) + oneTime.lineItem.amount;
      }
    }
    return m;
  }
}
