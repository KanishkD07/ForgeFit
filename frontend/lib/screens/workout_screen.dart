import 'dart:async';

import 'package:flutter/material.dart';

import '../models/routine.dart';
import '../models/workout.dart';
import '../services/app_state.dart';
import 'workout_summary_screen.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() =>
      _WorkoutScreenState();
}

class _WorkoutScreenState
    extends State<WorkoutScreen> {
  final List<WorkoutExercise> exercises = [];

  Timer? _timer;

  int _elapsedSeconds = 0;

  bool _workoutActive = false;
  bool _savingWorkout = false;
  bool _loadingRoutines = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) {
        if (mounted) {
          _loadRoutines();
        }
      },
    );
  }

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

  // =========================
  // WORKOUT START
  // =========================

  void _startWorkout() {
    if (_savingWorkout) return;

    _timer?.cancel();

    _disposeExercises();

    setState(() {
      exercises.clear();
      _workoutActive = true;
      _elapsedSeconds = 0;
    });

    _startTimer();
  }

  void _startFromRoutine(
    RoutineData routine,
  ) {
    if (_savingWorkout) return;

    _timer?.cancel();

    _disposeExercises();

    exercises.clear();

    for (final exercise
        in routine.exercises) {
      exercises.add(
        WorkoutExercise(
          name: exercise.name,
          sets: List.generate(
            exercise.defaultSets,
            (_) => WorkoutSet(),
          ),
        ),
      );
    }

    setState(() {
      _workoutActive = true;
      _elapsedSeconds = 0;
    });

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted ||
            !_workoutActive) {
          return;
        }

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
    if (!_workoutActive ||
        _savingWorkout) {
      return;
    }

    final shouldCancel =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title:
              const Text(
            "Cancel Workout?",
          ),
          content: const Text(
            "Your current workout will be discarded.",
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
                "Keep Training",
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

    if (shouldCancel == true &&
        mounted) {
      _resetWorkout();

      showMessage(
        "Workout cancelled",
      );
    }
  }

  // =========================
  // ROUTINES
  // =========================

  Future<void> _loadRoutines() async {
    if (_loadingRoutines ||
        !AppState.instance
            .isAuthenticated) {
      return;
    }

    setState(() {
      _loadingRoutines = true;
    });

    try {
      await AppState.instance
          .loadRoutines();
    } catch (error) {
      if (!mounted) return;

      showMessage(
        "Couldn't load routines. "
        "Check the backend and try again.",
      );

      debugPrint(
        "Routine load failed: $error",
      );
    } finally {
      if (mounted) {
        setState(() {
          _loadingRoutines =
              false;
        });
      }
    }
  }

  Future<void>
      _showRoutineEditor({
    RoutineData? routine,
  }) async {
    final draft =
        await showDialog<RoutineDraft>(
      context: context,
      builder: (dialogContext) {
        return RoutineEditorDialog(
          routine: routine,
        );
      },
    );

    if (draft == null ||
        !mounted) {
      return;
    }

    try {
      if (routine == null) {
        await AppState.instance
            .createRoutine(
          name: draft.name,
          exercises:
              draft.exercises,
        );

        if (!mounted) return;

        showMessage(
          "Routine created",
        );
      } else {
        await AppState.instance
            .updateRoutine(
          RoutineData(
            id: routine.id,
            name: draft.name,
            exercises:
                draft.exercises,
          ),
        );

        if (!mounted) return;

        showMessage(
          "Routine updated",
        );
      }

      setState(() {});
    } catch (error) {
      if (!mounted) return;

      showMessage(
        "Couldn't save routine.",
      );

      debugPrint(
        "Routine save failed: $error",
      );
    }
  }

  Future<void> _deleteRoutine(
    RoutineData routine,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title:
              const Text(
            "Delete Routine?",
          ),
          content: Text(
            '"${routine.name}" will be '
            "permanently deleted.",
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

    if (confirmed != true ||
        !mounted) {
      return;
    }

    try {
      await AppState.instance
          .deleteRoutine(
        routine.id,
      );

      if (!mounted) return;

      setState(() {});

      showMessage(
        "Routine deleted",
      );
    } catch (error) {
      if (!mounted) return;

      showMessage(
        "Couldn't delete routine.",
      );

      debugPrint(
        "Routine delete failed: $error",
      );
    }
  }

  // =========================
  // WORKOUT STATS
  // =========================

  String get formattedDuration {
    final hours =
        _elapsedSeconds ~/ 3600;

    final minutes =
        (_elapsedSeconds % 3600) ~/
            60;

    final seconds =
        _elapsedSeconds % 60;

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
          total +
          exercise.volume,
    );
  }

  int get completedSets {
    return exercises.fold(
      0,
      (total, exercise) =>
          total +
          exercise.sets
              .where(
                (set) =>
                    set.completed,
              )
              .length,
    );
  }

  // =========================
  // EXERCISES
  // =========================

  Future<void> addExercise() async {
    if (!_workoutActive ||
        _savingWorkout) {
      return;
    }

    final controller =
        TextEditingController();

    final String? name =
        await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title:
              const Text(
            "Add Exercise",
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization:
                TextCapitalization.words,
            textInputAction:
                TextInputAction.done,
            decoration:
                const InputDecoration(
              labelText:
                  "Exercise Name",
              hintText:
                  "e.g. Bench Press",
              prefixIcon: Icon(
                Icons.fitness_center,
              ),
              border:
                  OutlineInputBorder(),
            ),
            onSubmitted: (value) {
              final exerciseName =
                  value.trim();

              if (exerciseName
                  .isNotEmpty) {
                Navigator.pop(
                  dialogContext,
                  exerciseName,
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
              child:
                  const Text(
                "Cancel",
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final exerciseName =
                    controller.text
                        .trim();

                if (exerciseName
                    .isNotEmpty) {
                  Navigator.pop(
                    dialogContext,
                    exerciseName,
                  );
                }
              },
              child:
                  const Text(
                "Add",
              ),
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

  void addSet(
    int exerciseIndex,
  ) {
    if (_savingWorkout) return;

    final exercise =
        exercises[
            exerciseIndex];

    double? previousWeight;
    int? previousReps;

    if (exercise
        .sets.isNotEmpty) {
      final previous =
          exercise.sets.last;

      previousWeight =
          double.tryParse(
        previous
            .weightController.text
            .trim(),
      );

      previousReps =
          int.tryParse(
        previous
            .repsController.text
            .trim(),
      );
    }

    setState(() {
      exercise.sets.add(
        WorkoutSet(
          weight:
              previousWeight,
          reps:
              previousReps,
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
        exercises[
            exerciseIndex];

    setState(() {
      final removed =
          exercise.sets
              .removeAt(
        setIndex,
      );

      removed.dispose();

      if (exercise
          .sets.isEmpty) {
        exercise.sets.add(
          WorkoutSet(),
        );
      }
    });
  }

  void deleteExercise(
    int index,
  ) {
    if (_savingWorkout) return;

    final removedExercise =
        exercises[index];

    setState(() {
      exercises.removeAt(
        index,
      );
    });

    ScaffoldMessenger.of(context)
        .clearSnackBars();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          "${removedExercise.name} removed",
        ),
        action:
            SnackBarAction(
          label: "UNDO",
          onPressed: () {
            if (!mounted ||
                _savingWorkout) {
              return;
            }

            setState(() {
              final safeIndex =
                  index <=
                          exercises
                              .length
                      ? index
                      : exercises
                          .length;

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

  void showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .clearSnackBars();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
            Text(message),
      ),
    );
  }

  // =========================
  // FINISH WORKOUT
  // =========================

  Future<void>
      finishWorkout() async {
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

    for (final exercise
        in exercises) {
      final completed =
          exercise.sets
              .where(
                (set) =>
                    set.completed,
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

      for (final set
          in completed) {
        if (set.weight >
            previousPR) {
          newPR = true;
          break;
        }
      }

      if (newPR) {
        break;
      }
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
                  name:
                      exercise.name,
                  sets:
                      completedSetData,
                );
              },
            )
            .whereType<
                ExerciseData>()
            .toList();

    if (workoutExercises
        .isEmpty) {
      showMessage(
        "Complete at least one valid set.",
      );

      return;
    }

    final workout =
        WorkoutData(
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
          workout
              .exercises.length,
      totalSets:
          workout.totalSets,
      totalVolume:
          workout.totalVolume,
      durationSeconds:
          workout
              .durationSeconds,
      newPR: newPR,
    );

    setState(() {
      _savingWorkout = true;
    });

    try {
      await AppState.instance
          .saveWorkout(
        workout,
      );

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
                summaryData
                    .totalSets,
            totalVolume:
                summaryData
                    .totalVolume,
            durationSeconds:
                summaryData
                    .durationSeconds,
            newPR:
                summaryData
                    .newPR,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _savingWorkout =
            false;
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
          action:
              SnackBarAction(
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

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(
    BuildContext context,
  ) {
    if (!_workoutActive) {
      return _buildStartScreen();
    }

    return _buildActiveWorkout();
  }

  // =========================
  // START SCREEN
  // =========================

  Widget _buildStartScreen() {
    final routines =
        AppState.instance
            .routines;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Workout",
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child:
            RefreshIndicator(
          onRefresh:
              _loadRoutines,
          child:
              SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(),
            padding:
                const EdgeInsets
                    .fromLTRB(
              24,
              24,
              24,
              36,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Center(
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration:
                        BoxDecoration(
                      color:
                          Colors.red
                              .withValues(
                        alpha: 0.12,
                      ),
                      shape:
                          BoxShape
                              .circle,
                    ),
                    child:
                        const Icon(
                      Icons
                          .fitness_center,
                      color:
                          Colors.red,
                      size: 48,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 22,
                ),

                const Center(
                  child: Text(
                    "Ready to Train?",
                    textAlign:
                        TextAlign
                            .center,
                    style:
                        TextStyle(
                      fontSize: 30,
                      fontWeight:
                          FontWeight
                              .bold,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                const Center(
                  child: Text(
                    "Start an empty workout or use a saved routine.",
                    textAlign:
                        TextAlign
                            .center,
                    style:
                        TextStyle(
                      color:
                          Colors.grey,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 28,
                ),

                SizedBox(
                  width:
                      double.infinity,
                  height: 56,
                  child:
                      ElevatedButton
                          .icon(
                    onPressed:
                        _startWorkout,
                    icon:
                        const Icon(
                      Icons
                          .play_arrow_rounded,
                    ),
                    label:
                        const Text(
                      "Start Empty Workout",
                      style:
                          TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 32,
                ),

                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            "Saved Routines",
                            style:
                                TextStyle(
                              fontSize:
                                  21,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Text(
                            "Reuse your favourite training plans",
                            style:
                                TextStyle(
                              color:
                                  Colors
                                      .grey,
                              fontSize:
                                  12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      tooltip:
                          "Refresh Routines",
                      onPressed:
                          _loadingRoutines
                              ? null
                              : _loadRoutines,
                      icon:
                          _loadingRoutines
                              ? const SizedBox(
                                  width:
                                      20,
                                  height:
                                      20,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth:
                                        2,
                                  ),
                                )
                              : const Icon(
                                  Icons
                                      .refresh,
                                ),
                    ),

                    const SizedBox(
                      width: 4,
                    ),

                    ElevatedButton
                        .icon(
                      onPressed: () {
                        _showRoutineEditor();
                      },
                      icon:
                          const Icon(
                        Icons.add,
                      ),
                      label:
                          const Text(
                        "Routine",
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 16,
                ),

                if (_loadingRoutines &&
                    routines.isEmpty)
                  const Padding(
                    padding:
                        EdgeInsets
                            .symmetric(
                      vertical: 42,
                    ),
                    child: Center(
                      child:
                          CircularProgressIndicator(),
                    ),
                  )
                else if (routines
                    .isEmpty)
                  RoutineEmptyState(
                    onCreate: () {
                      _showRoutineEditor();
                    },
                  )
                else
                  ...routines.map(
                    (routine) =>
                        RoutineCard(
                      routine:
                          routine,
                      onStart: () {
                        _startFromRoutine(
                          routine,
                        );
                      },
                      onEdit: () {
                        _showRoutineEditor(
                          routine:
                              routine,
                        );
                      },
                      onDelete: () {
                        _deleteRoutine(
                          routine,
                        );
                      },
                    ),
                  ),

                const SizedBox(
                  height: 18,
                ),

                const Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,
                  children: [
                    Icon(
                      Icons
                          .timer_outlined,
                      size: 17,
                      color:
                          Colors.grey,
                    ),
                    SizedBox(
                      width: 6,
                    ),
                    Flexible(
                      child: Text(
                        "Timer starts only when a workout begins",
                        textAlign:
                            TextAlign
                                .center,
                        style:
                            TextStyle(
                          color:
                              Colors.grey,
                          fontSize:
                              13,
                        ),
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

  // =========================
  // ACTIVE WORKOUT
  // =========================

  Widget _buildActiveWorkout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Workout",
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding:
                const EdgeInsets
                    .only(
              right: 4,
            ),
            child: Center(
              child: Row(
                children: [
                  const Icon(
                    Icons
                        .timer_outlined,
                    color:
                        Colors.red,
                    size: 20,
                  ),

                  const SizedBox(
                    width: 6,
                  ),

                  Text(
                    formattedDuration,
                    style:
                        const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight
                              .bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          IconButton(
            tooltip:
                "Cancel Workout",
            onPressed:
                _savingWorkout
                    ? null
                    : _cancelWorkout,
            icon:
                const Icon(
              Icons.close,
              color:
                  Colors.red,
            ),
          ),

          const SizedBox(
            width: 6,
          ),
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
                          child:
                              Column(
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
                                      Colors
                                          .grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        ElevatedButton
                            .icon(
                          onPressed:
                              _savingWorkout
                                  ? null
                                  : addExercise,
                          icon:
                              const Icon(
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

                    if (exercises
                        .isEmpty)
                      EmptyWorkoutState(
                        onAddExercise:
                            addExercise,
                        enabled:
                            !_savingWorkout,
                      )
                    else
                      ListView
                          .separated(
                        shrinkWrap:
                            true,
                        physics:
                            const NeverScrollableScrollPhysics(),
                        itemCount:
                            exercises
                                .length,
                        separatorBuilder:
                            (_, __) =>
                                const SizedBox(
                          height: 16,
                        ),
                        itemBuilder:
                            (
                          context,
                          index,
                        ) {
                          return ExerciseCard(
                            exercise:
                                exercises[
                                    index],
                            enabled:
                                !_savingWorkout,
                            onChanged:
                                () {
                              if (!_savingWorkout) {
                                setState(
                                  () {},
                                );
                              }
                            },
                            onAddSet:
                                () {
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
                                (
                              setIndex,
                            ) {
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
                                .all(
                          18,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons
                                  .bar_chart_rounded,
                              color:
                                  Colors
                                      .red,
                              size: 30,
                            ),

                            const SizedBox(
                              width: 14,
                            ),

                            Expanded(
                              child:
                                  Column(
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
                                    height:
                                        4,
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
                    Color(
                  0xFF121212,
                ),
                border: Border(
                  top:
                      BorderSide(
                    color:
                        Color(
                      0xFF2A2A2A,
                    ),
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
                        child:
                            const Icon(
                          Icons
                              .delete_outline,
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    Expanded(
                      child:
                          SizedBox(
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
                                          Icons
                                              .flag_rounded,
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

// =====================================================
// ROUTINE UI
// =====================================================

class RoutineCard
    extends StatelessWidget {
  final RoutineData routine;

  final VoidCallback onStart;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const RoutineCard({
    super.key,
    required this.routine,
    required this.onStart,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final totalSets =
        routine.exercises.fold<int>(
      0,
      (
        total,
        exercise,
      ) =>
          total +
          exercise.defaultSets,
    );

    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 12,
      ),
      child: Card(
        child: Padding(
          padding:
              const EdgeInsets
                  .fromLTRB(
            16,
            16,
            10,
            14,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor:
                        Color(
                      0xFF341010,
                    ),
                    child: Icon(
                      Icons
                          .bookmark_rounded,
                      color:
                          Colors.red,
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
                          routine.name,
                          style:
                              const TextStyle(
                            fontSize:
                                17,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),

                        const SizedBox(
                          height: 3,
                        ),

                        Text(
                          "${routine.exercises.length} "
                          "${routine.exercises.length == 1 ? "exercise" : "exercises"}"
                          " • $totalSets "
                          "${totalSets == 1 ? "set" : "sets"}",
                          style:
                              const TextStyle(
                            color:
                                Colors
                                    .grey,
                            fontSize:
                                12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  PopupMenuButton<
                      String>(
                    tooltip:
                        "Routine Options",
                    onSelected:
                        (value) {
                      if (value ==
                          "edit") {
                        onEdit();
                      }

                      if (value ==
                          "delete") {
                        onDelete();
                      }
                    },
                    itemBuilder:
                        (context) => [
                      const PopupMenuItem(
                        value:
                            "edit",
                        child: Row(
                          children: [
                            Icon(
                              Icons
                                  .edit_outlined,
                              size:
                                  19,
                            ),
                            SizedBox(
                              width:
                                  10,
                            ),
                            Text(
                              "Edit Routine",
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value:
                            "delete",
                        child: Row(
                          children: [
                            Icon(
                              Icons
                                  .delete_outline,
                              color:
                                  Colors
                                      .red,
                              size:
                                  19,
                            ),
                            SizedBox(
                              width:
                                  10,
                            ),
                            Text(
                              "Delete Routine",
                              style:
                                  TextStyle(
                                color:
                                    Colors
                                        .red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(
                height: 14,
              ),

              Wrap(
                spacing: 7,
                runSpacing: 7,
                children:
                    routine.exercises
                        .map(
                  (exercise) {
                    return Chip(
                      label: Text(
                        "${exercise.name} ×${exercise.defaultSets}",
                      ),
                    );
                  },
                ).toList(),
              ),

              const SizedBox(
                height: 16,
              ),

              SizedBox(
                width:
                    double.infinity,
                height: 48,
                child:
                    ElevatedButton
                        .icon(
                  onPressed:
                      onStart,
                  icon:
                      const Icon(
                    Icons
                        .play_arrow_rounded,
                  ),
                  label: Text(
                    "Start ${routine.name}",
                    overflow:
                        TextOverflow
                            .ellipsis,
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

class RoutineEmptyState
    extends StatelessWidget {
  final VoidCallback onCreate;

  const RoutineEmptyState({
    super.key,
    required this.onCreate,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets
              .symmetric(
        vertical: 34,
        horizontal: 24,
      ),
      decoration: BoxDecoration(
        color:
            const Color(
          0xFF1E1E1E,
        ),
        borderRadius:
            BorderRadius.circular(
          14,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons
                .bookmark_border_rounded,
            size: 44,
            color: Colors.grey,
          ),

          const SizedBox(
            height: 14,
          ),

          const Text(
            "No routines yet",
            style: TextStyle(
              fontSize: 19,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 7,
          ),

          const Text(
            "Create a reusable workout plan "
            "and start it whenever you train.",
            textAlign:
                TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              height: 1.4,
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          OutlinedButton.icon(
            onPressed:
                onCreate,
            icon:
                const Icon(
              Icons.add,
            ),
            label:
                const Text(
              "Create Routine",
            ),
          ),
        ],
      ),
    );
  }
}

class RoutineDraft {
  final String name;

  final List<RoutineExerciseData>
      exercises;

  const RoutineDraft({
    required this.name,
    required this.exercises,
  });
}

class RoutineEditorDialog
    extends StatefulWidget {
  final RoutineData? routine;

  const RoutineEditorDialog({
    super.key,
    this.routine,
  });

  @override
  State<RoutineEditorDialog>
      createState() =>
          _RoutineEditorDialogState();
}

class _RoutineEditorDialogState
    extends State<
        RoutineEditorDialog> {
  late final
      TextEditingController
          nameController;

  late List<
          RoutineExerciseDraft>
      exerciseDrafts;

  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(
      text:
          widget.routine?.name ??
              "",
    );

    final existing =
        widget.routine;

    if (existing == null) {
      exerciseDrafts = [
        RoutineExerciseDraft(
          name: "",
          defaultSets: 3,
        ),
      ];
    } else {
      exerciseDrafts =
          existing.exercises
              .map(
                (exercise) =>
                    RoutineExerciseDraft(
                  name:
                      exercise.name,
                  defaultSets:
                      exercise
                          .defaultSets,
                ),
              )
              .toList();
    }
  }

  @override
  void dispose() {
    nameController.dispose();

    for (final draft
        in exerciseDrafts) {
      draft.dispose();
    }

    super.dispose();
  }

  void addExercise() {
    setState(() {
      exerciseDrafts.add(
        RoutineExerciseDraft(
          name: "",
          defaultSets: 3,
        ),
      );
    });
  }

  void removeExercise(
    int index,
  ) {
    if (exerciseDrafts
            .length ==
        1) {
      return;
    }

    final removed =
        exerciseDrafts
            .removeAt(
      index,
    );

    removed.dispose();

    setState(() {});
  }

  void moveExercise(
    int index,
    int direction,
  ) {
    final newIndex =
        index + direction;

    if (newIndex < 0 ||
        newIndex >=
            exerciseDrafts
                .length) {
      return;
    }

    setState(() {
      final item =
          exerciseDrafts
              .removeAt(
        index,
      );

      exerciseDrafts.insert(
        newIndex,
        item,
      );
    });
  }

  void save() {
    final routineName =
        nameController.text
            .trim();

    if (routineName.isEmpty) {
      _showError(
        "Enter a routine name.",
      );

      return;
    }

    final exercises =
        <RoutineExerciseData>[];

    final usedNames =
        <String>{};

    for (final draft
        in exerciseDrafts) {
      final exerciseName =
          draft
              .nameController
              .text
              .trim();

      if (exerciseName
          .isEmpty) {
        _showError(
          "Every exercise needs a name.",
        );

        return;
      }

      final normalisedName =
          exerciseName
              .toLowerCase();

      if (usedNames.contains(
        normalisedName,
      )) {
        _showError(
          "$exerciseName is already in this routine.",
        );

        return;
      }

      usedNames.add(
        normalisedName,
      );

      exercises.add(
        RoutineExerciseData(
          name:
              exerciseName,
          defaultSets:
              draft
                  .defaultSets,
        ),
      );
    }

    Navigator.pop(
      context,
      RoutineDraft(
        name:
            routineName,
        exercises:
            exercises,
      ),
    );
  }

  void _showError(
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .clearSnackBars();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
            Text(message),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return AlertDialog(
      title: Text(
        widget.routine == null
            ? "Create Routine"
            : "Edit Routine",
      ),
      content: SizedBox(
        width: 520,
        child:
            SingleChildScrollView(
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              TextField(
                controller:
                    nameController,
                autofocus:
                    widget.routine ==
                        null,
                textCapitalization:
                    TextCapitalization
                        .words,
                decoration:
                    const InputDecoration(
                  labelText:
                      "Routine Name",
                  hintText:
                      "e.g. Push Day",
                  prefixIcon:
                      Icon(
                    Icons
                        .bookmark_outline,
                  ),
                  border:
                      OutlineInputBorder(),
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Exercises",
                      style:
                          TextStyle(
                        fontSize:
                            17,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),
                  ),
                  Text(
                    "${exerciseDrafts.length}",
                    style:
                        const TextStyle(
                      color:
                          Colors.grey,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 12,
              ),

              ...List.generate(
                exerciseDrafts
                    .length,
                (index) {
                  final draft =
                      exerciseDrafts[
                          index];

                  return Padding(
                    padding:
                        const EdgeInsets
                            .only(
                      bottom: 12,
                    ),
                    child:
                        Container(
                      padding:
                          const EdgeInsets
                              .all(
                        12,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFF1E1E1E,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                      ),
                      child:
                          Column(
                        children: [
                          Row(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Expanded(
                                child:
                                    TextField(
                                  controller:
                                      draft
                                          .nameController,
                                  textCapitalization:
                                      TextCapitalization
                                          .words,
                                  decoration:
                                      InputDecoration(
                                    labelText:
                                        "Exercise ${index + 1}",
                                    hintText:
                                        "e.g. Bench Press",
                                    border:
                                        const OutlineInputBorder(),
                                  ),
                                ),
                              ),

                              const SizedBox(
                                width:
                                    4,
                              ),

                              Column(
                                children: [
                                  IconButton(
                                    tooltip:
                                        "Move Up",
                                    onPressed:
                                        index >
                                                0
                                            ? () {
                                                moveExercise(
                                                  index,
                                                  -1,
                                                );
                                              }
                                            : null,
                                    icon:
                                        const Icon(
                                      Icons
                                          .keyboard_arrow_up,
                                    ),
                                  ),
                                  IconButton(
                                    tooltip:
                                        "Move Down",
                                    onPressed:
                                        index <
                                                exerciseDrafts.length -
                                                    1
                                            ? () {
                                                moveExercise(
                                                  index,
                                                  1,
                                                );
                                              }
                                            : null,
                                    icon:
                                        const Icon(
                                      Icons
                                          .keyboard_arrow_down,
                                    ),
                                  ),
                                ],
                              ),

                              IconButton(
                                tooltip:
                                    "Remove Exercise",
                                onPressed:
                                    exerciseDrafts.length >
                                            1
                                        ? () {
                                            removeExercise(
                                              index,
                                            );
                                          }
                                        : null,
                                icon:
                                    const Icon(
                                  Icons
                                      .delete_outline,
                                  color:
                                      Colors.red,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          Row(
                            children: [
                              const Text(
                                "Default Sets",
                                style:
                                    TextStyle(
                                  color:
                                      Colors
                                          .grey,
                                  fontWeight:
                                      FontWeight
                                          .w500,
                                ),
                              ),

                              const Spacer(),

                              IconButton(
                                tooltip:
                                    "Remove Set",
                                onPressed:
                                    draft.defaultSets >
                                            1
                                        ? () {
                                            setState(
                                              () {
                                                draft.defaultSets--;
                                              },
                                            );
                                          }
                                        : null,
                                icon:
                                    const Icon(
                                  Icons
                                      .remove_circle_outline,
                                ),
                              ),

                              Container(
                                width: 42,
                                height: 38,
                                alignment:
                                    Alignment
                                        .center,
                                decoration:
                                    BoxDecoration(
                                  color:
                                      const Color(
                                    0xFF292929,
                                  ),
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    8,
                                  ),
                                ),
                                child:
                                    Text(
                                  "${draft.defaultSets}",
                                  style:
                                      const TextStyle(
                                    fontSize:
                                        17,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                              ),

                              IconButton(
                                tooltip:
                                    "Add Set",
                                onPressed:
                                    draft.defaultSets <
                                            20
                                        ? () {
                                            setState(
                                              () {
                                                draft.defaultSets++;
                                              },
                                            );
                                          }
                                        : null,
                                icon:
                                    const Icon(
                                  Icons
                                      .add_circle_outline,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              SizedBox(
                width:
                    double.infinity,
                child:
                    OutlinedButton
                        .icon(
                  onPressed:
                      addExercise,
                  icon:
                      const Icon(
                    Icons.add,
                  ),
                  label:
                      const Text(
                    "Add Exercise",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(
              context,
            );
          },
          child:
              const Text(
            "Cancel",
          ),
        ),
        ElevatedButton(
          onPressed: save,
          child: Text(
            widget.routine ==
                    null
                ? "Create"
                : "Save Changes",
          ),
        ),
      ],
    );
  }
}

class RoutineExerciseDraft {
  final TextEditingController
      nameController;

  int defaultSets;

  RoutineExerciseDraft({
    required String name,
    required this.defaultSets,
  }) : nameController =
            TextEditingController(
          text: name,
        );

  void dispose() {
    nameController.dispose();
  }
}

// =====================================================
// WORKOUT DATA
// =====================================================

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
          (set) =>
              set.completed,
        )
        .fold(
          0,
          (total, set) =>
              total +
              set.volume,
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
              : formatWeight(
                  weight,
                ),
        ),
        repsController =
            TextEditingController(
          text:
              reps?.toString() ??
                  "",
        );

  double get weight =>
      double.tryParse(
        weightController.text
            .trim(),
      ) ??
      0;

  int get reps =>
      int.tryParse(
        repsController.text
            .trim(),
      ) ??
      0;

  double get volume =>
      weight * reps;

  void dispose() {
    weightController.dispose();
    repsController.dispose();
  }
}

// =====================================================
// EXERCISE CARD
// =====================================================

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
  Widget build(
    BuildContext context,
  ) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets
                .fromLTRB(
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
                      Color(
                    0xFF341010,
                  ),
                  child: Icon(
                    Icons
                        .fitness_center,
                    color:
                        Colors.red,
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
                  onPressed:
                      enabled
                          ? onDeleteExercise
                          : null,
                  icon:
                      const Icon(
                    Icons
                        .delete_outline,
                    color:
                        Colors.red,
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
                        TextAlign
                            .center,
                    style:
                        SetHeaderStyle
                            .style,
                  ),
                ),

                SizedBox(
                  width: 10,
                ),

                Expanded(
                  child: Text(
                    "KG",
                    textAlign:
                        TextAlign
                            .center,
                    style:
                        SetHeaderStyle
                            .style,
                  ),
                ),

                SizedBox(
                  width: 10,
                ),

                Expanded(
                  child: Text(
                    "REPS",
                    textAlign:
                        TextAlign
                            .center,
                    style:
                        SetHeaderStyle
                            .style,
                  ),
                ),

                SizedBox(
                  width: 10,
                ),

                SizedBox(
                  width: 42,
                  child: Text(
                    "DONE",
                    textAlign:
                        TextAlign
                            .center,
                    style:
                        SetHeaderStyle
                            .style,
                  ),
                ),

                SizedBox(
                  width: 42,
                ),
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
                    number:
                        index + 1,
                    set:
                        exercise.sets[
                            index],
                    enabled:
                        enabled,
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
              width:
                  double.infinity,
              child:
                  TextButton.icon(
                onPressed:
                    enabled
                        ? onAddSet
                        : null,
                icon:
                    const Icon(
                  Icons.add,
                ),
                label:
                    const Text(
                  "Add Set",
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
// SET ROW
// =====================================================

class SetRow
    extends StatelessWidget {
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
  Widget build(
    BuildContext context,
  ) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 44,
          alignment:
              Alignment.center,
          decoration:
              BoxDecoration(
            color: set.completed
                ? Colors.red
                    .withValues(
                      alpha:
                          0.15,
                    )
                : const Color(
                    0xFF252525,
                  ),
            borderRadius:
                BorderRadius
                    .circular(
              8,
            ),
          ),
          child: Text(
            "$number",
            style:
                TextStyle(
              fontWeight:
                  FontWeight.bold,
              color: set.completed
                  ? Colors.red
                  : Colors.white,
            ),
          ),
        ),

        const SizedBox(
          width: 10,
        ),

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
                    EdgeInsets
                        .symmetric(
                  horizontal: 8,
                ),
                border:
                    OutlineInputBorder(),
              ),
            ),
          ),
        ),

        const SizedBox(
          width: 10,
        ),

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
                  TextInputType
                      .number,
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
                    EdgeInsets
                        .symmetric(
                  horizontal: 8,
                ),
                border:
                    OutlineInputBorder(),
              ),
            ),
          ),
        ),

        const SizedBox(
          width: 10,
        ),

        SizedBox(
          width: 42,
          child: IconButton(
            tooltip:
                set.completed
                    ? "Mark Incomplete"
                    : "Complete Set",
            onPressed:
                enabled
                    ? () {
                        toggleCompleted(
                          context,
                        );
                      }
                    : null,
            icon: Icon(
              set.completed
                  ? Icons
                      .check_circle
                  : Icons
                      .radio_button_unchecked,
              color:
                  set.completed
                      ? Colors.green
                      : Colors.grey,
            ),
          ),
        ),

        SizedBox(
          width: 42,
          child: IconButton(
            tooltip:
                "Delete Set",
            onPressed:
                enabled
                    ? onDelete
                    : null,
            icon:
                const Icon(
              Icons.close,
              size: 19,
              color:
                  Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}

// =====================================================
// EMPTY WORKOUT
// =====================================================

class EmptyWorkoutState
    extends StatelessWidget {
  final VoidCallback
      onAddExercise;

  final bool enabled;

  const EmptyWorkoutState({
    super.key,
    required this.onAddExercise,
    required this.enabled,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets
              .symmetric(
        vertical: 44,
        horizontal: 24,
      ),
      decoration: BoxDecoration(
        color:
            const Color(
          0xFF1E1E1E,
        ),
        borderRadius:
            BorderRadius.circular(
          14,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.fitness_center,
            size: 46,
            color: Colors.grey,
          ),

          const SizedBox(
            height: 16,
          ),

          const Text(
            "Add your first exercise",
            style: TextStyle(
              fontSize: 19,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 7,
          ),

          const Text(
            "Your workout timer is running. "
            "Add an exercise and start logging sets.",
            textAlign:
                TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          OutlinedButton.icon(
            onPressed:
                enabled
                    ? onAddExercise
                    : null,
            icon:
                const Icon(
              Icons.add,
            ),
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

String formatWeight(
  double value,
) {
  if (value ==
      value.roundToDouble()) {
    return value
        .toInt()
        .toString();
  }

  return value
      .toStringAsFixed(1);
}

String formatNumber(
  double value,
) {
  if (value ==
      value.roundToDouble()) {
    return value
        .toInt()
        .toString();
  }

  return value
      .toStringAsFixed(1);
}