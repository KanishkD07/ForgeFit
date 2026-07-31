import 'package:flutter/material.dart';

import '../models/workout.dart';
import '../services/app_state.dart';
import 'workout_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() =>
      _HistoryScreenState();
}

class _HistoryScreenState
    extends State<HistoryScreen> {
  final AppState appState =
      AppState.instance;

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
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openWorkout(
    WorkoutData workout,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            WorkoutDetailScreen(
          workout: workout,
        ),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final workouts =
        appState.workouts;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: appState.loadingWorkouts &&
              workouts.isEmpty
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : workouts.isEmpty
              ? const _EmptyHistory()
              : RefreshIndicator(
                  onRefresh:
                      appState.loadWorkouts,
                  child: ListView.separated(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding:
                        const EdgeInsets
                            .fromLTRB(
                      20,
                      16,
                      20,
                      30,
                    ),
                    itemCount:
                        workouts.length,
                    separatorBuilder:
                        (_, _) =>
                            const SizedBox(
                      height: 12,
                    ),
                    itemBuilder:
                        (context, index) {
                      final workout =
                          workouts[index];

                      return _WorkoutCard(
                        workout: workout,
                        onTap: () {
                          _openWorkout(
                            workout,
                          );
                        },
                      );
                    },
                  ),
                ),
    );
  }
}

class _WorkoutCard
    extends StatelessWidget {
  final WorkoutData workout;
  final VoidCallback onTap;

  const _WorkoutCard({
    required this.workout,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final exerciseCount =
        workout.exercises.length;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding:
              const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration:
                        BoxDecoration(
                      color: Colors.red
                          .withValues(
                        alpha: 0.13,
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(
                        13,
                      ),
                    ),
                    child: const Icon(
                      Icons
                          .fitness_center,
                      color: Colors.red,
                      size: 23,
                    ),
                  ),

                  const SizedBox(
                    width: 14,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          formatHistoryDate(
                            workout.date,
                          ),
                          style:
                              const TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),

                        const SizedBox(
                          height: 4,
                        ),

                        Text(
                          '${formatHistoryTime(workout.date)}'
                          ' • '
                          '$exerciseCount '
                          '${exerciseCount == 1 ? 'exercise' : 'exercises'}',
                          style:
                              const TextStyle(
                            color:
                                Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(
                    Icons
                        .chevron_right_rounded,
                    color: Colors.grey,
                  ),
                ],
              ),

              const SizedBox(
                height: 17,
              ),

              const Divider(
                height: 1,
              ),

              const SizedBox(
                height: 16,
              ),

              Row(
                children: [
                  Expanded(
                    child:
                        _WorkoutStat(
                      icon: Icons
                          .timer_outlined,
                      value:
                          formatHistoryDuration(
                        workout
                            .durationSeconds,
                      ),
                      label:
                          'Duration',
                    ),
                  ),

                  _VerticalDivider(),

                  Expanded(
                    child:
                        _WorkoutStat(
                      icon: Icons
                          .bar_chart_rounded,
                      value:
                          '${formatHistoryNumber(workout.totalVolume)} kg',
                      label:
                          'Volume',
                    ),
                  ),

                  _VerticalDivider(),

                  Expanded(
                    child:
                        _WorkoutStat(
                      icon: Icons
                          .check_circle_outline,
                      value:
                          '${workout.totalSets}',
                      label:
                          workout.totalSets ==
                                  1
                              ? 'Set'
                              : 'Sets',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkoutStat
    extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _WorkoutStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 19,
          color: Colors.red,
        ),

        const SizedBox(
          height: 6,
        ),

        Text(
          value,
          maxLines: 1,
          overflow:
              TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),

        const SizedBox(
          height: 3,
        ),

        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 42,
      color: const Color(
        0xFF333333,
      ),
    );
  }
}

class _EmptyHistory
    extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding:
            const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.red
                    .withValues(
                  alpha: 0.10,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons
                    .history_rounded,
                color: Colors.red,
                size: 48,
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            const Text(
              'No Workouts Yet',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            const Text(
              'Finish your first workout '
              'and it will appear here.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String formatHistoryDate(
  DateTime date,
) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

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

  final difference =
      today.difference(
    workoutDay,
  );

  if (difference.inDays == 0) {
    return 'Today';
  }

  if (difference.inDays == 1) {
    return 'Yesterday';
  }

  if (date.year == now.year) {
    return '${date.day} '
        '${months[date.month - 1]}';
  }

  return '${date.day} '
      '${months[date.month - 1]} '
      '${date.year}';
}

String formatHistoryTime(
  DateTime date,
) {
  final hour =
      date.hour % 12 == 0
          ? 12
          : date.hour % 12;

  final minute =
      date.minute
          .toString()
          .padLeft(
            2,
            '0',
          );

  final period =
      date.hour >= 12
          ? 'PM'
          : 'AM';

  return '$hour:$minute $period';
}

String formatHistoryDuration(
  int seconds,
) {
  final hours =
      seconds ~/ 3600;

  final minutes =
      (seconds % 3600) ~/ 60;

  if (hours > 0) {
    return '${hours}h ${minutes}m';
  }

  if (minutes > 0) {
    return '${minutes}m';
  }

  return '${seconds}s';
}

String formatHistoryNumber(
  double value,
) {
  if (value ==
      value.roundToDouble()) {
    return value
        .toInt()
        .toString();
  }

  return value.toStringAsFixed(1);
}