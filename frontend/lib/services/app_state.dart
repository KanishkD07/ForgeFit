import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/routine.dart';
import '../models/user_profile.dart';
import '../models/workout.dart';

import 'profile_api.dart';
import 'routine_api.dart';
import 'workout_api.dart';

class AppState extends ChangeNotifier {
  static final AppState instance =
      AppState._internal();

  AppState._internal();

  // =========================
  // AUTHENTICATION
  // =========================

  String? _authToken;
  String? _userId;
  String? _userName;
  String? _userEmail;

  String? get authToken => _authToken;
  String? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;

  bool get isAuthenticated =>
      _authToken != null &&
      _authToken!.isNotEmpty;

  static const String _tokenKey =
      'auth_token';

  static const String _userIdKey =
      'user_id';

  static const String _userNameKey =
      'user_name';

  static const String _userEmailKey =
      'user_email';

  Future<void> setAuth({
    required String token,
    required String userId,
    required String name,
    required String email,
  }) async {
    // Clear data belonging to the
    // previous account.
    _profile = null;

    _workouts.clear();
    _routines.clear();

    _authToken = token;
    _userId = userId;
    _userName = name;
    _userEmail = email;

    final prefs =
        await SharedPreferences
            .getInstance();

    await prefs.setString(
      _tokenKey,
      token,
    );

    await prefs.setString(
      _userIdKey,
      userId,
    );

    await prefs.setString(
      _userNameKey,
      name,
    );

    await prefs.setString(
      _userEmailKey,
      email,
    );

    debugPrint(
      'SESSION SAVED: '
      '${prefs.getString(_tokenKey) != null}',
    );

    notifyListeners();
  }

  Future<bool> restoreSession() async {
    final prefs =
        await SharedPreferences
            .getInstance();

    final token =
        prefs.getString(
      _tokenKey,
    );

    debugPrint(
      'SESSION RESTORED: '
      '${token != null}',
    );

    final userId =
        prefs.getString(
      _userIdKey,
    );

    final name =
        prefs.getString(
      _userNameKey,
    );

    final email =
        prefs.getString(
      _userEmailKey,
    );

    if (
      token == null ||
      token.isEmpty ||
      userId == null ||
      userId.isEmpty ||
      name == null ||
      name.isEmpty ||
      email == null ||
      email.isEmpty
    ) {
      return false;
    }

    _authToken = token;
    _userId = userId;
    _userName = name;
    _userEmail = email;

    notifyListeners();

    return true;
  }

  Future<void> logout() async {
    _authToken = null;
    _userId = null;
    _userName = null;
    _userEmail = null;

    _profile = null;

    // Important for multi-user
    // separation.
    _workouts.clear();
    _routines.clear();

    final prefs =
        await SharedPreferences
            .getInstance();

    await prefs.remove(
      _tokenKey,
    );

    await prefs.remove(
      _userIdKey,
    );

    await prefs.remove(
      _userNameKey,
    );

    await prefs.remove(
      _userEmailKey,
    );

    notifyListeners();
  }

  String _requireToken() {
    final token =
        _authToken;

    if (
      token == null ||
      token.isEmpty
    ) {
      throw Exception(
        'Authentication required',
      );
    }

    return token;
  }

  // =========================
  // PROFILE
  // =========================

  UserProfile? _profile;

  UserProfile? get profile =>
      _profile;

  bool _loadingProfile = false;

  bool get loadingProfile =>
      _loadingProfile;

  Future<void> loadProfile() async {
    if (_loadingProfile) {
      return;
    }

    final token =
        _requireToken();

    _loadingProfile = true;

    notifyListeners();

    try {
      _profile =
          await ProfileApi
              .getProfile(
        token,
      );
    } finally {
      _loadingProfile = false;

      notifyListeners();
    }
  }

  Future<UserProfile>
      updateProfile({
    required String name,
    required double height,
    required double weight,
    required String goal,
  }) async {
    final token =
        _requireToken();

    final currentProfile =
        _profile;

    if (currentProfile == null) {
      throw Exception(
        'Profile has not been loaded',
      );
    }

    final profileToUpdate =
        UserProfile(
      id: currentProfile.id,
      name: name,
      height: height,
      weight: weight,
      goal: goal,
      memberSince:
          currentProfile
              .memberSince,
    );

    final updatedProfile =
        await ProfileApi
            .updateProfile(
      profileToUpdate,
      token,
    );

    _profile =
        updatedProfile;

    _userName =
        updatedProfile.name;

    final prefs =
        await SharedPreferences
            .getInstance();

    await prefs.setString(
      _userNameKey,
      updatedProfile.name,
    );

    notifyListeners();

    return updatedProfile;
  }

  Future<void> updateWeight(
    double weight,
  ) async {
    final currentProfile =
        _profile;

    if (currentProfile == null) {
      throw Exception(
        'Profile has not been loaded',
      );
    }

    await updateProfile(
      name:
          currentProfile.name,
      height:
          currentProfile.height,
      weight:
          weight,
      goal:
          currentProfile.goal,
    );
  }

  // =========================
  // WORKOUTS
  // =========================

  final List<WorkoutData>
      _workouts = [];

  bool _loadingWorkouts =
      false;

  bool get loadingWorkouts =>
      _loadingWorkouts;

  List<WorkoutData>
      get workouts =>
          List.unmodifiable(
            _workouts,
          );

  int get totalWorkouts =>
      _workouts.length;

  double get totalVolume {
    return _workouts.fold(
      0,
      (
        total,
        workout,
      ) =>
          total +
          workout.totalVolume,
    );
  }

  int get totalTrainingSeconds {
    return _workouts.fold(
      0,
      (
        total,
        workout,
      ) =>
          total +
          workout
              .durationSeconds,
    );
  }

  Future<WorkoutData>
      saveWorkout(
    WorkoutData workout,
  ) async {
    final token =
        _requireToken();

    final savedWorkout =
        await WorkoutApi
            .saveWorkout(
      workout,
      token,
    );

    _workouts.insert(
      0,
      savedWorkout,
    );

    notifyListeners();

    return savedWorkout;
  }

  Future<void>
      loadWorkouts() async {
    if (_loadingWorkouts) {
      return;
    }

    final token =
        _requireToken();

    _loadingWorkouts = true;

    notifyListeners();

    try {
      final workouts =
          await WorkoutApi
              .getWorkouts(
        token,
      );

      _workouts
        ..clear()
        ..addAll(
          workouts,
        );
    } finally {
      _loadingWorkouts =
          false;

      notifyListeners();
    }
  }

  Future<WorkoutData>
      updateWorkout(
    WorkoutData workout,
  ) async {
    final token =
        _requireToken();

    final updatedWorkout =
        await WorkoutApi
            .updateWorkout(
      workout,
      token,
    );

    final index =
        _workouts.indexWhere(
      (
        existingWorkout,
      ) =>
          existingWorkout.id ==
          updatedWorkout.id,
    );

    if (index != -1) {
      _workouts[index] =
          updatedWorkout;
    }

    _workouts.sort(
      (
        a,
        b,
      ) =>
          b.date.compareTo(
        a.date,
      ),
    );

    notifyListeners();

    return updatedWorkout;
  }

  Future<void>
      deleteWorkout(
    String id,
  ) async {
    final token =
        _requireToken();

    await WorkoutApi
        .deleteWorkout(
      id,
      token,
    );

    _workouts.removeWhere(
      (
        workout,
      ) =>
          workout.id == id,
    );

    notifyListeners();
  }

  // =========================
  // ROUTINES
  // =========================

  final List<RoutineData>
      _routines = [];

  bool _loadingRoutines =
      false;

  bool get loadingRoutines =>
      _loadingRoutines;

  List<RoutineData>
      get routines =>
          List.unmodifiable(
            _routines,
          );

  int get totalRoutines =>
      _routines.length;

  Future<void>
      loadRoutines() async {
    if (_loadingRoutines) {
      return;
    }

    final token =
        _requireToken();

    _loadingRoutines = true;

    notifyListeners();

    try {
      final routines =
          await RoutineApi
              .getRoutines(
        token,
      );

      _routines
        ..clear()
        ..addAll(
          routines,
        );
    } finally {
      _loadingRoutines =
          false;

      notifyListeners();
    }
  }

  Future<RoutineData>
      createRoutine({
    required String name,

    required List<
            RoutineExerciseData>
        exercises,
  }) async {
    final token =
        _requireToken();

    final routine =
        RoutineData(
      id: '',
      name: name.trim(),
      exercises:
          List.unmodifiable(
        exercises,
      ),
    );

    final createdRoutine =
        await RoutineApi
            .createRoutine(
      routine,
      token,
    );

    _routines.insert(
      0,
      createdRoutine,
    );

    notifyListeners();

    return createdRoutine;
  }

  Future<RoutineData>
      updateRoutine(
    RoutineData routine,
  ) async {
    final token =
        _requireToken();

    final updatedRoutine =
        await RoutineApi
            .updateRoutine(
      routine,
      token,
    );

    final index =
        _routines.indexWhere(
      (
        existingRoutine,
      ) =>
          existingRoutine.id ==
          updatedRoutine.id,
    );

    if (index != -1) {
      _routines[index] =
          updatedRoutine;
    } else {
      _routines.insert(
        0,
        updatedRoutine,
      );
    }

    notifyListeners();

    return updatedRoutine;
  }

  Future<void>
      deleteRoutine(
    String id,
  ) async {
    final token =
        _requireToken();

    await RoutineApi
        .deleteRoutine(
      id,
      token,
    );

    _routines.removeWhere(
      (
        routine,
      ) =>
          routine.id == id,
    );

    notifyListeners();
  }

  // =========================
  // STATISTICS
  // =========================

  double personalRecordFor(
    String exerciseName,
  ) {
    double best = 0;

    for (
      final workout
      in _workouts
    ) {
      for (
        final exercise
        in workout.exercises
      ) {
        if (
          exercise.name
                  .toLowerCase() ==
              exerciseName
                  .toLowerCase()
        ) {
          if (
            exercise.bestWeight >
                best
          ) {
            best =
                exercise
                    .bestWeight;
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
    final now =
        DateTime.now();

    final sevenDaysAgo =
        now.subtract(
      const Duration(
        days: 7,
      ),
    );

    return _workouts.where(
      (
        workout,
      ) {
        return workout.date
            .isAfter(
          sevenDaysAgo,
        );
      },
    ).toList();
  }

  double get weeklyVolume {
    return workoutsThisWeek.fold(
      0,
      (
        total,
        workout,
      ) =>
          total +
          workout.totalVolume,
    );
  }

  int get weeklyTrainingSeconds {
    return workoutsThisWeek.fold(
      0,
      (
        total,
        workout,
      ) =>
          total +
          workout
              .durationSeconds,
    );
  }

  WorkoutData?
      get latestWorkout {
    if (_workouts.isEmpty) {
      return null;
    }

    return _workouts.first;
  }

  Map<String, double>
      get personalRecords {
    final records =
        <String, double>{};

    for (
      final workout
      in _workouts
    ) {
      for (
        final exercise
        in workout.exercises
      ) {
        final name =
            exercise.name.trim();

        if (name.isEmpty) {
          continue;
        }

        final currentBest =
            records[name] ?? 0;

        if (
          exercise.bestWeight >
              currentBest
        ) {
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