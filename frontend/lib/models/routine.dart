class RoutineExerciseData {
  final String name;
  final int defaultSets;

  const RoutineExerciseData({
    required this.name,
    required this.defaultSets,
  });

  factory RoutineExerciseData.fromJson(
    Map<String, dynamic> json,
  ) {
    return RoutineExerciseData(
      name:
          json['name'] as String,

      defaultSets:
          (json['defaultSets']
                  as num)
              .toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),

      'defaultSets':
          defaultSets,
    };
  }
}

class RoutineData {
  final String id;
  final String name;

  final List<RoutineExerciseData>
      exercises;

  const RoutineData({
    required this.id,
    required this.name,
    required this.exercises,
  });

  factory RoutineData.fromJson(
    Map<String, dynamic> json,
  ) {
    return RoutineData(
      id:
          (json['_id'] ??
                  json['id'])
              .toString(),

      name:
          json['name'] as String,

      exercises:
          (json['exercises']
                  as List<dynamic>)
              .map(
        (item) {
          return RoutineExerciseData
              .fromJson(
            item
                as Map<String,
                    dynamic>,
          );
        },
      ).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),

      'exercises':
          exercises
              .map(
                (exercise) =>
                    exercise
                        .toJson(),
              )
              .toList(),
    };
  }
}