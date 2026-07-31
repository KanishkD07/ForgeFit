class UserProfile {
  final String id;

  String name;
  double height;
  double weight;
  String goal;
  DateTime memberSince;

  int weeklyWorkoutGoal;

  UserProfile({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.goal,
    required this.memberSince,
    this.weeklyWorkoutGoal = 4,
  });

  factory UserProfile.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserProfile(
      id: json["_id"]?.toString() ?? "",
      name: json["name"]?.toString() ?? "",
      height:
          (json["height"] as num)
              .toDouble(),
      weight:
          (json["weight"] as num)
              .toDouble(),
      goal:
          json["goal"]?.toString() ?? "",
      memberSince:
          DateTime.parse(
        json["memberSince"].toString(),
      ),
      weeklyWorkoutGoal:
          (json["weeklyWorkoutGoal"]
                      as num?)
                  ?.toInt() ??
              4,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "height": height,
      "weight": weight,
      "goal": goal,
      "weeklyWorkoutGoal":
          weeklyWorkoutGoal,
    };
  }
}