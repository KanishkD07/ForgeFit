import 'package:fl_chart/fl_chart.dart';
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

  String? _selectedExercise;

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
    final profile = appState.profile;

    if (profile == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final workouts = appState.workouts;
    final exerciseNames = getExerciseNames(workouts);

    if (exerciseNames.isNotEmpty &&
        (_selectedExercise == null ||
            !exerciseNames.contains(_selectedExercise))) {
      _selectedExercise = exerciseNames.first;
    }

    final selectedExercise = _selectedExercise;

    final sessions = selectedExercise == null
        ? <ExerciseSessionData>[]
        : buildExerciseSessions(
            workouts,
            selectedExercise,
          );

    final records = appState.personalRecords;

    final sortedRecords = records.entries.toList()
      ..sort(
        (a, b) => b.value.compareTo(a.value),
      );

    final exerciseAnalytics =
        buildExerciseAnalytics(workouts);

    final trainingInsights = buildTrainingInsights(
      workouts,
      exerciseAnalytics,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Progress',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            appState.loadProfile(),
            appState.loadWorkouts(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                'Your Progress',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Track strength, volume, consistency and personal records.',
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
                          '${formatNumber(profile.weight)} kg',
                      label: 'Body Weight',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ProgressStatCard(
                      icon: Icons.fitness_center,
                      value: '${appState.totalWorkouts}',
                      label: 'Workouts',
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
                      label: 'Total Volume',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ProgressStatCard(
                      icon: Icons.emoji_events_outlined,
                      value:
                          '${appState.totalPersonalRecords}',
                      label: 'PRs',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 34),

              const SectionTitle(
                title: 'Exercise Progress',
                subtitle:
                    'Detailed performance analytics for every movement',
              ),

              const SizedBox(height: 14),

              if (exerciseNames.isEmpty)
                const EmptySectionCard(
                  icon: Icons.show_chart_rounded,
                  title: 'No strength data yet',
                  message:
                      'Complete weighted exercises to start tracking your progress.',
                )
              else ...[
                ExerciseSelector(
                  exercises: exerciseNames,
                  selectedExercise: selectedExercise!,
                  onChanged: (value) {
                    setState(() {
                      _selectedExercise = value;
                    });
                  },
                ),
                const SizedBox(height: 14),
                ExerciseAnalyticsDetailCard(
                  exercise: selectedExercise,
                  sessions: sessions,
                ),
              ],

              const SizedBox(height: 34),

              const SectionTitle(
                title: 'Training Trends',
                subtitle:
                    'See how your training changes week by week',
              ),

              const SizedBox(height: 14),

              TrainingTrendsCard(
                workouts: workouts,
              ),

              const SizedBox(height: 34),

              const SectionTitle(
                title: 'Exercise Analytics',
                subtitle:
                    'See which movements make up your training',
              ),

              const SizedBox(height: 14),

              if (exerciseAnalytics.isEmpty)
                const EmptySectionCard(
                  icon: Icons.leaderboard_outlined,
                  title: 'No exercise analytics yet',
                  message:
                      'Complete workouts to build your exercise breakdown.',
                )
              else
                ExerciseBreakdownCard(
                  analytics: exerciseAnalytics,
                ),

              const SizedBox(height: 34),

              const SectionTitle(
                title: 'Training Insights',
                subtitle:
                    'Useful takeaways from your recorded training',
              ),

              const SizedBox(height: 14),

              if (trainingInsights.isEmpty)
                const EmptySectionCard(
                  icon: Icons.lightbulb_outline_rounded,
                  title: 'More training needed',
                  message:
                      'Record a few workouts and ForgeFit will start finding patterns.',
                )
              else
                TrainingInsightsCard(
                  insights: trainingInsights,
                ),

              const SizedBox(height: 34),

              const SectionTitle(
                title: 'Personal Records',
                subtitle: 'Your heaviest completed sets',
              ),

              const SizedBox(height: 14),

              if (sortedRecords.isEmpty)
                const EmptySectionCard(
                  icon: Icons.emoji_events_outlined,
                  title: 'No personal records yet',
                  message:
                      'Your best lifts will appear here after a workout.',
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

              const SizedBox(height: 34),

              const SectionTitle(
                title: 'Recent Training',
                subtitle: 'Your latest workout volume',
              ),

              const SizedBox(height: 14),

              if (workouts.isEmpty)
                const EmptySectionCard(
                  icon: Icons.bar_chart_outlined,
                  title: 'Nothing to chart yet',
                  message:
                      'Your recent workout volume will appear here.',
                )
              else
                WorkoutVolumeChart(
                  workouts: workouts,
                ),

              const SizedBox(height: 34),

              const SectionTitle(
                title: 'Body Weight',
                subtitle: 'Current body measurement',
              ),

              const SizedBox(height: 14),

              CurrentWeightCard(
                weight: profile.weight,
              ),

              const SizedBox(height: 34),

              const SectionTitle(
                title: 'Training Summary',
                subtitle: 'All recorded workouts',
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
                          value: '${appState.totalWorkouts}',
                          label: 'Sessions',
                        ),
                      ),
                      const SummaryDivider(),
                      Expanded(
                        child: SummaryMetric(
                          value: formatTrainingTime(
                            appState.totalTrainingSeconds,
                          ),
                          label: 'Training',
                        ),
                      ),
                      const SummaryDivider(),
                      Expanded(
                        child: SummaryMetric(
                          value: formatCompactVolume(
                            appState.totalVolume,
                          ),
                          label: 'Volume',
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
                              '${appState.workoutsThisWeek.length}',
                          label: 'This Week',
                        ),
                      ),
                      const SummaryDivider(),
                      Expanded(
                        child: SummaryMetric(
                          value: formatTrainingTime(
                            appState.weeklyTrainingSeconds,
                          ),
                          label: 'Week Time',
                        ),
                      ),
                      const SummaryDivider(),
                      Expanded(
                        child: SummaryMetric(
                          value: formatCompactVolume(
                            appState.weeklyVolume,
                          ),
                          label: 'Week Volume',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================
// EXERCISE SESSION ANALYTICS
// =====================================================

class ExerciseSessionData {
  final DateTime date;
  final List<WorkoutSetData> sets;

  const ExerciseSessionData({
    required this.date,
    required this.sets,
  });

  double get bestWeight {
    if (sets.isEmpty) return 0;

    return sets
        .map((set) => set.weight)
        .reduce((a, b) => a > b ? a : b);
  }

  double get volume {
    return sets.fold(
      0,
      (total, set) => total + set.volume,
    );
  }

  int get reps {
    return sets.fold(
      0,
      (total, set) => total + set.reps,
    );
  }
}

List<String> getExerciseNames(
  List<WorkoutData> workouts,
) {
  final names = <String, String>{};

  for (final workout in workouts) {
    for (final exercise in workout.exercises) {
      final name = exercise.name.trim();

      if (name.isEmpty || exercise.sets.isEmpty) {
        continue;
      }

      names[name.toLowerCase()] ??= name;
    }
  }

  final result = names.values.toList();

  result.sort(
    (a, b) =>
        a.toLowerCase().compareTo(b.toLowerCase()),
  );

  return result;
}

List<ExerciseSessionData> buildExerciseSessions(
  List<WorkoutData> workouts,
  String exerciseName,
) {
  final sessions = <ExerciseSessionData>[];

  final chronological = [...workouts]
    ..sort(
      (a, b) => a.date.compareTo(b.date),
    );

  for (final workout in chronological) {
    final matchingSets = <WorkoutSetData>[];

    for (final exercise in workout.exercises) {
      if (exercise.name.trim().toLowerCase() !=
          exerciseName.trim().toLowerCase()) {
        continue;
      }

      matchingSets.addAll(exercise.sets);
    }

    if (matchingSets.isNotEmpty) {
      sessions.add(
        ExerciseSessionData(
          date: workout.date,
          sets: matchingSets,
        ),
      );
    }
  }

  return sessions;
}

class ExerciseSelector extends StatelessWidget {
  final List<String> exercises;
  final String selectedExercise;
  final ValueChanged<String> onChanged;

  const ExerciseSelector({
    super.key,
    required this.exercises,
    required this.selectedExercise,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedExercise,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Exercise',
        prefixIcon: Icon(
          Icons.fitness_center,
        ),
        border: OutlineInputBorder(),
      ),
      items: exercises.map(
        (exercise) {
          return DropdownMenuItem(
            value: exercise,
            child: Text(
              exercise,
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ).toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}

class ExerciseAnalyticsDetailCard
    extends StatelessWidget {
  final String exercise;
  final List<ExerciseSessionData> sessions;

  const ExerciseAnalyticsDetailCard({
    super.key,
    required this.exercise,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const EmptySectionCard(
        icon: Icons.show_chart,
        title: 'No exercise data',
        message:
            'Complete this exercise to start tracking it.',
      );
    }

    final starting = sessions.first.bestWeight;
    final latest = sessions.last.bestWeight;

    double currentPR = 0;

    for (final session in sessions) {
      if (session.bestWeight > currentPR) {
        currentPR = session.bestWeight;
      }
    }

    double previousPR = 0;

    for (final session in sessions) {
      if (session.bestWeight < currentPR &&
          session.bestWeight > previousPR) {
        previousPR = session.bestWeight;
      }
    }

    final prGain = previousPR > 0
        ? currentPR - previousPR
        : 0.0;

    final overallGain = latest - starting;

    final overallPercent = starting > 0
        ? (overallGain / starting) * 100
        : 0.0;

    final totalSets = sessions.fold<int>(
      0,
      (total, session) =>
          total + session.sets.length,
    );

    final totalReps = sessions.fold<int>(
      0,
      (total, session) => total + session.reps,
    );

    final totalVolume = sessions.fold<double>(
      0,
      (total, session) => total + session.volume,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          18,
          20,
          18,
          20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    exercise,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ProgressChangeBadge(
                  change: overallGain,
                  percentage: overallPercent,
                ),
              ],
            ),

            const SizedBox(height: 6),

            Text(
              '${sessions.length} '
              '${sessions.length == 1 ? 'session' : 'sessions'} recorded',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: AnalyticsMetric(
                    label: 'Current PR',
                    value:
                        '${formatNumber(currentPR)} kg',
                    highlight: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AnalyticsMetric(
                    label: 'Previous PR',
                    value: previousPR > 0
                        ? '${formatNumber(previousPR)} kg'
                        : '—',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AnalyticsMetric(
                    label: 'PR Gain',
                    value: prGain > 0
                        ? '+${formatNumber(prGain)} kg'
                        : '—',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: AnalyticsMetric(
                    label: 'Starting',
                    value:
                        '${formatNumber(starting)} kg',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AnalyticsMetric(
                    label: 'Latest',
                    value:
                        '${formatNumber(latest)} kg',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AnalyticsMetric(
                    label: 'Volume',
                    value:
                        formatCompactVolume(totalVolume),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: AnalyticsMetric(
                    label: 'Sessions',
                    value: '${sessions.length}',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AnalyticsMetric(
                    label: 'Sets',
                    value: '$totalSets',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AnalyticsMetric(
                    label: 'Reps',
                    value: '$totalReps',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            const ChartHeading(
              title: 'Strength Progress',
              subtitle:
                  'Heaviest completed set per session',
            ),

            const SizedBox(height: 18),

            if (sessions.length < 2)
              const ChartPlaceholder(
                message:
                    'Complete this exercise again to build your strength chart.',
              )
            else
              ExerciseProgressChart(
                sessions: sessions,
                metric: ExerciseChartMetric.weight,
              ),

            const SizedBox(height: 30),

            const ChartHeading(
              title: 'Volume Progress',
              subtitle:
                  'Total weight × reps for each session',
            ),

            const SizedBox(height: 18),

            if (sessions.length < 2)
              const ChartPlaceholder(
                message:
                    'Complete another session to compare training volume.',
              )
            else
              ExerciseProgressChart(
                sessions: sessions,
                metric: ExerciseChartMetric.volume,
              ),

            const SizedBox(height: 30),

            const Text(
              'Recent Performance',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Your latest recorded sessions',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 14),

            ...sessions.reversed
                .take(5)
                .map(
                  (session) =>
                      ExerciseSessionCard(
                    session: session,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class ProgressChangeBadge
    extends StatelessWidget {
  final double change;
  final double percentage;

  const ProgressChangeBadge({
    super.key,
    required this.change,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final colour = change > 0
        ? Colors.green
        : change < 0
            ? Colors.red
            : Colors.grey;

    final icon = change > 0
        ? Icons.trending_up
        : change < 0
            ? Icons.trending_down
            : Icons.trending_flat;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: colour.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: colour,
          ),
          const SizedBox(width: 5),
          Text(
            change == 0
                ? 'No change'
                : '${change > 0 ? '+' : ''}'
                    '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              color: colour,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class AnalyticsMetric extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const AnalyticsMetric({
    super.key,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: highlight
                    ? Colors.amber
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class ChartHeading extends StatelessWidget {
  final String title;
  final String subtitle;

  const ChartHeading({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class ChartPlaceholder extends StatelessWidget {
  final String message;

  const ChartPlaceholder({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.show_chart_rounded,
            color: Colors.grey,
            size: 36,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

enum ExerciseChartMetric {
  weight,
  volume,
}

class ExerciseProgressChart extends StatelessWidget {
  final List<ExerciseSessionData> sessions;
  final ExerciseChartMetric metric;

  const ExerciseProgressChart({
    super.key,
    required this.sessions,
    required this.metric,
  });

  double valueFor(
    ExerciseSessionData session,
  ) {
    switch (metric) {
      case ExerciseChartMetric.weight:
        return session.bestWeight;
      case ExerciseChartMetric.volume:
        return session.volume;
    }
  }

  @override
  Widget build(BuildContext context) {
    final values =
        sessions.map(valueFor).toList();

    double minValue = values.first;
    double maxValue = values.first;

    for (final value in values) {
      if (value < minValue) minValue = value;
      if (value > maxValue) maxValue = value;
    }

    double padding =
        (maxValue - minValue) * 0.25;

    if (metric == ExerciseChartMetric.weight) {
      if (padding < 5) padding = 5;
    } else {
      if (padding < 100) padding = 100;
    }

    final minY = (minValue - padding)
        .clamp(0, double.infinity)
        .toDouble();

    final maxY = maxValue + padding;

    final interval =
        calculateInterval(minY, maxY);

    final spots = List.generate(
      sessions.length,
      (index) => FlSpot(
        index.toDouble(),
        values[index],
      ),
    );

    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX:
              (sessions.length - 1).toDouble(),
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: interval,
            getDrawingHorizontalLine: (_) {
              return const FlLine(
                color: Color(0xFF333333),
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(
            show: false,
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 46,
                interval: interval,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      metric ==
                              ExerciseChartMetric
                                  .volume
                          ? formatCompactVolume(
                              value,
                            )
                          : formatNumber(value),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 9,
                      ),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 34,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();

                  if (index < 0 ||
                      index >= sessions.length ||
                      !shouldShowDate(
                        index,
                        sessions.length,
                      )) {
                    return const SizedBox.shrink();
                  }

                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      formatShortDate(
                        sessions[index].date,
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 9,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData:
                LineTouchTooltipData(
              getTooltipItems: (spots) {
                return spots.map(
                  (spot) {
                    final session =
                        sessions[spot.x.toInt()];

                    final value =
                        valueFor(session);

                    final text = metric ==
                            ExerciseChartMetric.weight
                        ? '${formatNumber(value)} kg'
                        : '${formatCompactVolume(value)} kg';

                    return LineTooltipItem(
                      '$text\n',
                      const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: formatFullDate(
                            session.date,
                          ),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                            fontWeight:
                                FontWeight.normal,
                          ),
                        ),
                      ],
                    );
                  },
                ).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: false,
              barWidth: 3,
              color: Colors.red,
              dotData: FlDotData(
                show: true,
                getDotPainter: (
                  spot,
                  percent,
                  barData,
                  index,
                ) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.red,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.red.withValues(
                  alpha: 0.08,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExerciseSessionCard
    extends StatelessWidget {
  final ExerciseSessionData session;

  const ExerciseSessionCard({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  formatFullDate(session.date),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                '${formatCompactVolume(session.volume)} kg',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              session.sets.length,
              (index) {
                final set = session.sets[index];

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF242424),
                    borderRadius:
                        BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${index + 1}. '
                    '${formatNumber(set.weight)} kg × '
                    '${set.reps}',
                    style: const TextStyle(
                      fontSize: 11,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// WEEKLY TRAINING TRENDS
// =====================================================

enum TrainingTrendMetric {
  workouts,
  volume,
  time,
}

class WeeklyTrainingData {
  final DateTime weekStart;
  final int workouts;
  final double volume;
  final int trainingSeconds;

  const WeeklyTrainingData({
    required this.weekStart,
    required this.workouts,
    required this.volume,
    required this.trainingSeconds,
  });
}

class TrainingTrendsCard extends StatefulWidget {
  final List<WorkoutData> workouts;

  const TrainingTrendsCard({
    super.key,
    required this.workouts,
  });

  @override
  State<TrainingTrendsCard> createState() =>
      _TrainingTrendsCardState();
}

class _TrainingTrendsCardState
    extends State<TrainingTrendsCard> {
  TrainingTrendMetric selectedMetric =
      TrainingTrendMetric.workouts;

  @override
  Widget build(BuildContext context) {
    final weeks =
        buildWeeklyTrainingData(widget.workouts);

    final current = weeks.last;

    final previous = weeks.length > 1
        ? weeks[weeks.length - 2]
        : null;

    final currentValue =
        trendValue(current, selectedMetric);

    final previousValue = previous == null
        ? 0.0
        : trendValue(previous, selectedMetric);

    final change = previous == null
        ? null
        : calculateTrendChange(
            currentValue,
            previousValue,
          );

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          18,
          20,
          18,
          18,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Training',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Last 8 weeks',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                TrendChoice(
                  label: 'Workouts',
                  selected: selectedMetric ==
                      TrainingTrendMetric.workouts,
                  onTap: () {
                    setState(() {
                      selectedMetric =
                          TrainingTrendMetric.workouts;
                    });
                  },
                ),
                TrendChoice(
                  label: 'Volume',
                  selected: selectedMetric ==
                      TrainingTrendMetric.volume,
                  onTap: () {
                    setState(() {
                      selectedMetric =
                          TrainingTrendMetric.volume;
                    });
                  },
                ),
                TrendChoice(
                  label: 'Time',
                  selected: selectedMetric ==
                      TrainingTrendMetric.time,
                  onTap: () {
                    setState(() {
                      selectedMetric =
                          TrainingTrendMetric.time;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'This Week',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        formatTrendValue(
                          current,
                          selectedMetric,
                        ),
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (change != null)
                  TrendChangeBadge(
                    percentage: change,
                  ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 240,
              child: WeeklyTrainingChart(
                weeks: weeks,
                metric: selectedMetric,
              ),
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 15,
                  color: Colors.grey,
                ),
                SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Weeks run from Monday to Sunday.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
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

class TrendChoice extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const TrendChoice({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      selectedColor:
          Colors.red.withValues(alpha: 0.20),
      labelStyle: TextStyle(
        color: selected ? Colors.red : Colors.grey,
        fontWeight: selected
            ? FontWeight.bold
            : FontWeight.normal,
      ),
      side: BorderSide(
        color: selected
            ? Colors.red
            : const Color(0xFF444444),
      ),
    );
  }
}

class TrendChangeBadge extends StatelessWidget {
  final double percentage;

  const TrendChangeBadge({
    super.key,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final positive = percentage > 0;
    final negative = percentage < 0;

    final colour = positive
        ? Colors.green
        : negative
            ? Colors.red
            : Colors.grey;

    final icon = positive
        ? Icons.trending_up
        : negative
            ? Icons.trending_down
            : Icons.trending_flat;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: colour.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: colour,
          ),
          const SizedBox(width: 5),
          Text(
            '${positive ? '+' : ''}'
            '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              color: colour,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class WeeklyTrainingChart extends StatelessWidget {
  final List<WeeklyTrainingData> weeks;
  final TrainingTrendMetric metric;

  const WeeklyTrainingChart({
    super.key,
    required this.weeks,
    required this.metric,
  });

  @override
  Widget build(BuildContext context) {
    final values = weeks
        .map(
          (week) => trendValue(week, metric),
        )
        .toList();

    double maxValue = 0;

    for (final value in values) {
      if (value > maxValue) {
        maxValue = value;
      }
    }

    if (maxValue <= 0) {
      maxValue = 1;
    }

    final maxY = maxValue * 1.25;

    final interval =
        calculateTrendInterval(maxY, metric);

    return BarChart(
      BarChartData(
        minY: 0,
        maxY: maxY,
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (_) {
            return const FlLine(
              color: Color(0xFF333333),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(
          show: false,
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              interval: interval,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    formatTrendAxisValue(
                      value,
                      metric,
                    ),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 9,
                    ),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();

                if (index < 0 ||
                    index >= weeks.length) {
                  return const SizedBox.shrink();
                }

                final week = weeks[index];

                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    '${week.weekStart.day}/'
                    '${week.weekStart.month}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 9,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (
              group,
              groupIndex,
              rod,
              rodIndex,
            ) {
              final week = weeks[groupIndex];

              return BarTooltipItem(
                '${formatWeekRange(week.weekStart)}\n',
                const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: formatTrendValue(
                      week,
                      metric,
                    ),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        barGroups: List.generate(
          weeks.length,
          (index) {
            final value = values[index];

            final isCurrent =
                index == weeks.length - 1;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: value,
                  width: 18,
                  borderRadius:
                      const BorderRadius.vertical(
                    top: Radius.circular(5),
                  ),
                  color: isCurrent
                      ? Colors.red
                      : const Color(0xFF6A2929),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// =====================================================
// EXERCISE BREAKDOWN
// =====================================================

class ExerciseAnalyticsData {
  final String name;
  final int workoutCount;
  final int setCount;
  final int repCount;
  final double volume;
  final double bestWeight;
  final DateTime latestDate;

  const ExerciseAnalyticsData({
    required this.name,
    required this.workoutCount,
    required this.setCount,
    required this.repCount,
    required this.volume,
    required this.bestWeight,
    required this.latestDate,
  });
}

List<ExerciseAnalyticsData> buildExerciseAnalytics(
  List<WorkoutData> workouts,
) {
  final names = <String, String>{};
  final workoutCounts = <String, int>{};
  final setCounts = <String, int>{};
  final repCounts = <String, int>{};
  final volumes = <String, double>{};
  final bestWeights = <String, double>{};
  final latestDates = <String, DateTime>{};

  for (final workout in workouts) {
    final seen = <String>{};

    for (final exercise in workout.exercises) {
      final name = exercise.name.trim();

      if (name.isEmpty || exercise.sets.isEmpty) {
        continue;
      }

      final key = name.toLowerCase();

      names[key] ??= name;

      setCounts[key] =
          (setCounts[key] ?? 0) +
              exercise.sets.length;

      final reps = exercise.sets.fold<int>(
        0,
        (total, set) => total + set.reps,
      );

      repCounts[key] =
          (repCounts[key] ?? 0) + reps;

      volumes[key] =
          (volumes[key] ?? 0) +
              exercise.volume;

      if (exercise.bestWeight >
          (bestWeights[key] ?? 0)) {
        bestWeights[key] =
            exercise.bestWeight;
      }

      final latest = latestDates[key];

      if (latest == null ||
          workout.date.isAfter(latest)) {
        latestDates[key] = workout.date;
      }

      if (seen.add(key)) {
        workoutCounts[key] =
            (workoutCounts[key] ?? 0) + 1;
      }
    }
  }

  final result = names.entries.map(
    (entry) {
      final key = entry.key;

      return ExerciseAnalyticsData(
        name: entry.value,
        workoutCount:
            workoutCounts[key] ?? 0,
        setCount: setCounts[key] ?? 0,
        repCount: repCounts[key] ?? 0,
        volume: volumes[key] ?? 0,
        bestWeight: bestWeights[key] ?? 0,
        latestDate:
            latestDates[key] ?? DateTime.now(),
      );
    },
  ).toList();

  result.sort(
    (a, b) {
      final sessions =
          b.workoutCount.compareTo(a.workoutCount);

      if (sessions != 0) return sessions;

      return b.volume.compareTo(a.volume);
    },
  );

  return result;
}

class ExerciseBreakdownCard
    extends StatelessWidget {
  final List<ExerciseAnalyticsData> analytics;

  const ExerciseBreakdownCard({
    super.key,
    required this.analytics,
  });

  @override
  Widget build(BuildContext context) {
    final visible = analytics.take(6).toList();

    final maxSets = visible.fold<int>(
      0,
      (best, item) =>
          item.setCount > best ? item.setCount : best,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          18,
          20,
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
                    'Exercise Breakdown',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${analytics.length} exercises',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            const Text(
              'Your most frequently trained movements',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 22),

            ...List.generate(
              visible.length,
              (index) {
                final item = visible[index];

                final progress = maxSets == 0
                    ? 0.0
                    : item.setCount / maxSets;

                return Padding(
                  padding: EdgeInsets.only(
                    bottom:
                        index == visible.length - 1
                            ? 0
                            : 18,
                  ),
                  child: ExerciseAnalyticsRow(
                    rank: index + 1,
                    data: item,
                    progress: progress,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ExerciseAnalyticsRow
    extends StatelessWidget {
  final int rank;
  final ExerciseAnalyticsData data;
  final double progress;

  const ExerciseAnalyticsRow({
    super.key,
    required this.rank,
    required this.data,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: rank == 1
                    ? Colors.red.withValues(
                        alpha: 0.15,
                      )
                    : const Color(0xFF181818),
                borderRadius:
                    BorderRadius.circular(8),
              ),
              child: Text(
                '$rank',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: rank == 1
                      ? Colors.red
                      : Colors.grey,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    data.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${data.workoutCount} sessions'
                    ' • ${data.setCount} sets'
                    ' • ${data.repCount} reps',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.end,
              children: [
                Text(
                  '${formatCompactVolume(data.volume)} kg',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'PR ${formatNumber(data.bestWeight)} kg',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor:
                const Color(0xFF242424),
            valueColor:
                const AlwaysStoppedAnimation<Color>(
              Colors.red,
            ),
          ),
        ),
      ],
    );
  }
}

// =====================================================
// INSIGHTS
// =====================================================

class TrainingInsightData {
  final IconData icon;
  final String title;
  final String message;

  const TrainingInsightData({
    required this.icon,
    required this.title,
    required this.message,
  });
}

List<TrainingInsightData> buildTrainingInsights(
  List<WorkoutData> workouts,
  List<ExerciseAnalyticsData> analytics,
) {
  if (workouts.isEmpty) {
    return [];
  }

  final insights = <TrainingInsightData>[];

  final weeks = buildWeeklyTrainingData(workouts);

  final current = weeks.last;

  final previous =
      weeks.length > 1 ? weeks[weeks.length - 2] : null;

  if (current.workouts > 0) {
    insights.add(
      TrainingInsightData(
        icon: Icons.calendar_month_outlined,
        title: 'This week',
        message:
            'You completed ${current.workouts} '
            '${current.workouts == 1 ? 'workout' : 'workouts'} '
            'with ${formatCompactVolume(current.volume)} kg of recorded volume.',
      ),
    );
  }

  if (previous != null &&
      previous.volume > 0 &&
      current.volume > 0) {
    final change = calculateTrendChange(
      current.volume,
      previous.volume,
    );

    if (change.abs() >= 5) {
      insights.add(
        TrainingInsightData(
          icon: change > 0
              ? Icons.trending_up
              : Icons.trending_down,
          title: 'Weekly volume',
          message: change > 0
              ? 'Your volume is ${change.abs().toStringAsFixed(1)}% higher than last week.'
              : 'Your volume is ${change.abs().toStringAsFixed(1)}% lower than last week.',
        ),
      );
    }
  }

  if (analytics.isNotEmpty) {
    final mostTrained = analytics.first;

    insights.add(
      TrainingInsightData(
        icon: Icons.fitness_center,
        title: 'Most trained exercise',
        message:
            '${mostTrained.name} leads with '
            '${mostTrained.workoutCount} sessions and '
            '${mostTrained.setCount} completed sets.',
      ),
    );

    final volumeLeaders = [...analytics]
      ..sort(
        (a, b) => b.volume.compareTo(a.volume),
      );

    final leader = volumeLeaders.first;

    if (leader.volume > 0) {
      insights.add(
        TrainingInsightData(
          icon: Icons.bar_chart_rounded,
          title: 'Volume leader',
          message:
              '${leader.name} has generated the most volume at '
              '${formatCompactVolume(leader.volume)} kg.',
        ),
      );
    }
  }

  return insights.take(4).toList();
}

class TrainingInsightsCard extends StatelessWidget {
  final List<TrainingInsightData> insights;

  const TrainingInsightsCard({
    super.key,
    required this.insights,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          18,
          20,
          18,
          18,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.auto_awesome_outlined,
                  color: Colors.red,
                  size: 22,
                ),
                SizedBox(width: 9),
                Text(
                  'ForgeFit Insights',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ...List.generate(
              insights.length,
              (index) {
                final insight = insights[index];

                return Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(
                    bottom:
                        index == insights.length - 1
                            ? 0
                            : 12,
                  ),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF181818),
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                        child: Icon(
                          insight.icon,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              insight.title,
                              style: const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              insight.message,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// PERSONAL RECORDS
// =====================================================

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
              ? 'Personal record'
              : formatFullDate(date!),
        ),
        trailing: Text(
          '${formatNumber(weight)} kg',
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

// =====================================================
// RECENT WORKOUT VOLUME
// =====================================================

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
                    'Workout Volume',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${recent.length} recent',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Total completed-set volume per workout',
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

// =====================================================
// BODY WEIGHT
// =====================================================

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
                    '${formatNumber(weight)} kg',
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Current body weight',
                    style: TextStyle(
                      color: Colors.grey,
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

// =====================================================
// SHARED UI
// =====================================================

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
          crossAxisAlignment: CrossAxisAlignment.start,
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
      crossAxisAlignment: CrossAxisAlignment.start,
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
  const SummaryDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      width: 1,
      color: const Color(0xFF444444),
    );
  }
}

// =====================================================
// HELPERS
// =====================================================

List<WeeklyTrainingData> buildWeeklyTrainingData(
  List<WorkoutData> workouts,
) {
  final now = DateTime.now();

  final today = DateTime(
    now.year,
    now.month,
    now.day,
  );

  final currentWeekStart = today.subtract(
    Duration(
      days: today.weekday - 1,
    ),
  );

  final weeks = <WeeklyTrainingData>[];

  for (int offset = 7;
      offset >= 0;
      offset--) {
    final start = currentWeekStart.subtract(
      Duration(
        days: offset * 7,
      ),
    );

    final end = start.add(
      const Duration(days: 7),
    );

    final weekWorkouts = workouts.where(
      (workout) {
        return !workout.date.isBefore(start) &&
            workout.date.isBefore(end);
      },
    ).toList();

    final volume = weekWorkouts.fold<double>(
      0,
      (total, workout) =>
          total + workout.totalVolume,
    );

    final seconds = weekWorkouts.fold<int>(
      0,
      (total, workout) =>
          total + workout.durationSeconds,
    );

    weeks.add(
      WeeklyTrainingData(
        weekStart: start,
        workouts: weekWorkouts.length,
        volume: volume,
        trainingSeconds: seconds,
      ),
    );
  }

  return weeks;
}

double trendValue(
  WeeklyTrainingData week,
  TrainingTrendMetric metric,
) {
  switch (metric) {
    case TrainingTrendMetric.workouts:
      return week.workouts.toDouble();

    case TrainingTrendMetric.volume:
      return week.volume;

    case TrainingTrendMetric.time:
      return week.trainingSeconds / 3600;
  }
}

String formatTrendValue(
  WeeklyTrainingData week,
  TrainingTrendMetric metric,
) {
  switch (metric) {
    case TrainingTrendMetric.workouts:
      return '${week.workouts} '
          '${week.workouts == 1 ? 'workout' : 'workouts'}';

    case TrainingTrendMetric.volume:
      return '${formatCompactVolume(week.volume)} kg';

    case TrainingTrendMetric.time:
      return formatTrainingTime(
        week.trainingSeconds,
      );
  }
}

double calculateTrendChange(
  double current,
  double previous,
) {
  if (previous == 0) {
    return current == 0 ? 0 : 100;
  }

  return ((current - previous) / previous) * 100;
}

double calculateTrendInterval(
  double maxY,
  TrainingTrendMetric metric,
) {
  switch (metric) {
    case TrainingTrendMetric.workouts:
      return maxY <= 5 ? 1 : 2;

    case TrainingTrendMetric.volume:
      if (maxY <= 5000) return 1000;
      if (maxY <= 15000) return 2500;
      if (maxY <= 50000) return 10000;
      return 25000;

    case TrainingTrendMetric.time:
      if (maxY <= 5) return 1;
      if (maxY <= 10) return 2;
      return 5;
  }
}

String formatTrendAxisValue(
  double value,
  TrainingTrendMetric metric,
) {
  switch (metric) {
    case TrainingTrendMetric.workouts:
      return value.round().toString();

    case TrainingTrendMetric.volume:
      if (value >= 1000) {
        return '${(value / 1000).toStringAsFixed(0)}k';
      }

      return value.round().toString();

    case TrainingTrendMetric.time:
      return '${formatNumber(value)}h';
  }
}

String formatWeekRange(
  DateTime start,
) {
  final end = start.add(
    const Duration(days: 6),
  );

  return '${start.day}/${start.month}'
      ' – '
      '${end.day}/${end.month}';
}

DateTime? findPRDate(
  List<WorkoutData> workouts,
  String exerciseName,
  double record,
) {
  WorkoutData? match;

  for (final workout in workouts) {
    for (final exercise in workout.exercises) {
      if (exercise.name.trim().toLowerCase() !=
          exerciseName.trim().toLowerCase()) {
        continue;
      }

      if (exercise.sets.any(
        (set) => set.weight == record,
      )) {
        if (match == null ||
            workout.date.isAfter(match.date)) {
          match = workout;
        }
      }
    }
  }

  return match?.date;
}

double calculateInterval(
  double min,
  double max,
) {
  final range = max - min;

  if (range <= 10) return 2;
  if (range <= 25) return 5;
  if (range <= 50) return 10;
  if (range <= 100) return 20;
  if (range <= 500) return 100;
  if (range <= 2000) return 500;
  if (range <= 10000) return 2000;

  return 5000;
}

bool shouldShowDate(
  int index,
  int length,
) {
  if (length <= 5) return true;

  if (index == 0 ||
      index == length - 1) {
    return true;
  }

  final step = (length / 4).ceil();

  return index % step == 0;
}

String formatTrainingTime(
  int seconds,
) {
  final hours = seconds ~/ 3600;
  final minutes =
      (seconds % 3600) ~/ 60;
  final remaining = seconds % 60;

  if (hours > 0) {
    return '${hours}h ${minutes}m';
  }

  if (minutes > 0) {
    return '${minutes}m';
  }

  return '${remaining}s';
}

String formatCompactVolume(
  double volume,
) {
  if (volume >= 1000000) {
    return '${(volume / 1000000).toStringAsFixed(1)}M';
  }

  if (volume >= 1000) {
    return '${(volume / 1000).toStringAsFixed(1)}k';
  }

  return formatNumber(volume);
}

String formatShortDate(
  DateTime date,
) {
  return '${date.day}/${date.month}';
}

String formatFullDate(
  DateTime date,
) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  return '${date.day} '
      '${months[date.month - 1]} '
      '${date.year}';
}

String formatNumber(
  double value,
) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }

  return value.toStringAsFixed(1);
}