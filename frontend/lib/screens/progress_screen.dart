import 'package:flutter/material.dart';

import '../models/workout.dart';
import '../services/app_state.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final AppState appState = AppState.instance;

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

  @override
  Widget build(BuildContext context) {
    final workouts = appState.workouts;
    final records = appState.personalRecords;

    final sortedRecords = records.entries.toList()
      ..sort(
        (a, b) => b.value.compareTo(a.value),
      );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Progress",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Your Progress",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              "Track your training, strength and personal records.",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 28),

            Row(
              children: [
                Expanded(
                  child: ProgressStatCard(
                    icon: Icons.monitor_weight_outlined,
                    value:
                        "${formatNumber(appState.profile.weight)} kg",
                    label: "Body Weight",
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ProgressStatCard(
                    icon: Icons.fitness_center,
                    value: "${appState.totalWorkouts}",
                    label: "Workouts",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ProgressStatCard(
                    icon: Icons.bar_chart_rounded,
                    value: formatCompactVolume(
                      appState.totalVolume,
                    ),
                    label: "Total Volume",
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ProgressStatCard(
                    icon: Icons.emoji_events_outlined,
                    value:
                        "${appState.totalPersonalRecords}",
                    label: "PRs",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            const SectionTitle(
              title: "Strength Progress",
              subtitle:
                  "How your lifts have changed over time",
            ),

            const SizedBox(height: 14),

            if (workouts.isEmpty)
              const EmptySectionCard(
                icon: Icons.insights_outlined,
                title: "No strength data yet",
                message:
                    "Complete workouts to start tracking your strength progress.",
              )
            else
              StrengthProgressSection(
                workouts: workouts,
              ),

            const SizedBox(height: 32),

            const SectionTitle(
              title: "Personal Records",
              subtitle:
                  "Your heaviest completed sets",
            ),

            const SizedBox(height: 14),

            if (sortedRecords.isEmpty)
              const EmptySectionCard(
                icon: Icons.emoji_events_outlined,
                title: "No personal records yet",
                message:
                    "Your best lifts will appear here after you complete a workout.",
              )
            else
              ...List.generate(
                sortedRecords.length,
                (index) {
                  final record = sortedRecords[index];

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom:
                          index == sortedRecords.length - 1
                              ? 0
                              : 10,
                    ),
                    child: PersonalRecordCard(
                      exercise: record.key,
                      weight: record.value,
                      date: findPRDate(
                        workouts,
                        record.key,
                        record.value,
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 32),

            const SectionTitle(
              title: "Recent Training",
              subtitle:
                  "Your latest workout volume",
            ),

            const SizedBox(height: 14),

            if (workouts.isEmpty)
              const EmptySectionCard(
                icon: Icons.bar_chart_outlined,
                title: "Nothing to chart yet",
                message:
                    "Your recent workout volume will appear here.",
              )
            else
              WorkoutVolumeChart(
                workouts: workouts,
              ),

            const SizedBox(height: 32),

            const SectionTitle(
              title: "Body Weight",
              subtitle: "Current body measurement",
            ),

            const SizedBox(height: 14),

            CurrentWeightCard(
              weight: appState.profile.weight,
            ),

            const SizedBox(height: 32),

            const SectionTitle(
              title: "Training Summary",
              subtitle: "All recorded workouts",
            ),

            const SizedBox(height: 14),

            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 22,
                  horizontal: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SummaryMetric(
                        value:
                            "${appState.totalWorkouts}",
                        label: "Sessions",
                      ),
                    ),

                    const SummaryDivider(),

                    Expanded(
                      child: SummaryMetric(
                        value: formatTrainingTime(
                          appState.totalTrainingSeconds,
                        ),
                        label: "Training",
                      ),
                    ),

                    const SummaryDivider(),

                    Expanded(
                      child: SummaryMetric(
                        value: formatCompactVolume(
                          appState.totalVolume,
                        ),
                        label: "Volume",
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 22,
                  horizontal: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SummaryMetric(
                        value:
                            "${appState.workoutsThisWeek.length}",
                        label: "This Week",
                      ),
                    ),

                    const SummaryDivider(),

                    Expanded(
                      child: SummaryMetric(
                        value: formatTrainingTime(
                          appState.weeklyTrainingSeconds,
                        ),
                        label: "Week Time",
                      ),
                    ),

                    const SummaryDivider(),

                    Expanded(
                      child: SummaryMetric(
                        value: formatCompactVolume(
                          appState.weeklyVolume,
                        ),
                        label: "Week Volume",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StrengthProgressSection extends StatelessWidget {
  final List<WorkoutData> workouts;

  const StrengthProgressSection({
    super.key,
    required this.workouts,
  });

  @override
  Widget build(BuildContext context) {
    final progress = calculateExerciseProgress(
      workouts,
    );

    final entries = progress.entries.toList()
      ..sort(
        (a, b) =>
            b.value.current.compareTo(a.value.current),
      );

    if (entries.isEmpty) {
      return const EmptySectionCard(
        icon: Icons.insights_outlined,
        title: "No strength data yet",
        message:
            "Complete weighted sets to start tracking your strength.",
      );
    }

    return Column(
      children: List.generate(
        entries.length,
        (index) {
          final entry = entries[index];
          final data = entry.value;

          return Padding(
            padding: EdgeInsets.only(
              bottom:
                  index == entries.length - 1 ? 0 : 12,
            ),
            child: StrengthProgressCard(
              exercise: entry.key,
              firstWeight: data.first,
              currentWeight: data.current,
            ),
          );
        },
      ),
    );
  }
}

class StrengthProgressData {
  final double first;
  final double current;

  const StrengthProgressData({
    required this.first,
    required this.current,
  });
}

Map<String, StrengthProgressData>
    calculateExerciseProgress(
  List<WorkoutData> workouts,
) {
  final chronological = [...workouts]
    ..sort(
      (a, b) => a.date.compareTo(b.date),
    );

  final firstRecords = <String, double>{};
  final currentRecords = <String, double>{};
  final displayNames = <String, String>{};

  for (final workout in chronological) {
    for (final exercise in workout.exercises) {
      if (exercise.sets.isEmpty) continue;

      final key =
          exercise.name.trim().toLowerCase();

      if (key.isEmpty) continue;

      displayNames[key] ??= exercise.name.trim();

      final best = exercise.bestWeight;

      firstRecords.putIfAbsent(
        key,
        () => best,
      );

      final currentBest =
          currentRecords[key] ?? 0;

      if (best > currentBest) {
        currentRecords[key] = best;
      }
    }
  }

  final result =
      <String, StrengthProgressData>{};

  for (final key in currentRecords.keys) {
    result[displayNames[key] ?? key] =
        StrengthProgressData(
      first: firstRecords[key] ?? 0,
      current: currentRecords[key] ?? 0,
    );
  }

  return result;
}

class StrengthProgressCard extends StatelessWidget {
  final String exercise;
  final double firstWeight;
  final double currentWeight;

  const StrengthProgressCard({
    super.key,
    required this.exercise,
    required this.firstWeight,
    required this.currentWeight,
  });

  double get increase =>
      currentWeight - firstWeight;

  double get percentageIncrease {
    if (firstWeight <= 0) return 0;

    return (increase / firstWeight) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final improved = increase > 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundColor: Color(0xFF341010),
              child: Icon(
                Icons.fitness_center,
                color: Colors.red,
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "${formatNumber(firstWeight)} kg  →  "
                    "${formatNumber(currentWeight)} kg",
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.end,
              children: [
                Text(
                  improved
                      ? "+${formatNumber(increase)} kg"
                      : "Baseline",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: improved
                        ? Colors.green
                        : Colors.grey,
                  ),
                ),

                if (improved) ...[
                  const SizedBox(height: 4),

                  Text(
                    "+${percentageIncrease.toStringAsFixed(1)}%",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class WorkoutVolumeChart extends StatelessWidget {
  final List<WorkoutData> workouts;

  const WorkoutVolumeChart({
    super.key,
    required this.workouts,
  });

  @override
  Widget build(BuildContext context) {
    final recent = workouts.take(7).toList()
      ..sort(
        (a, b) => a.date.compareTo(b.date),
      );

    double maxVolume = 0;

    for (final workout in recent) {
      if (workout.totalVolume > maxVolume) {
        maxVolume = workout.totalVolume;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          18,
          22,
          18,
          18,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Workout Volume",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Text(
                  "${recent.length} recent",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            const Text(
              "Total completed-set volume per workout",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              height: 170,
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: List.generate(
                  recent.length,
                  (index) {
                    final workout = recent[index];

                    final ratio = maxVolume <= 0
                        ? 0.0
                        : workout.totalVolume /
                            maxVolume;

                    final barHeight =
                        30 + (ratio * 95);

                    return Expanded(
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 5,
                        ),
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.end,
                          children: [
                            FittedBox(
                              child: Text(
                                formatCompactVolume(
                                  workout.totalVolume,
                                ),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                              ),
                            ),

                            const SizedBox(height: 6),

                            Container(
                              height: barHeight,
                              decoration: BoxDecoration(
                                color: index ==
                                        recent.length - 1
                                    ? Colors.red
                                    : const Color(
                                        0xFF5A2525,
                                      ),
                                borderRadius:
                                    BorderRadius.circular(
                                  6,
                                ),
                              ),
                            ),

                            const SizedBox(height: 7),

                            Text(
                              formatShortDate(
                                workout.date,
                              ),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CurrentWeightCard extends StatelessWidget {
  final double weight;

  const CurrentWeightCard({
    super.key,
    required this.weight,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.red.withValues(
                  alpha: 0.12,
                ),
                borderRadius:
                    BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.monitor_weight_outlined,
                color: Colors.red,
                size: 30,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    "${formatNumber(weight)} kg",
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    "Current body weight",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const Tooltip(
              message:
                  "Weight history will be available after persistence is added.",
              child: Icon(
                Icons.info_outline,
                color: Colors.grey,
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
  final DateTime? date;

  const PersonalRecordCard({
    super.key,
    required this.exercise,
    required this.weight,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 7,
        ),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF352900),
          child: Icon(
            Icons.emoji_events,
            color: Colors.amber,
          ),
        ),
        title: Text(
          exercise,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          date == null
              ? "Personal record"
              : formatFullDate(date!),
        ),
        trailing: Text(
          "${formatNumber(weight)} kg",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.amber,
          ),
        ),
      ),
    );
  }
}

class ProgressStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const ProgressStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: Colors.red,
              size: 27,
            ),

            const SizedBox(height: 17),

            FittedBox(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 4),

            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const SectionTitle({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          subtitle,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class EmptySectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const EmptySectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 30,
          horizontal: 20,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.grey,
              size: 38,
            ),

            const SizedBox(height: 14),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              message,
              textAlign: TextAlign.center,
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

class SummaryMetric extends StatelessWidget {
  final String value;
  final String label;

  const SummaryMetric({
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
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 5),

        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class SummaryDivider extends StatelessWidget {
  const SummaryDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      width: 1,
      color: const Color(0xFF444444),
    );
  }
}

DateTime? findPRDate(
  List<WorkoutData> workouts,
  String exerciseName,
  double record,
) {
  WorkoutData? matchingWorkout;

  for (final workout in workouts) {
    for (final exercise in workout.exercises) {
      if (exercise.name.toLowerCase() !=
          exerciseName.toLowerCase()) {
        continue;
      }

      final hitRecord = exercise.sets.any(
        (set) => set.weight == record,
      );

      if (hitRecord) {
        if (matchingWorkout == null ||
            workout.date.isAfter(
              matchingWorkout.date,
            )) {
          matchingWorkout = workout;
        }
      }
    }
  }

  return matchingWorkout?.date;
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

String formatShortDate(DateTime date) {
  return "${date.day}/${date.month}";
}

String formatFullDate(DateTime date) {
  const months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  return "${date.day} "
      "${months[date.month - 1]} "
      "${date.year}";
}

String formatNumber(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }

  return value.toStringAsFixed(1);
}