import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/models/workout.dart';

void main() {
  group('WorkoutSetData', () {
    test('calculates set volume correctly', () {
      const set = WorkoutSetData(
        weight: 100,
        reps: 5,
      );

      expect(
        set.volume,
        500,
      );
    });
  });

  group('ExerciseData', () {
    test('calculates exercise volume correctly', () {
      const exercise = ExerciseData(
        name: 'Bench Press',
        sets: [
          WorkoutSetData(
            weight: 60,
            reps: 10,
          ),
          WorkoutSetData(
            weight: 70,
            reps: 8,
          ),
          WorkoutSetData(
            weight: 80,
            reps: 5,
          ),
        ],
      );

      expect(
        exercise.volume,
        1560,
      );
    });

    test('finds best weight correctly', () {
      const exercise = ExerciseData(
        name: 'Deadlift',
        sets: [
          WorkoutSetData(
            weight: 80,
            reps: 8,
          ),
          WorkoutSetData(
            weight: 100,
            reps: 5,
          ),
          WorkoutSetData(
            weight: 90,
            reps: 6,
          ),
        ],
      );

      expect(
        exercise.bestWeight,
        100,
      );
    });

    test('returns zero best weight with no sets', () {
      const exercise = ExerciseData(
        name: 'Squat',
        sets: [],
      );

      expect(
        exercise.bestWeight,
        0,
      );
    });
  });

  group('WorkoutData', () {
    test('calculates total workout volume correctly', () {
      final workout = WorkoutData(
        id: 'test-workout',
        date: DateTime(
          2026,
          7,
          31,
        ),
        durationSeconds: 3600,
        exercises: const [
          ExerciseData(
            name: 'Bench Press',
            sets: [
              WorkoutSetData(
                weight: 60,
                reps: 10,
              ),
              WorkoutSetData(
                weight: 70,
                reps: 8,
              ),
            ],
          ),
          ExerciseData(
            name: 'Deadlift',
            sets: [
              WorkoutSetData(
                weight: 100,
                reps: 5,
              ),
            ],
          ),
        ],
      );

      expect(
        workout.totalVolume,
        1660,
      );
    });

    test('calculates total sets correctly', () {
      final workout = WorkoutData(
        id: 'test-workout',
        date: DateTime(
          2026,
          7,
          31,
        ),
        durationSeconds: 1800,
        exercises: const [
          ExerciseData(
            name: 'Bench Press',
            sets: [
              WorkoutSetData(
                weight: 60,
                reps: 10,
              ),
              WorkoutSetData(
                weight: 65,
                reps: 8,
              ),
              WorkoutSetData(
                weight: 70,
                reps: 6,
              ),
            ],
          ),
          ExerciseData(
            name: 'Squat',
            sets: [
              WorkoutSetData(
                weight: 80,
                reps: 8,
              ),
              WorkoutSetData(
                weight: 90,
                reps: 5,
              ),
            ],
          ),
        ],
      );

      expect(
        workout.totalSets,
        5,
      );
    });

    test('empty workout has zero volume and sets', () {
      final workout = WorkoutData(
        id: 'empty-workout',
        date: DateTime(
          2026,
          7,
          31,
        ),
        durationSeconds: 0,
        exercises: const [],
      );

      expect(
        workout.totalVolume,
        0,
      );

      expect(
        workout.totalSets,
        0,
      );
    });
  });
}