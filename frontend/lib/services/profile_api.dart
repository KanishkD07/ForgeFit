import 'dart:convert';

import 'package:http/http.dart'
    as http;

import '../models/user_profile.dart';

class ProfileApi {
  static const String baseUrl =
      "http://localhost:3000/api/profile";

  // GET /api/profile
  static Future<UserProfile>
      getProfile() async {
    final response =
        await http.get(
      Uri.parse(baseUrl),
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to load profile. "
        "Status: ${response.statusCode}",
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
  ) async {
    final response =
        await http.patch(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type":
            "application/json",
      },
      body: jsonEncode(
        profile.toJson(),
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to update profile. "
        "Status: ${response.statusCode}",
      );
    }

    final data =
        jsonDecode(response.body)
            as Map<String, dynamic>;

    return UserProfile.fromJson(data);
  }
}