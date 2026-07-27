import 'package:flutter/material.dart';

import '../models/workout.dart';
import '../services/app_state.dart';
import 'edit_workout_screen.dart';

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

  String? _deletingWorkoutId;

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

  Future<void> _editWorkout(
    WorkoutData workout,
  ) async {
    if (_deletingWorkoutId != null) {
      return;
    }

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

    if (updated == true && mounted) {
      ScaffoldMessenger.of(context)
          .clearSnackBars();

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Workout updated successfully",
          ),
        ),
      );
    }
  }

  Future<void> _deleteWorkout(
    WorkoutData workout,
  ) async {
    if (_deletingWorkoutId != null) {
      return;
    }

    final shouldDelete =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            "Delete Workout?",
          ),
          content: Text(
            "Delete the workout from "
            "${formatDate(workout.date)}? "
            "This cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child:
                  const Text("Cancel"),
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
      _deletingWorkoutId =
          workout.id;
    });

    try {
      await appState.deleteWorkout(
        workout.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .clearSnackBars();

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Workout deleted",
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .clearSnackBars();

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Couldn't delete workout. "
            "Please check the backend "
            "and try again.",
          ),
        ),
      );

      debugPrint(
        "Workout deletion failed: "
        "$error",
      );
    } finally {
      if (mounted) {
        setState(() {
          _deletingWorkoutId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final workouts =
        appState.workouts;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Workout History",
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
      body: workouts.isEmpty
          ? const EmptyHistoryState()
          : ListView.separated(
              padding:
                  const EdgeInsets
                      .fromLTRB(
                20,
                12,
                20,
                30,
              ),
              itemCount:
                  workouts.length,
              separatorBuilder:
                  (_, __) =>
                      const SizedBox(
                height: 14,
              ),
              itemBuilder:
                  (context, index) {
                final workout =
                    workouts[index];

                return WorkoutHistoryCard(
                  workout: workout,
                  deleting:
                      _deletingWorkoutId ==
                          workout.id,
                  actionsDisabled:
                      _deletingWorkoutId !=
                          null,
                  onEdit: () {
                    _editWorkout(
                      workout,
                    );
                  },
                  onDelete: () {
                    _deleteWorkout(
                      workout,
                    );
                  },
                );
              },
            ),
    );
  }
}

class WorkoutHistoryCard
    extends StatelessWidget {
  final WorkoutData workout;

  final bool deleting;
  final bool actionsDisabled;

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const WorkoutHistoryCard({
    super.key,
    required this.workout,
    required this.deleting,
    required this.actionsDisabled,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons
                      .calendar_today_outlined,
                  color: Colors.red,
                  size: 20,
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child: Text(
                    formatDate(
                      workout.date,
                    ),
                    style:
                        const TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                Text(
                  formatTime(
                    workout.date,
                  ),
                  style:
                      const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(
                  width: 4,
                ),

                IconButton(
                  tooltip:
                      "Edit Workout",
                  onPressed:
                      actionsDisabled
                          ? null
                          : onEdit,
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: Colors.white70,
                    size: 20,
                  ),
                ),

                SizedBox(
                  width: 40,
                  height: 40,
                  child: deleting
                      ? const Padding(
                          padding:
                              EdgeInsets
                                  .all(10),
                          child:
                              CircularProgressIndicator(
                            strokeWidth:
                                2,
                          ),
                        )
                      : IconButton(
                          tooltip:
                              "Delete Workout",
                          onPressed:
                              actionsDisabled
                                  ? null
                                  : onDelete,
                          icon:
                              const Icon(
                            Icons
                                .delete_outline,
                            color:
                                Colors.red,
                            size: 20,
                          ),
                        ),
                ),
              ],
            ),

            const SizedBox(
              height: 16,
            ),

            Row(
              children: [
                Expanded(
                  child: HistoryMetric(
                    icon: Icons
                        .timer_outlined,
                    value:
                        formatDuration(
                      workout
                          .durationSeconds,
                    ),
                  ),
                ),

                Expanded(
                  child: HistoryMetric(
                    icon: Icons
                        .bar_chart_rounded,
                    value:
                        "${formatNumber(workout.totalVolume)} kg",
                  ),
                ),

                Expanded(
                  child: HistoryMetric(
                    icon: Icons
                        .checklist_rounded,
                    value:
                        "${workout.totalSets} sets",
                  ),
                ),
              ],
            ),

            const Divider(
              height: 30,
            ),

            ...List.generate(
              workout.exercises.length,
              (index) {
                final exercise =
                    workout
                        .exercises[index];

                return Padding(
                  padding:
                      EdgeInsets.only(
                    bottom: index ==
                            workout
                                    .exercises
                                    .length -
                                1
                        ? 0
                        : 18,
                  ),
                  child:
                      ExerciseHistory(
                    exercise:
                        exercise,
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

class ExerciseHistory
    extends StatelessWidget {
  final ExerciseData exercise;

  const ExerciseHistory({
    super.key,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.fitness_center,
              color: Colors.red,
              size: 18,
            ),

            const SizedBox(
              width: 9,
            ),

            Expanded(
              child: Text(
                exercise.name,
                style:
                    const TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),

            Text(
              "${formatNumber(exercise.volume)} kg",
              style:
                  const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 10,
        ),

        Padding(
          padding:
              const EdgeInsets.only(
            left: 27,
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              exercise.sets.length,
              (index) {
                final set =
                    exercise
                        .sets[index];

                return Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFF252525,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      8,
                    ),
                  ),
                  child: Text(
                    "${index + 1}. "
                    "${formatNumber(set.weight)} kg × "
                    "${set.reps}",
                    style:
                        const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class HistoryMetric
    extends StatelessWidget {
  final IconData icon;
  final String value;

  const HistoryMetric({
    super.key,
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey,
        ),

        const SizedBox(
          width: 5,
        ),

        Flexible(
          child: Text(
            value,
            overflow:
                TextOverflow.ellipsis,
            style:
                const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class EmptyHistoryState
    extends StatelessWidget {
  const EmptyHistoryState({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.history,
              size: 70,
              color: Colors.grey,
            ),

            const SizedBox(
              height: 20,
            ),

            const Text(
              "No workouts yet",
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            const Text(
              "Complete your first workout "
              "and it will appear here.",
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String formatDate(DateTime date) {
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

String formatTime(DateTime date) {
  final hour = date.hour == 0
      ? 12
      : (date.hour > 12
          ? date.hour - 12
          : date.hour);

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

String formatDuration(int seconds) {
  final hours =
      seconds ~/ 3600;

  final minutes =
      (seconds % 3600) ~/ 60;

  final remainingSeconds =
      seconds % 60;

  if (hours > 0) {
    return "${hours}h ${minutes}m";
  }

  if (minutes > 0) {
    return "${minutes}m "
        "${remainingSeconds}s";
  }

  return "${remainingSeconds}s";
}

String formatNumber(double value) {
  if (value ==
      value.roundToDouble()) {
    return value
        .toInt()
        .toString();
  }

  return value.toStringAsFixed(1);
}