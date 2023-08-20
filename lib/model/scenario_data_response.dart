import 'package:moneyapp_flutter/model/asset.dart';
import 'package:moneyapp_flutter/model/one_time.dart';
import 'package:moneyapp_flutter/model/recurring.dart';
import 'package:moneyapp_flutter/model/settings.dart';

class ScenarioDataResponse {
  final Settings settings;
  final List<Asset> assets;
  final List<Recurring> recurrings;
  final List<OneTime> onetimes;

  ScenarioDataResponse(
      this.settings, this.assets, this.recurrings, this.onetimes);
}
