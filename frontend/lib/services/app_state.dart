import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import '../models/workout.dart';
import 'workout_api.dart';

class AppState extends ChangeNotifier {
  static final AppState instance =
      AppState._internal();

  AppState._internal();

  final UserProfile profile =
      UserProfile(
    name: "Kanishk",
    height: 175,
    weight: 78,
    goal:
        "Build strength and an athletic physique",
    memberSince: DateTime(2026, 7),
  );

  final List<WorkoutData> _workouts =
      [];

  bool _loadingWorkouts = false;

  bool get loadingWorkouts =>
      _loadingWorkouts;

  List<WorkoutData> get workouts =>
      List.unmodifiable(_workouts);

  int get totalWorkouts =>
      _workouts.length;

  double get totalVolume {
    return _workouts.fold(
      0,
      (total, workout) =>
          total + workout.totalVolume,
    );
  }

  int get totalTrainingSeconds {
    return _workouts.fold(
      0,
      (total, workout) =>
          total +
          workout.durationSeconds,
    );
  }

  // CREATE
  Future<WorkoutData> saveWorkout(
    WorkoutData workout,
  ) async {
    final savedWorkout =
        await WorkoutApi.saveWorkout(
      workout,
    );

    _workouts.insert(
      0,
      savedWorkout,
    );

    notifyListeners();

    return savedWorkout;
  }

  // READ
  Future<void> loadWorkouts() async {
    if (_loadingWorkouts) return;

    _loadingWorkouts = true;
    notifyListeners();

    try {
      final workouts =
          await WorkoutApi
              .getWorkouts();

      _workouts
        ..clear()
        ..addAll(workouts);
    } finally {
      _loadingWorkouts = false;
      notifyListeners();
    }
  }

  // UPDATE
  Future<WorkoutData> updateWorkout(
    WorkoutData workout,
  ) async {
    final updatedWorkout =
        await WorkoutApi.updateWorkout(
      workout,
    );

    final index =
        _workouts.indexWhere(
      (existingWorkout) =>
          existingWorkout.id ==
          updatedWorkout.id,
    );

    if (index != -1) {
      _workouts[index] =
          updatedWorkout;
    }

    _workouts.sort(
      (a, b) =>
          b.date.compareTo(a.date),
    );

    notifyListeners();

    return updatedWorkout;
  }

  // DELETE
  Future<void> deleteWorkout(
    String id,
  ) async {
    await WorkoutApi.deleteWorkout(id);

    _workouts.removeWhere(
      (workout) =>
          workout.id == id,
    );

    notifyListeners();
  }

  void updateWeight(double weight) {
    profile.weight = weight;
    notifyListeners();
  }

  void updateProfile({
    required String name,
    required double height,
    required double weight,
    required String goal,
  }) {
    profile.name = name;
    profile.height = height;
    profile.weight = weight;
    profile.goal = goal;

    notifyListeners();
  }

  double personalRecordFor(
    String exerciseName,
  ) {
    double best = 0;

    for (final workout in _workouts) {
      for (final exercise
          in workout.exercises) {
        if (exercise.name
                .toLowerCase() ==
            exerciseName
                .toLowerCase()) {
          if (exercise.bestWeight >
              best) {
            best =
                exercise.bestWeight;
          }
        }
      }
    }

    return best;
  }

  int get totalPersonalRecords =>
      personalRecords.length;

  List<WorkoutData>
      get workoutsThisWeek {
    final now = DateTime.now();

    final sevenDaysAgo =
        now.subtract(
      const Duration(days: 7),
    );

    return _workouts
        .where((workout) {
      return workout.date
          .isAfter(sevenDaysAgo);
    }).toList();
  }

  double get weeklyVolume {
    return workoutsThisWeek.fold(
      0,
      (total, workout) =>
          total +
          workout.totalVolume,
    );
  }

  int get weeklyTrainingSeconds {
    return workoutsThisWeek.fold(
      0,
      (total, workout) =>
          total +
          workout.durationSeconds,
    );
  }

  WorkoutData? get latestWorkout {
    if (_workouts.isEmpty) {
      return null;
    }

    return _workouts.first;
  }

  Map<String, double>
      get personalRecords {
    final records =
        <String, double>{};

    for (final workout in _workouts) {
      for (final exercise
          in workout.exercises) {
        final name =
            exercise.name.trim();

        if (name.isEmpty) continue;

        final currentBest =
            records[name] ?? 0;

        if (exercise.bestWeight >
            currentBest) {
          records[name] =
              exercise.bestWeight;
        }
      }
    }

    return records;
  }

  void clearWorkouts() {
    _workouts.clear();
    notifyListeners();
  }
}