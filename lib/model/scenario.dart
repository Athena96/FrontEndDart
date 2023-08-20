class Scenario {
  final String email;
  final int active;
  final String scenarioId;
  final String title;

  Scenario(this.email, this.active, this.scenarioId, this.title);

  // Named constructor that initializes the object from a JSON map
  Scenario.fromJson(Map<String, dynamic> json)
      : email = json['email'],
        active = int.parse(json['active'].toString()),
        scenarioId = json['scenarioId'],
        title = json['title'];

  static Scenario getActiveScenario(List<Scenario> scenarios) {
    for (var scenario in scenarios) {
      if (scenario.active == 1) {
        return scenario;
      }
    }
    throw Exception('No active scenario found');
  }

  @override
  String toString() {
    return 'Scenario(email: $email, active: $active, scenarioId: $scenarioId, title: $title)';
  }
}
