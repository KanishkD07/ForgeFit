import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthResult {
  final String token;
  final String userId;
  final String name;
  final String email;

  const AuthResult({
    required this.token,
    required this.userId,
    required this.name,
    required this.email,
  });

  factory AuthResult.fromJson(
    Map<String, dynamic> json,
  ) {
    final user =
        json['user']
            as Map<String, dynamic>;

    return AuthResult(
      token: json['token'] as String,
      userId: user['id'] as String,
      name: user['name'] as String,
      email: user['email'] as String,
    );
  }
}

class AuthApi {
  static const String baseUrl =
      'http://localhost:3000/api';

  // LOGIN
  static Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/auth/login',
      ),
      headers: {
        'Content-Type':
            'application/json',
      },
      body: jsonEncode({
        'email':
            email.trim().toLowerCase(),
        'password': password,
      }),
    );

    final data =
        jsonDecode(response.body);

    if (response.statusCode == 200) {
      return AuthResult.fromJson(
        data as Map<String, dynamic>,
      );
    }

    if (data
            is Map<String, dynamic> &&
        data['message'] is String) {
      throw Exception(
        data['message'],
      );
    }

    throw Exception(
      'Login failed',
    );
  }

  // REGISTER
  static Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    required double height,
    required double weight,
    required String goal,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/auth/register',
      ),
      headers: {
        'Content-Type':
            'application/json',
      },
      body: jsonEncode({
        'name': name.trim(),
        'email':
            email.trim().toLowerCase(),
        'password': password,
        'height': height,
        'weight': weight,
        'goal': goal.trim(),
      }),
    );

    final data =
        jsonDecode(response.body);

    if (response.statusCode == 201) {
      return AuthResult.fromJson(
        data as Map<String, dynamic>,
      );
    }

    if (data
            is Map<String, dynamic> &&
        data['message'] is String) {
      throw Exception(
        data['message'],
      );
    }

    throw Exception(
      'Failed to create account',
    );
  }
}