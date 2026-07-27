import 'package:flutter/material.dart';

import '../models/workout.dart';
import '../services/app_state.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';
import 'workout_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AppState appState = AppState.instance;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    appState.addListener(_refresh);
  }

  @override
  void dispose() {
    appState.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (!mounted) return;

    setState(() {});
  }

  void _changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openProgress() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProgressScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        appState: appState,
        onStartWorkout: () {
          _changeTab(1);
        },
        onOpenProgress: _openProgress,
      ),
      const WorkoutScreen(),
      const HistoryScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: SafeArea(
        child: screens[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _changeTab,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_outlined),
            activeIcon: Icon(Icons.fitness_center),
            label: "Workout",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "History",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final AppState appState;
  final VoidCallback onStartWorkout;
  final VoidCallback onOpenProgress;

  const HomeScreen({
    super.key,
    required this.appState,
    required this.onStartWorkout,
    required this.onOpenProgress,
  });

  @override
  Widget build(BuildContext context) {
    final profile = appState.profile;
    final latestWorkout = appState.latestWorkout;
    final records = appState.personalRecords;

    String? latestPRName;
    double latestPRWeight = 0;

    if (records.isNotEmpty) {
      latestPRName = records.keys.last;
      latestPRWeight = records[latestPRName] ?? 0;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        20,
        24,
        20,
        30,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "FORGEFIT",
            style: TextStyle(
              color: Colors.red,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "${getGreeting()}, ${profile.name}",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            "Ready for another session?",
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 28),

          Row(
            children: [
              Expanded(
                child: DashboardStatCard(
                  icon: Icons.monitor_weight_outlined,
                  value: "${formatNumber(profile.weight)} kg",
                  label: "Weight",
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: DashboardStatCard(
                  icon: Icons.local_fire_department_outlined,
                  value: "${calculateStreak(appState.workouts)}",
                  label: "Day Streak",
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: DashboardStatCard(
                  icon: Icons.fitness_center,
                  value: "${appState.totalWorkouts}",
                  label: "Workouts",
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: DashboardStatCard(
                  icon: Icons.emoji_events_outlined,
                  value: "${appState.totalPersonalRecords}",
                  label: "PRs",
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: onOpenProgress,
              icon: const Icon(Icons.insights_rounded),
              label: const Text(
                "View Progress",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(
                child: Text(
                  latestWorkout == null
                      ? "Start Training"
                      : "Latest Workout",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              if (latestWorkout != null)
                Text(
                  formatWorkoutDate(latestWorkout.date),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          if (latestWorkout == null)
            EmptyDashboardWorkout(
              onStartWorkout: onStartWorkout,
            )
          else
            LatestWorkoutCard(
              workout: latestWorkout,
            ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: onStartWorkout,
              icon: const Icon(
                Icons.play_arrow_rounded,
              ),
              label: Text(
                latestWorkout == null
                    ? "Start First Workout"
                    : "Start Workout",
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          const Text(
            "Personal Records",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          if (latestPRName == null)
            const EmptyPRCard()
          else
            PersonalRecordCard(
              exercise: latestPRName,
              weight: latestPRWeight,
            ),

          const SizedBox(height: 32),

          const Text(
            "This Week",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: WeeklyStat(
                      value:
                          "${appState.workoutsThisWeek.length}",
                      label: "Sessions",
                    ),
                  ),

                  const WeeklyDivider(),

                  Expanded(
                    child: WeeklyStat(
                      value: formatTrainingTime(
                        appState.weeklyTrainingSeconds,
                      ),
                      label: "Training",
                    ),
                  ),

                  const WeeklyDivider(),

                  Expanded(
                    child: WeeklyStat(
                      value: formatCompactVolume(
                        appState.weeklyVolume,
                      ),
                      label: "Volume",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LatestWorkoutCard extends StatelessWidget {
  final WorkoutData workout;

  const LatestWorkoutCard({
    super.key,
    required this.workout,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            ...List.generate(
              workout.exercises.length,
              (index) {
                final exercise = workout.exercises[index];

                return Column(
                  children: [
                    WorkoutExerciseRow(
                      exercise: exercise.name,
                      target: buildSetSummary(exercise),
                    ),

                    if (index !=
                        workout.exercises.length - 1)
                      const Divider(height: 28),
                  ],
                );
              },
            ),

            const Divider(height: 30),

            Row(
              children: [
                Expanded(
                  child: MiniWorkoutStat(
                    icon: Icons.timer_outlined,
                    value: formatTrainingTime(
                      workout.durationSeconds,
                    ),
                  ),
                ),

                Expanded(
                  child: MiniWorkoutStat(
                    icon: Icons.checklist_rounded,
                    value: "${workout.totalSets} sets",
                  ),
                ),

                Expanded(
                  child: MiniWorkoutStat(
                    icon: Icons.bar_chart_rounded,
                    value:
                        "${formatNumber(workout.totalVolume)} kg",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyDashboardWorkout extends StatelessWidget {
  final VoidCallback onStartWorkout;

  const EmptyDashboardWorkout({
    super.key,
    required this.onStartWorkout,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 32,
          horizontal: 20,
        ),
        child: Column(
          children: [
            const Icon(
              Icons.fitness_center,
              size: 40,
              color: Colors.grey,
            ),

            const SizedBox(height: 14),

            const Text(
              "No workouts logged yet",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              "Your latest session will appear here after you finish a workout.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 16),

            TextButton(
              onPressed: onStartWorkout,
              child: const Text("Start Training"),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyPRCard extends StatelessWidget {
  const EmptyPRCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Color(0xFF252525),
              child: Icon(
                Icons.emoji_events_outlined,
                color: Colors.grey,
              ),
            ),

            SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "No PRs yet",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 4),

                  Text(
                    "Complete a workout to establish your first records.",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PersonalRecordCard extends StatelessWidget {
  final String exercise;
  final double weight;

  const PersonalRecordCard({
    super.key,
    required this.exercise,
    required this.weight,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 25,
              backgroundColor: Color(0xFF352900),
              child: Icon(
                Icons.emoji_events,
                color: Colors.amber,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    "Personal Record",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            Text(
              "${formatNumber(weight)} kg",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const DashboardStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: Colors.red,
              size: 26,
            ),

            const SizedBox(height: 18),

            Text(
              value,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WorkoutExerciseRow extends StatelessWidget {
  final String exercise;
  final String target;

  const WorkoutExerciseRow({
    super.key,
    required this.exercise,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.fitness_center,
          color: Colors.red,
          size: 20,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            exercise,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(width: 10),

        Flexible(
          child: Text(
            target,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class MiniWorkoutStat extends StatelessWidget {
  final IconData icon;
  final String value;

  const MiniWorkoutStat({
    super.key,
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.grey,
          size: 18,
        ),

        const SizedBox(height: 6),

        FittedBox(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class WeeklyStat extends StatelessWidget {
  final String value;
  final String label;

  const WeeklyStat({
    super.key,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FittedBox(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 5),

        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class WeeklyDivider extends StatelessWidget {
  const WeeklyDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 35,
      color: const Color(0xFF444444),
    );
  }
}

String getGreeting() {
  final hour = DateTime.now().hour;

  if (hour < 12) {
    return "Good Morning";
  }

  if (hour < 17) {
    return "Good Afternoon";
  }

  return "Good Evening";
}

int calculateStreak(List<WorkoutData> workouts) {
  if (workouts.isEmpty) {
    return 0;
  }

  final uniqueDates = workouts.map((workout) {
    return DateTime(
      workout.date.year,
      workout.date.month,
      workout.date.day,
    );
  }).toSet().toList()
    ..sort((a, b) => b.compareTo(a));

  if (uniqueDates.isEmpty) {
    return 0;
  }

  final now = DateTime.now();
  final today = DateTime(
    now.year,
    now.month,
    now.day,
  );

  final yesterday = today.subtract(
    const Duration(days: 1),
  );

  // A streak can still be active if the last workout
  // was yesterday and the user has not trained today yet.
  if (uniqueDates.first != today &&
      uniqueDates.first != yesterday) {
    return 0;
  }

  int streak = 1;

  for (int i = 1; i < uniqueDates.length; i++) {
    final expectedPreviousDay = uniqueDates[i - 1].subtract(
      const Duration(days: 1),
    );

    if (uniqueDates[i] == expectedPreviousDay) {
      streak++;
    } else {
      break;
    }
  }

  return streak;
}

String buildSetSummary(ExerciseData exercise) {
  if (exercise.sets.isEmpty) {
    return "No sets";
  }

  if (exercise.sets.length == 1) {
    final set = exercise.sets.first;

    return "${formatNumber(set.weight)} kg × ${set.reps}";
  }

  final bestWeight = exercise.bestWeight;

  return "${exercise.sets.length} sets • "
      "best ${formatNumber(bestWeight)} kg";
}

String formatTrainingTime(int seconds) {
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  final remainingSeconds = seconds % 60;

  if (hours > 0) {
    return "${hours}h ${minutes}m";
  }

  if (minutes > 0) {
    return "${minutes}m";
  }

  return "${remainingSeconds}s";
}

String formatCompactVolume(double volume) {
  if (volume >= 1000000) {
    return "${(volume / 1000000).toStringAsFixed(1)}M";
  }

  if (volume >= 1000) {
    return "${(volume / 1000).toStringAsFixed(1)}k";
  }

  return formatNumber(volume);
}

String formatWorkoutDate(DateTime date) {
  final now = DateTime.now();

  final today = DateTime(
    now.year,
    now.month,
    now.day,
  );

  final workoutDay = DateTime(
    date.year,
    date.month,
    date.day,
  );

  if (workoutDay == today) {
    return "Today";
  }

  if (workoutDay ==
      today.subtract(const Duration(days: 1))) {
    return "Yesterday";
  }

  return "${date.day}/${date.month}/${date.year}";
}

String formatNumber(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }

  return value.toStringAsFixed(1);
}