import 'dart:async';

import 'package:flutter/material.dart';

import '../models/workout.dart';
import '../services/app_state.dart';
import 'workout_summary_screen.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final List<WorkoutExercise> exercises = [];

  Timer? _timer;

  int _elapsedSeconds = 0;

  bool _workoutActive = false;
  bool _savingWorkout = false;

  @override
  void dispose() {
    _timer?.cancel();
    _disposeExercises();
    super.dispose();
  }

  void _disposeExercises() {
    for (final exercise in exercises) {
      exercise.dispose();
    }
  }

  void _startWorkout() {
    if (_savingWorkout) return;

    _timer?.cancel();

    setState(() {
      _workoutActive = true;
      _elapsedSeconds = 0;
    });

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted || !_workoutActive) return;

        setState(() {
          _elapsedSeconds++;
        });
      },
    );
  }

  void _resetWorkout() {
    _timer?.cancel();

    _disposeExercises();

    setState(() {
      exercises.clear();
      _elapsedSeconds = 0;
      _workoutActive = false;
      _savingWorkout = false;
    });
  }

  Future<void> _cancelWorkout() async {
    if (!_workoutActive || _savingWorkout) return;

    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Cancel Workout?"),
          content: const Text(
            "Your current workout will be discarded.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text("Keep Training"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                "Discard",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldCancel == true && mounted) {
      _resetWorkout();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Workout cancelled"),
        ),
      );
    }
  }

  String get formattedDuration {
    final hours = _elapsedSeconds ~/ 3600;

    final minutes =
        (_elapsedSeconds % 3600) ~/ 60;

    final seconds = _elapsedSeconds % 60;

    if (hours > 0) {
      return "${hours.toString().padLeft(2, '0')}:"
          "${minutes.toString().padLeft(2, '0')}:"
          "${seconds.toString().padLeft(2, '0')}";
    }

    return "${minutes.toString().padLeft(2, '0')}:"
        "${seconds.toString().padLeft(2, '0')}";
  }

  double get totalVolume {
    return exercises.fold(
      0,
      (total, exercise) =>
          total + exercise.volume,
    );
  }

  int get completedSets {
    return exercises.fold(
      0,
      (total, exercise) =>
          total +
          exercise.sets
              .where(
                (set) => set.completed,
              )
              .length,
    );
  }

  Future<void> addExercise() async {
    if (!_workoutActive || _savingWorkout) {
      return;
    }

    final controller =
        TextEditingController();

    final String? name =
        await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Add Exercise"),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization:
                TextCapitalization.words,
            textInputAction:
                TextInputAction.done,
            decoration:
                const InputDecoration(
              labelText: "Exercise Name",
              hintText: "e.g. Bench Press",
              prefixIcon:
                  Icon(Icons.fitness_center),
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) {
              final name = value.trim();

              if (name.isNotEmpty) {
                Navigator.pop(
                  dialogContext,
                  name,
                );
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final name =
                    controller.text.trim();

                if (name.isNotEmpty) {
                  Navigator.pop(
                    dialogContext,
                    name,
                  );
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (name == null ||
        name.trim().isEmpty ||
        !mounted) {
      return;
    }

    setState(() {
      exercises.add(
        WorkoutExercise(
          name: name.trim(),
          sets: [
            WorkoutSet(),
          ],
        ),
      );
    });
  }

  void addSet(int exerciseIndex) {
    if (_savingWorkout) return;

    final exercise =
        exercises[exerciseIndex];

    double? previousWeight;
    int? previousReps;

    if (exercise.sets.isNotEmpty) {
      final previous =
          exercise.sets.last;

      previousWeight = double.tryParse(
        previous.weightController.text
            .trim(),
      );

      previousReps = int.tryParse(
        previous.repsController.text
            .trim(),
      );
    }

    setState(() {
      exercise.sets.add(
        WorkoutSet(
          weight: previousWeight,
          reps: previousReps,
        ),
      );
    });
  }

  void deleteSet(
    int exerciseIndex,
    int setIndex,
  ) {
    if (_savingWorkout) return;

    final exercise =
        exercises[exerciseIndex];

    setState(() {
      final removed =
          exercise.sets.removeAt(
        setIndex,
      );

      removed.dispose();

      if (exercise.sets.isEmpty) {
        exercise.sets.add(
          WorkoutSet(),
        );
      }
    });
  }

  void deleteExercise(int index) {
    if (_savingWorkout) return;

    final removedExercise =
        exercises[index];

    setState(() {
      exercises.removeAt(index);
    });

    ScaffoldMessenger.of(context)
        .clearSnackBars();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          "${removedExercise.name} removed",
        ),
        action: SnackBarAction(
          label: "UNDO",
          onPressed: () {
            if (!mounted ||
                _savingWorkout) {
              return;
            }

            setState(() {
              final safeIndex =
                  index <= exercises.length
                      ? index
                      : exercises.length;

              exercises.insert(
                safeIndex,
                removedExercise,
              );
            });
          },
        ),
      ),
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
        .clearSnackBars();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> finishWorkout() async {
    if (!_workoutActive ||
        _savingWorkout) {
      return;
    }

    if (exercises.isEmpty) {
      showMessage(
        "Add at least one exercise first.",
      );

      return;
    }

    if (completedSets == 0) {
      showMessage(
        "Complete at least one set before finishing.",
      );

      return;
    }

    bool newPR = false;

    for (final exercise in exercises) {
      final completed = exercise.sets
          .where(
            (set) => set.completed,
          )
          .toList();

      if (completed.isEmpty) {
        continue;
      }

      final previousPR =
          AppState.instance
              .personalRecordFor(
        exercise.name,
      );

      for (final set in completed) {
        if (set.weight > previousPR) {
          newPR = true;
          break;
        }
      }

      if (newPR) break;
    }

    final workoutExercises =
        exercises
            .map(
              (exercise) {
                final completedSetData =
                    exercise.sets
                        .where(
                          (set) =>
                              set.completed,
                        )
                        .map(
                          (set) =>
                              WorkoutSetData(
                            weight:
                                set.weight,
                            reps:
                                set.reps,
                          ),
                        )
                        .toList();

                if (completedSetData
                    .isEmpty) {
                  return null;
                }

                return ExerciseData(
                  name: exercise.name,
                  sets: completedSetData,
                );
              },
            )
            .whereType<ExerciseData>()
            .toList();

    if (workoutExercises.isEmpty) {
      showMessage(
        "Complete at least one valid set.",
      );

      return;
    }

    final workout = WorkoutData(
      // This is only a temporary local ID.
      // MongoDB will create the permanent ID.
      id: DateTime.now()
          .microsecondsSinceEpoch
          .toString(),
      date: DateTime.now(),
      durationSeconds:
          _elapsedSeconds,
      exercises:
          workoutExercises,
    );

    final summaryData =
        WorkoutSummaryData(
      totalExercises:
          workout.exercises.length,
      totalSets:
          workout.totalSets,
      totalVolume:
          workout.totalVolume,
      durationSeconds:
          workout.durationSeconds,
      newPR: newPR,
    );

    setState(() {
      _savingWorkout = true;
    });

    try {
      await AppState.instance
          .saveWorkout(workout);

      if (!mounted) return;

      _timer?.cancel();

      _disposeExercises();

      setState(() {
        exercises.clear();
        _elapsedSeconds = 0;
        _workoutActive = false;
        _savingWorkout = false;
      });

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              WorkoutSummaryScreen(
            totalExercises:
                summaryData
                    .totalExercises,
            totalSets:
                summaryData.totalSets,
            totalVolume:
                summaryData.totalVolume,
            durationSeconds:
                summaryData
                    .durationSeconds,
            newPR:
                summaryData.newPR,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _savingWorkout = false;
      });

      ScaffoldMessenger.of(context)
          .clearSnackBars();

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: const Text(
            "Couldn't save workout. "
            "Your workout is still here — "
            "check the backend and try again.",
          ),
          action: SnackBarAction(
            label: "RETRY",
            onPressed: () {
              finishWorkout();
            },
          ),
        ),
      );

      debugPrint(
        "Workout save failed: $error",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_workoutActive) {
      return _buildStartScreen();
    }

    return _buildActiveWorkout();
  }

  Widget _buildStartScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Workout",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color:
                        Colors.red.withValues(
                      alpha: 0.12,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    color: Colors.red,
                    size: 55,
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  "Ready to Train?",
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Start a workout when you're ready. "
                  "Your timer begins only after you start the session.",
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 34),

                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child:
                      ElevatedButton.icon(
                    onPressed:
                        _startWorkout,
                    icon: const Icon(
                      Icons
                          .play_arrow_rounded,
                    ),
                    label: const Text(
                      "Start Workout",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                const Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 17,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 6),
                    Text(
                      "Timer starts at 00:00",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveWorkout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Workout",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding:
                const EdgeInsets.only(
              right: 4,
            ),
            child: Center(
              child: Row(
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    color: Colors.red,
                    size: 20,
                  ),

                  const SizedBox(width: 6),

                  Text(
                    formattedDuration,
                    style:
                        const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          IconButton(
            tooltip: "Cancel Workout",
            onPressed: _savingWorkout
                ? null
                : _cancelWorkout,
            icon: const Icon(
              Icons.close,
              color: Colors.red,
            ),
          ),

          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child:
                  SingleChildScrollView(
                padding:
                    const EdgeInsets
                        .fromLTRB(
                  20,
                  12,
                  20,
                  24,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                "Active Workout",
                                style:
                                    TextStyle(
                                  fontSize:
                                      24,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),

                              SizedBox(
                                height: 5,
                              ),

                              Text(
                                "Log each set as you train.",
                                style:
                                    TextStyle(
                                  color:
                                      Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        ElevatedButton.icon(
                          onPressed:
                              _savingWorkout
                                  ? null
                                  : addExercise,
                          icon: const Icon(
                            Icons.add,
                          ),
                          label:
                              const Text(
                            "Exercise",
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    if (exercises.isEmpty)
                      EmptyWorkoutState(
                        onAddExercise:
                            addExercise,
                        enabled:
                            !_savingWorkout,
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(),
                        itemCount:
                            exercises.length,
                        separatorBuilder:
                            (_, __) =>
                                const SizedBox(
                          height: 16,
                        ),
                        itemBuilder:
                            (context,
                                index) {
                          return ExerciseCard(
                            exercise:
                                exercises[
                                    index],
                            enabled:
                                !_savingWorkout,
                            onChanged: () {
                              if (!_savingWorkout) {
                                setState(
                                  () {},
                                );
                              }
                            },
                            onAddSet: () {
                              addSet(
                                index,
                              );
                            },
                            onDeleteExercise:
                                () {
                              deleteExercise(
                                index,
                              );
                            },
                            onDeleteSet:
                                (setIndex) {
                              deleteSet(
                                index,
                                setIndex,
                              );
                            },
                          );
                        },
                      ),

                    const SizedBox(
                      height: 24,
                    ),

                    Card(
                      child: Padding(
                        padding:
                            const EdgeInsets
                                .all(18),
                        child: Row(
                          children: [
                            const Icon(
                              Icons
                                  .bar_chart_rounded,
                              color:
                                  Colors.red,
                              size: 30,
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
                                  const Text(
                                    "Session Volume",
                                    style:
                                        TextStyle(
                                      color:
                                          Colors
                                              .grey,
                                      fontSize:
                                          13,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 4,
                                  ),

                                  Text(
                                    "$completedSets completed "
                                    "${completedSets == 1 ? "set" : "sets"}",
                                  ),
                                ],
                              ),
                            ),

                            Text(
                              "${formatNumber(totalVolume)} kg",
                              style:
                                  const TextStyle(
                                fontSize:
                                    20,
                                fontWeight:
                                    FontWeight
                                        .bold,
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

            Container(
              padding:
                  const EdgeInsets
                      .fromLTRB(
                20,
                12,
                20,
                16,
              ),
              decoration:
                  const BoxDecoration(
                color:
                    Color(0xFF121212),
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
                      width: 54,
                      height: 56,
                      child:
                          OutlinedButton(
                        onPressed:
                            _savingWorkout
                                ? null
                                : _cancelWorkout,
                        style:
                            OutlinedButton
                                .styleFrom(
                          padding:
                              EdgeInsets
                                  .zero,
                        ),
                        child: const Icon(
                          Icons
                              .delete_outline,
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child:
                            ElevatedButton(
                          onPressed:
                              _savingWorkout
                                  ? null
                                  : finishWorkout,
                          child:
                              _savingWorkout
                                  ? const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .center,
                                      children: [
                                        SizedBox(
                                          width:
                                              20,
                                          height:
                                              20,
                                          child:
                                              CircularProgressIndicator(
                                            strokeWidth:
                                                2.5,
                                          ),
                                        ),
                                        SizedBox(
                                          width:
                                              12,
                                        ),
                                        Text(
                                          "Saving Workout...",
                                          style:
                                              TextStyle(
                                            fontSize:
                                                16,
                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    )
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .center,
                                      children: [
                                        Icon(
                                          Icons.flag_rounded,
                                        ),
                                        SizedBox(
                                          width:
                                              8,
                                        ),
                                        Text(
                                          "Finish Workout",
                                          style:
                                              TextStyle(
                                            fontSize:
                                                17,
                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),
                                      ],
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

class WorkoutSummaryData {
  final int totalExercises;
  final int totalSets;
  final double totalVolume;
  final int durationSeconds;
  final bool newPR;

  const WorkoutSummaryData({
    required this.totalExercises,
    required this.totalSets,
    required this.totalVolume,
    required this.durationSeconds,
    required this.newPR,
  });
}

class WorkoutExercise {
  final String name;
  final List<WorkoutSet> sets;

  WorkoutExercise({
    required this.name,
    required this.sets,
  });

  double get volume {
    return sets
        .where(
          (set) => set.completed,
        )
        .fold(
          0,
          (total, set) =>
              total + set.volume,
        );
  }

  void dispose() {
    for (final set in sets) {
      set.dispose();
    }
  }
}

class WorkoutSet {
  final TextEditingController
      weightController;

  final TextEditingController
      repsController;

  bool completed;

  WorkoutSet({
    double? weight,
    int? reps,
    this.completed = false,
  })  : weightController =
            TextEditingController(
          text: weight == null
              ? ""
              : formatWeight(weight),
        ),
        repsController =
            TextEditingController(
          text: reps?.toString() ?? "",
        );

  double get weight =>
      double.tryParse(
        weightController.text.trim(),
      ) ??
      0;

  int get reps =>
      int.tryParse(
        repsController.text.trim(),
      ) ??
      0;

  double get volume =>
      weight * reps;

  void dispose() {
    weightController.dispose();
    repsController.dispose();
  }
}

class ExerciseCard
    extends StatelessWidget {
  final WorkoutExercise exercise;

  final bool enabled;

  final VoidCallback onChanged;
  final VoidCallback onAddSet;
  final VoidCallback
      onDeleteExercise;

  final void Function(int)
      onDeleteSet;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.enabled,
    required this.onChanged,
    required this.onAddSet,
    required this.onDeleteExercise,
    required this.onDeleteSet,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          12,
        ),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor:
                      Color(0xFF341010),
                  child: Icon(
                    Icons.fitness_center,
                    color: Colors.red,
                    size: 20,
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
                          fontSize: 18,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),

                      const SizedBox(
                        height: 3,
                      ),

                      Text(
                        "Volume: ${formatNumber(exercise.volume)} kg",
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

                IconButton(
                  tooltip:
                      "Delete Exercise",
                  onPressed: enabled
                      ? onDeleteExercise
                      : null,
                  icon: const Icon(
                    Icons
                        .delete_outline,
                    color: Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 18,
            ),

            const Row(
              children: [
                SizedBox(
                  width: 42,
                  child: Text(
                    "SET",
                    textAlign:
                        TextAlign.center,
                    style:
                        SetHeaderStyle
                            .style,
                  ),
                ),

                SizedBox(width: 10),

                Expanded(
                  child: Text(
                    "KG",
                    textAlign:
                        TextAlign.center,
                    style:
                        SetHeaderStyle
                            .style,
                  ),
                ),

                SizedBox(width: 10),

                Expanded(
                  child: Text(
                    "REPS",
                    textAlign:
                        TextAlign.center,
                    style:
                        SetHeaderStyle
                            .style,
                  ),
                ),

                SizedBox(width: 10),

                SizedBox(
                  width: 42,
                  child: Text(
                    "DONE",
                    textAlign:
                        TextAlign.center,
                    style:
                        SetHeaderStyle
                            .style,
                  ),
                ),

                SizedBox(width: 42),
              ],
            ),

            const SizedBox(
              height: 8,
            ),

            ...List.generate(
              exercise.sets.length,
              (index) {
                return Padding(
                  padding:
                      const EdgeInsets
                          .only(
                    bottom: 9,
                  ),
                  child: SetRow(
                    number: index + 1,
                    set:
                        exercise.sets[
                            index],
                    enabled: enabled,
                    onChanged:
                        onChanged,
                    onDelete: () {
                      onDeleteSet(
                        index,
                      );
                    },
                  ),
                );
              },
            ),

            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed:
                    enabled
                        ? onAddSet
                        : null,
                icon:
                    const Icon(Icons.add),
                label:
                    const Text("Add Set"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SetRow extends StatelessWidget {
  final int number;
  final WorkoutSet set;
  final bool enabled;

  final VoidCallback onChanged;
  final VoidCallback onDelete;

  const SetRow({
    super.key,
    required this.number,
    required this.set,
    required this.enabled,
    required this.onChanged,
    required this.onDelete,
  });

  void toggleCompleted(
    BuildContext context,
  ) {
    if (!enabled) return;

    if (!set.completed &&
        (set.weight <= 0 ||
            set.reps <= 0)) {
      ScaffoldMessenger.of(context)
          .clearSnackBars();

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Enter a valid weight and reps first.",
          ),
        ),
      );

      return;
    }

    set.completed =
        !set.completed;

    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: set.completed
                ? Colors.red.withValues(
                    alpha: 0.15,
                  )
                : const Color(
                    0xFF252525,
                  ),
            borderRadius:
                BorderRadius.circular(
              8,
            ),
          ),
          child: Text(
            "$number",
            style: TextStyle(
              fontWeight:
                  FontWeight.bold,
              color: set.completed
                  ? Colors.red
                  : Colors.white,
            ),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: SizedBox(
            height: 44,
            child: TextField(
              controller:
                  set.weightController,
              enabled:
                  enabled &&
                      !set.completed,
              keyboardType:
                  const TextInputType
                      .numberWithOptions(
                decimal: true,
              ),
              textAlign:
                  TextAlign.center,
              onChanged: (_) {
                if (enabled) {
                  onChanged();
                }
              },
              decoration:
                  const InputDecoration(

                contentPadding:
                    EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                border:
                    OutlineInputBorder(),
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: SizedBox(
            height: 44,
            child: TextField(
              controller:
                  set.repsController,
              enabled:
                  enabled &&
                      !set.completed,
              keyboardType:
                  TextInputType.number,
              textAlign:
                  TextAlign.center,
              onChanged: (_) {
                if (enabled) {
                  onChanged();
                }
              },
              decoration:
                  const InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                border:
                    OutlineInputBorder(),
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        SizedBox(
          width: 42,
          child: IconButton(
            tooltip: set.completed
                ? "Mark Incomplete"
                : "Complete Set",
            onPressed: enabled
                ? () {
                    toggleCompleted(
                      context,
                    );
                  }
                : null,
            icon: Icon(
              set.completed
                  ? Icons.check_circle
                  : Icons
                      .radio_button_unchecked,
              color: set.completed
                  ? Colors.green
                  : Colors.grey,
            ),
          ),
        ),

        SizedBox(
          width: 42,
          child: IconButton(
            tooltip: "Delete Set",
            onPressed:
                enabled
                    ? onDelete
                    : null,
            icon: const Icon(
              Icons.close,
              size: 19,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}

class EmptyWorkoutState
    extends StatelessWidget {
  final VoidCallback onAddExercise;
  final bool enabled;

  const EmptyWorkoutState({
    super.key,
    required this.onAddExercise,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        vertical: 44,
        horizontal: 24,
      ),
      decoration: BoxDecoration(
        color:
            const Color(0xFF1E1E1E),
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.fitness_center,
            size: 46,
            color: Colors.grey,
          ),

          const SizedBox(height: 16),

          const Text(
            "Add your first exercise",
            style: TextStyle(
              fontSize: 19,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            "Your workout timer is running. "
            "Add an exercise and start logging sets.",
            textAlign:
                TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 20),

          OutlinedButton.icon(
            onPressed:
                enabled
                    ? onAddExercise
                    : null,
            icon:
                const Icon(Icons.add),
            label:
                const Text(
              "Add Exercise",
            ),
          ),
        ],
      ),
    );
  }
}

class SetHeaderStyle {
  static const TextStyle style =
      TextStyle(
    color: Colors.grey,
    fontSize: 11,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.7,
  );
}

String formatWeight(double value) {
  if (value ==
      value.roundToDouble()) {
    return value.toInt().toString();
  }

  return value.toStringAsFixed(1);
}

String formatNumber(double value) {
  if (value ==
      value.roundToDouble()) {
    return value.toInt().toString();
  }

  return value.toStringAsFixed(1);
}