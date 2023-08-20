class Settings {
  final String scenarioDataId;
  final String type;
  final DateTime birthday;
  final double annualAssetReturnPercent;
  final double annualInflationPercent;

  Settings(this.scenarioDataId, this.type, this.birthday,
      this.annualAssetReturnPercent, this.annualInflationPercent);

  Settings.fromJson(Map<String, dynamic> json)
      : scenarioDataId = json['scenarioDataId'],
        type = json['type'].split('#').first,
        birthday = DateTime.fromMillisecondsSinceEpoch(
            int.parse(json['birthday'].toString())),
        annualAssetReturnPercent =
            double.parse(json['annualAssetReturnPercent'].toString()),
        annualInflationPercent =
            double.parse(json['annualInflationPercent'].toString());

  @override
  String toString() {
    return 'Settings(scenarioDataId: $scenarioDataId, type: $type, birthday: $birthday, annualAssetReturnPercent: $annualAssetReturnPercent, annualInflationPercent: $annualInflationPercent)';
  }
}
