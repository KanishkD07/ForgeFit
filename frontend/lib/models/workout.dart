class WorkoutSetData {
  final double weight;
  final int reps;

  const WorkoutSetData({
    required this.weight,
    required this.reps,
  });

  double get volume => weight * reps;
}

class ExerciseData {
  final String name;
  final List<WorkoutSetData> sets;

  const ExerciseData({
    required this.name,
    required this.sets,
  });

  double get volume {
    return sets.fold(
      0,
      (total, set) => total + set.volume,
    );
  }

  double get bestWeight {
    if (sets.isEmpty) return 0;

    return sets
        .map((set) => set.weight)
        .reduce((a, b) => a > b ? a : b);
  }
}

class WorkoutData {
  final String id;
  final DateTime date;
  final int durationSeconds;
  final List<ExerciseData> exercises;

  const WorkoutData({
    required this.id,
    required this.date,
    required this.durationSeconds,
    required this.exercises,
  });

  double get totalVolume {
    return exercises.fold(
      0,
      (total, exercise) => total + exercise.volume,
    );
  }

  int get totalSets {
    return exercises.fold(
      0,
      (total, exercise) => total + exercise.sets.length,
    );
  }
}