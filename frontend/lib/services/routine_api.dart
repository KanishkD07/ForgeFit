import 'dart:convert';

import 'package:http/http.dart'
    as http;

import '../models/routine.dart';

class RoutineApi {
  static const String baseUrl =
      'http://localhost:3000/api';

  static Map<String, String>
      _headers(
    String token,
  ) {
    return {
      'Content-Type':
          'application/json',

      'Authorization':
          'Bearer $token',
    };
  }

  static dynamic _decode(
    http.Response response,
  ) {
    if (response.body.isEmpty) {
      return null;
    }

    try {
      return jsonDecode(
        response.body,
      );
    } catch (_) {
      return null;
    }
  }

  static Exception _error(
    http.Response response,
    String fallback,
  ) {
    final data =
        _decode(response);

    if (data
            is Map<String, dynamic> &&
        data['message']
            is String) {
      return Exception(
        data['message'],
      );
    }

    return Exception(
      fallback,
    );
  }

  // =========================
  // GET ROUTINES
  // =========================

  static Future<List<RoutineData>>
      getRoutines(
    String token,
  ) async {
    final response =
        await http.get(
      Uri.parse(
        '$baseUrl/routines',
      ),
      headers:
          _headers(token),
    );

    if (response.statusCode !=
        200) {
      throw _error(
        response,
        'Failed to load routines',
      );
    }

    final data =
        _decode(response)
            as List<dynamic>;

    return data.map(
      (item) {
        return RoutineData.fromJson(
          item
              as Map<String,
                  dynamic>,
        );
      },
    ).toList();
  }

  // =========================
  // CREATE ROUTINE
  // =========================

  static Future<RoutineData>
      createRoutine(
    RoutineData routine,
    String token,
  ) async {
    final response =
        await http.post(
      Uri.parse(
        '$baseUrl/routines',
      ),
      headers:
          _headers(token),
      body: jsonEncode(
        routine.toJson(),
      ),
    );

    if (response.statusCode !=
        201) {
      throw _error(
        response,
        'Failed to create routine',
      );
    }

    return RoutineData.fromJson(
      _decode(response)
          as Map<String, dynamic>,
    );
  }

  // =========================
  // UPDATE ROUTINE
  // =========================

  static Future<RoutineData>
      updateRoutine(
    RoutineData routine,
    String token,
  ) async {
    final response =
        await http.patch(
      Uri.parse(
        '$baseUrl/routines/${routine.id}',
      ),
      headers:
          _headers(token),
      body: jsonEncode(
        routine.toJson(),
      ),
    );

    if (response.statusCode !=
        200) {
      throw _error(
        response,
        'Failed to update routine',
      );
    }

    return RoutineData.fromJson(
      _decode(response)
          as Map<String, dynamic>,
    );
  }

  // =========================
  // DELETE ROUTINE
  // =========================

  static Future<void>
      deleteRoutine(
    String id,
    String token,
  ) async {
    final response =
        await http.delete(
      Uri.parse(
        '$baseUrl/routines/$id',
      ),
      headers:
          _headers(token),
    );

    if (response.statusCode !=
        200) {
      throw _error(
        response,
        'Failed to delete routine',
      );
    }
  }
}