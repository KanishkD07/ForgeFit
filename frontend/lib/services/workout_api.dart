import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/workout.dart';

class WorkoutApi {
  static const String baseUrl =
      'http://localhost:3000';

  static Map<String, String> _headers(
    String token,
  ) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // CREATE
  static Future<WorkoutData> saveWorkout(
    WorkoutData workout,
    String token,
  ) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/api/workouts',
      ),
      headers: _headers(token),
      body: jsonEncode(
        _workoutToJson(workout),
      ),
    );

    if (response.statusCode != 201) {
      throw Exception(
        'Failed to save workout: '
        '${response.body}',
      );
    }

    final data =
        jsonDecode(response.body)
            as Map<String, dynamic>;

    return _workoutFromJson(data);
  }

  // READ
  static Future<List<WorkoutData>>
      getWorkouts(
    String token,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/workouts',
      ),
      headers: _headers(token),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load workouts: '
        '${response.body}',
      );
    }

    final data =
        jsonDecode(response.body)
            as List<dynamic>;

    return data.map((item) {
      return _workoutFromJson(
        item as Map<String, dynamic>,
      );
    }).toList();
  }

  // UPDATE
  static Future<WorkoutData> updateWorkout(
    WorkoutData workout,
    String token,
  ) async {
    final response = await http.patch(
      Uri.parse(
        '$baseUrl/api/workouts/${workout.id}',
      ),
      headers: _headers(token),
      body: jsonEncode(
        _workoutToJson(workout),
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update workout: '
        '${response.body}',
      );
    }

    final data =
        jsonDecode(response.body)
            as Map<String, dynamic>;

    return _workoutFromJson(data);
  }

  // DELETE
  static Future<void> deleteWorkout(
    String id,
    String token,
  ) async {
    final response = await http.delete(
      Uri.parse(
        '$baseUrl/api/workouts/$id',
      ),
      headers: _headers(token),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to delete workout: '
        '${response.body}',
      );
    }
  }

  static Map<String, dynamic>
      _workoutToJson(
    WorkoutData workout,
  ) {
    return {
      'date': workout.date
          .toUtc()
          .toIso8601String(),
      'durationSeconds':
          workout.durationSeconds,
      'exercises':
          workout.exercises.map(
        (exercise) {
          return {
            'name': exercise.name,
            'sets':
                exercise.sets.map(
              (set) {
                return {
                  'weight': set.weight,
                  'reps': set.reps,
                };
              },
            ).toList(),
          };
        },
      ).toList(),
    };
  }

  static WorkoutData _workoutFromJson(
    Map<String, dynamic> data,
  ) {
    return WorkoutData(
      id: data['_id'] as String,
      date: DateTime.parse(
        data['date'] as String,
      ),
      durationSeconds:
          (data['durationSeconds'] as num)
              .toInt(),
      exercises:
          (data['exercises']
                  as List<dynamic>)
              .map((exercise) {
        final exerciseData =
            exercise
                as Map<String, dynamic>;

        return ExerciseData(
          name:
              exerciseData['name']
                  as String,
          sets:
              (exerciseData['sets']
                      as List<dynamic>)
                  .map((set) {
            final setData =
                set
                    as Map<String, dynamic>;

            return WorkoutSetData(
              weight:
                  (setData['weight']
                          as num)
                      .toDouble(),
              reps:
                  (setData['reps']
                          as num)
                      .toInt(),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}