
class Settings {
  final String id;
      final  String simulationId;
       final String email;
       final DateTime birthday;
       final double annualAssetReturnPercent;
       final double annualInflationPercent;

  Settings(this.id, this.simulationId, this.email, this.birthday, this.annualAssetReturnPercent, this.annualInflationPercent);

  Settings.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        simulationId = json['simulationId'],
        email = json['email'],
        birthday = DateTime.fromMillisecondsSinceEpoch(int.parse(json['birthday'].toString())),
        annualAssetReturnPercent = double.parse(json['annualAssetReturnPercent'].toString()),
        annualInflationPercent = double.parse(json['annualInflationPercent'].toString());
 
 @override
  String toString() {
    return 'Settings(id: $id, simulationId: $simulationId, email: $email, birthday: $birthday, annualAssetReturnPercent: $annualAssetReturnPercent, annualInflationPercent: $annualInflationPercent)';
  }
}
