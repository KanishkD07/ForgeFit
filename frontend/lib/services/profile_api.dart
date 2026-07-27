import 'dart:convert';

import 'package:http/http.dart'
    as http;

import '../models/user_profile.dart';

class ProfileApi {
  static const String baseUrl =
      'http://localhost:3000/api/profile';

  static Map<String, String> _headers(
    String token,
  ) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // GET /api/profile
  static Future<UserProfile>
      getProfile(
    String token,
  ) async {
    final response =
        await http.get(
      Uri.parse(baseUrl),
      headers: _headers(token),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load profile: '
        '${response.body}',
      );
    }

    final data =
        jsonDecode(response.body)
            as Map<String, dynamic>;

    return UserProfile.fromJson(data);
  }

  // PATCH /api/profile
  static Future<UserProfile>
      updateProfile(
    UserProfile profile,
    String token,
  ) async {
    final response =
        await http.patch(
      Uri.parse(baseUrl),
      headers: _headers(token),
      body: jsonEncode(
        profile.toJson(),
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update profile: '
        '${response.body}',
      );
    }

    final data =
        jsonDecode(response.body)
            as Map<String, dynamic>;

    return UserProfile.fromJson(data);
  }
}