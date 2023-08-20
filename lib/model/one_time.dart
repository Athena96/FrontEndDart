import 'charge_type.dart';

class OneTime {
  final String scenarioDataId;
  final String type;
  final String id;
  final String title;
  final int age;
  final ChargeType chargeType;
  final double amount;

  OneTime(this.id, this.scenarioDataId, this.type, this.title, this.age,
      this.chargeType, this.amount);

  OneTime.fromJson(Map<String, dynamic> json)
      : scenarioDataId = json['scenarioDataId'].toString(),
        type = json['type'].split('#').first,
        id = json['id'].toString(),
        title = json['title'].toString(),
        age = int.parse(json['age'].toString()),
        chargeType = json['chargeType'].toString() == 'EXPENSE'
            ? ChargeType.EXPENSE
            : ChargeType.INCOME,
        amount = double.parse(json['amount'].toString());

  static Map<int, double> convertOneTimesToMap(List<OneTime> oneTimes) {
    final Map<int, double> m = {};
    for (final oneTime in oneTimes) {
      if (oneTime.chargeType == ChargeType.EXPENSE) {
        m[oneTime.age] = (m[oneTime.age] ?? 0.0) - oneTime.amount;
      } else {
        m[oneTime.age] = (m[oneTime.age] ?? 0.0) + oneTime.amount;
      }
    }
    return m;
  }
}
