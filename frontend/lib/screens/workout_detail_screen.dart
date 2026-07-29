import 'package:flutter/material.dart';

import '../models/workout.dart';
import '../services/app_state.dart';
import 'edit_workout_screen.dart';

class WorkoutDetailScreen
    extends StatefulWidget {
  final WorkoutData workout;

  const WorkoutDetailScreen({
    super.key,
    required this.workout,
  });

  @override
  State<WorkoutDetailScreen> createState() =>
      _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState
    extends State<WorkoutDetailScreen> {
  late WorkoutData workout;

  bool _deleting = false;

  @override
  void initState() {
    super.initState();

    workout = widget.workout;
  }

  Future<void> _editWorkout() async {
    final updated =
        await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditWorkoutScreen(
          workout: workout,
        ),
      ),
    );

    if (updated != true || !mounted) {
      return;
    }

    final matchingWorkout =
        AppState.instance.workouts
            .where(
              (item) =>
                  item.id == workout.id,
            )
            .firstOrNull;

    if (matchingWorkout != null) {
      setState(() {
        workout = matchingWorkout;
      });
    }
  }

  Future<void> _deleteWorkout() async {
    if (_deleting) return;

    final shouldDelete =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            "Delete Workout?",
          ),
          content: const Text(
            "This workout will be permanently "
            "removed from your history.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                "Cancel",
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                "Delete",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true ||
        !mounted) {
      return;
    }

    setState(() {
      _deleting = true;
    });

    try {
      await AppState.instance
          .deleteWorkout(
        workout.id,
      );

      if (!mounted) return;

      Navigator.pop(
        context,
        true,
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _deleting = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Couldn't delete workout. "
            "Please try again.",
          ),
        ),
      );

      debugPrint(
        "Workout delete failed: $error",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Workout Details",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  30,
                ),
                children: [
                  _WorkoutHeader(
                    workout: workout,
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  _StatsRow(
                    workout: workout,
                  ),

                  const SizedBox(
                    height: 28,
                  ),

                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Exercises",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),

                      Text(
                        "${workout.exercises.length}",
                        style:
                            const TextStyle(
                          color: Colors.grey,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  ...workout.exercises
                      .asMap()
                      .entries
                      .map(
                    (entry) {
                      return Padding(
                        padding:
                            const EdgeInsets
                                .only(
                          bottom: 14,
                        ),
                        child:
                            _ExerciseCard(
                          exercise:
                              entry.value,
                          number:
                              entry.key + 1,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            Container(
              padding:
                  const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                16,
              ),
              decoration:
                  const BoxDecoration(
                color: Color(0xFF121212),
                border: Border(
                  top: BorderSide(
                    color:
                        Color(0xFF2A2A2A),
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    SizedBox(
                      width: 56,
                      height: 54,
                      child:
                          OutlinedButton(
                        onPressed:
                            _deleting
                                ? null
                                : _deleteWorkout,
                        style:
                            OutlinedButton
                                .styleFrom(
                          padding:
                              EdgeInsets.zero,
                        ),
                        child: _deleting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth:
                                      2,
                                ),
                              )
                            : const Icon(
                                Icons
                                    .delete_outline,
                                color:
                                    Colors.red,
                              ),
                      ),
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child:
                            ElevatedButton.icon(
                          onPressed:
                              _deleting
                                  ? null
                                  : _editWorkout,
                          icon: const Icon(
                            Icons.edit_outlined,
                          ),
                          label: const Text(
                            "Edit Workout",
                            style:
                                TextStyle(
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ),
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

class _WorkoutHeader
    extends StatelessWidget {
  final WorkoutData workout;

  const _WorkoutHeader({
    required this.workout,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color:
                    Colors.red.withValues(
                  alpha: 0.13,
                ),
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
              ),
              child: const Icon(
                Icons.fitness_center,
                color: Colors.red,
                size: 27,
              ),
            ),

            const SizedBox(
              width: 15,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    formatDetailDate(
                      workout.date,
                    ),
                    style:
                        const TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    formatDetailTime(
                      workout.date,
                    ),
                    style:
                        const TextStyle(
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

class _StatsRow
    extends StatelessWidget {
  final WorkoutData workout;

  const _StatsRow({
    required this.workout,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.timer_outlined,
            label: "Duration",
            value: formatDetailDuration(
              workout.durationSeconds,
            ),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _StatCard(
            icon: Icons
                .bar_chart_rounded,
            label: "Volume",
            value:
                "${formatDetailNumber(workout.totalVolume)} kg",
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _StatCard(
            icon: Icons
                .check_circle_outline,
            label: "Sets",
            value:
                "${workout.totalSets}",
          ),
        ),
      ],
    );
  }
}

class _StatCard
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 15,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.red,
              size: 21,
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              value,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 3,
            ),

            Text(
              label,
              style:
                  const TextStyle(
                color: Colors.grey,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseCard
    extends StatelessWidget {
  final ExerciseData exercise;
  final int number;

  const _ExerciseCard({
    required this.exercise,
    required this.number,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      const Color(
                    0xFF341010,
                  ),
                  child: Text(
                    "$number",
                    style:
                        const TextStyle(
                      color: Colors.red,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        exercise.name,
                        style:
                            const TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),

                      const SizedBox(
                        height: 3,
                      ),

                      Text(
                        "${exercise.sets.length} "
                        "${exercise.sets.length == 1 ? "set" : "sets"}"
                        " • "
                        "${formatDetailNumber(exercise.volume)} kg volume",
                        style:
                            const TextStyle(
                          color:
                              Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 16,
            ),

            const Divider(
              height: 1,
            ),

            const SizedBox(
              height: 12,
            ),

            const Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Text(
                    "SET",
                    style:
                        _DetailHeaderStyle
                            .style,
                  ),
                ),

                Expanded(
                  child: Text(
                    "WEIGHT",
                    textAlign:
                        TextAlign.center,
                    style:
                        _DetailHeaderStyle
                            .style,
                  ),
                ),

                Expanded(
                  child: Text(
                    "REPS",
                    textAlign:
                        TextAlign.center,
                    style:
                        _DetailHeaderStyle
                            .style,
                  ),
                ),

                Expanded(
                  child: Text(
                    "VOLUME",
                    textAlign:
                        TextAlign.end,
                    style:
                        _DetailHeaderStyle
                            .style,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 10,
            ),

            ...exercise.sets
                .asMap()
                .entries
                .map(
              (entry) {
                final set =
                    entry.value;

                return Padding(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    vertical: 7,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 50,
                        child: Text(
                          "${entry.key + 1}",
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),

                      Expanded(
                        child: Text(
                          "${formatDetailNumber(set.weight)} kg",
                          textAlign:
                              TextAlign
                                  .center,
                        ),
                      ),

                      Expanded(
                        child: Text(
                          "${set.reps}",
                          textAlign:
                              TextAlign
                                  .center,
                        ),
                      ),

                      Expanded(
                        child: Text(
                          formatDetailNumber(
                            set.volume,
                          ),
                          textAlign:
                              TextAlign.end,
                          style:
                              const TextStyle(
                            color:
                                Colors.grey,
                          ),
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

class _DetailHeaderStyle {
  static const TextStyle style =
      TextStyle(
    color: Colors.grey,
    fontSize: 10,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.6,
  );
}

String formatDetailDate(
  DateTime date,
) {
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

String formatDetailTime(
  DateTime date,
) {
  final hour =
      date.hour % 12 == 0
          ? 12
          : date.hour % 12;

  final minute =
      date.minute
          .toString()
          .padLeft(2, "0");

  final period =
      date.hour >= 12
          ? "PM"
          : "AM";

  return "$hour:$minute $period";
}

String formatDetailDuration(
  int seconds,
) {
  final hours =
      seconds ~/ 3600;

  final minutes =
      (seconds % 3600) ~/ 60;

  if (hours > 0) {
    return "${hours}h ${minutes}m";
  }

  if (minutes > 0) {
    return "${minutes}m";
  }

  return "${seconds}s";
}

String formatDetailNumber(
  double value,
) {
  if (value ==
      value.roundToDouble()) {
    return value.toInt().toString();
  }

  return value.toStringAsFixed(1);
}