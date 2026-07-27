import 'package:flutter/material.dart';

import '../models/workout.dart';
import '../services/app_state.dart';

class EditWorkoutScreen extends StatefulWidget {
  final WorkoutData workout;

  const EditWorkoutScreen({
    super.key,
    required this.workout,
  });

  @override
  State<EditWorkoutScreen> createState() =>
      _EditWorkoutScreenState();
}

class _EditWorkoutScreenState
    extends State<EditWorkoutScreen> {
  late List<EditableExercise> exercises;

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    exercises = widget.workout.exercises.map(
      (exercise) {
        return EditableExercise(
          name: exercise.name,
          sets: exercise.sets.map(
            (set) {
              return EditableSet(
                weight: set.weight,
                reps: set.reps,
              );
            },
          ).toList(),
        );
      },
    ).toList();
  }

  @override
  void dispose() {
    for (final exercise in exercises) {
      exercise.dispose();
    }

    super.dispose();
  }

  void _addExercise() {
    if (_saving) return;

    setState(() {
      exercises.add(
        EditableExercise(
          name: "",
          sets: [
            EditableSet(),
          ],
        ),
      );
    });
  }

  void _deleteExercise(int index) {
    if (_saving) return;

    final exercise =
        exercises.removeAt(index);

    exercise.dispose();

    setState(() {});
  }

  void _addSet(int exerciseIndex) {
    if (_saving) return;

    final exercise =
        exercises[exerciseIndex];

    double? previousWeight;
    int? previousReps;

    if (exercise.sets.isNotEmpty) {
      final previous =
          exercise.sets.last;

      previousWeight =
          double.tryParse(
        previous.weightController.text
            .trim(),
      );

      previousReps =
          int.tryParse(
        previous.repsController.text
            .trim(),
      );
    }

    setState(() {
      exercise.sets.add(
        EditableSet(
          weight: previousWeight,
          reps: previousReps,
        ),
      );
    });
  }

  void _deleteSet(
    int exerciseIndex,
    int setIndex,
  ) {
    if (_saving) return;

    final exercise =
        exercises[exerciseIndex];

    final removed =
        exercise.sets.removeAt(
      setIndex,
    );

    removed.dispose();

    setState(() {});
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .clearSnackBars();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (_saving) return;

    if (exercises.isEmpty) {
      _showMessage(
        "Workout must contain at least one exercise.",
      );

      return;
    }

    final updatedExercises =
        <ExerciseData>[];

    for (final exercise in exercises) {
      final name =
          exercise.nameController.text
              .trim();

      if (name.isEmpty) {
        _showMessage(
          "Every exercise needs a name.",
        );

        return;
      }

      if (exercise.sets.isEmpty) {
        _showMessage(
          "$name needs at least one set.",
        );

        return;
      }

      final sets = <WorkoutSetData>[];

      for (final set in exercise.sets) {
        final weight =
            double.tryParse(
          set.weightController.text
              .trim(),
        );

        final reps =
            int.tryParse(
          set.repsController.text
              .trim(),
        );

        if (weight == null ||
            weight < 0 ||
            reps == null ||
            reps <= 0) {
          _showMessage(
            "Enter valid weight and reps for $name.",
          );

          return;
        }

        sets.add(
          WorkoutSetData(
            weight: weight,
            reps: reps,
          ),
        );
      }

      updatedExercises.add(
        ExerciseData(
          name: name,
          sets: sets,
        ),
      );
    }

    final updatedWorkout =
        WorkoutData(
      id: widget.workout.id,
      date: widget.workout.date,
      durationSeconds:
          widget.workout.durationSeconds,
      exercises: updatedExercises,
    );

    setState(() {
      _saving = true;
    });

    try {
      await AppState.instance
          .updateWorkout(
        updatedWorkout,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      _showMessage(
        "Couldn't update workout. "
        "Please check the backend and try again.",
      );

      debugPrint(
        "Workout update failed: $error",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Workout",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
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
                _WorkoutInfoCard(
                  workout: widget.workout,
                ),

                const SizedBox(height: 20),

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

                    ElevatedButton.icon(
                      onPressed:
                          _saving
                              ? null
                              : _addExercise,
                      icon:
                          const Icon(Icons.add),
                      label: const Text(
                        "Exercise",
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                if (exercises.isEmpty)
                  const _EmptyEditorState()
                else
                  ...List.generate(
                    exercises.length,
                    (index) {
                      return Padding(
                        padding:
                            const EdgeInsets
                                .only(
                          bottom: 16,
                        ),
                        child:
                            EditableExerciseCard(
                          exercise:
                              exercises[index],
                          exerciseNumber:
                              index + 1,
                          enabled: !_saving,
                          onDeleteExercise:
                              () {
                            _deleteExercise(
                              index,
                            );
                          },
                          onAddSet: () {
                            _addSet(index);
                          },
                          onDeleteSet:
                              (setIndex) {
                            _deleteSet(
                              index,
                              setIndex,
                            );
                          },
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
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child:
                          OutlinedButton(
                        onPressed:
                            _saving
                                ? null
                                : () {
                                    Navigator.pop(
                                      context,
                                    );
                                  },
                        child:
                            const Text(
                          "Cancel",
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 54,
                      child:
                          ElevatedButton(
                        onPressed:
                            _saving
                                ? null
                                : _saveChanges,
                        child: _saving
                            ? const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .center,
                                children: [
                                  SizedBox(
                                    width: 19,
                                    height: 19,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth:
                                          2.5,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "Saving...",
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
                                        .save_outlined,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    "Save Changes",
                                    style:
                                        TextStyle(
                                      fontWeight:
                                          FontWeight
                                              .bold,
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
    );
  }
}

class EditableExercise {
  final TextEditingController
      nameController;

  final List<EditableSet> sets;

  EditableExercise({
    required String name,
    required this.sets,
  }) : nameController =
            TextEditingController(
          text: name,
        );

  void dispose() {
    nameController.dispose();

    for (final set in sets) {
      set.dispose();
    }
  }
}

class EditableSet {
  final TextEditingController
      weightController;

  final TextEditingController
      repsController;

  EditableSet({
    double? weight,
    int? reps,
  })  : weightController =
            TextEditingController(
          text: weight == null
              ? ""
              : formatEditableNumber(
                  weight,
                ),
        ),
        repsController =
            TextEditingController(
          text: reps?.toString() ?? "",
        );

  void dispose() {
    weightController.dispose();
    repsController.dispose();
  }
}

class EditableExerciseCard
    extends StatelessWidget {
  final EditableExercise exercise;
  final int exerciseNumber;
  final bool enabled;

  final VoidCallback
      onDeleteExercise;

  final VoidCallback onAddSet;

  final void Function(int)
      onDeleteSet;

  const EditableExerciseCard({
    super.key,
    required this.exercise,
    required this.exerciseNumber,
    required this.enabled,
    required this.onDeleteExercise,
    required this.onAddSet,
    required this.onDeleteSet,
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
                    "$exerciseNumber",
                    style:
                        const TextStyle(
                      color: Colors.red,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: TextField(
                    controller:
                        exercise
                            .nameController,
                    enabled: enabled,
                    textCapitalization:
                        TextCapitalization
                            .words,
                    decoration:
                        const InputDecoration(
                      labelText:
                          "Exercise Name",
                      hintText:
                          "Bench Press",
                      border:
                          OutlineInputBorder(),
                    ),
                  ),
                ),

                const SizedBox(width: 6),

                IconButton(
                  tooltip:
                      "Delete Exercise",
                  onPressed:
                      enabled
                          ? onDeleteExercise
                          : null,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    "SET",
                    textAlign:
                        TextAlign.center,
                    style:
                        _EditorHeaderStyle
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
                        _EditorHeaderStyle
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
                        _EditorHeaderStyle
                            .style,
                  ),
                ),

                SizedBox(width: 42),
              ],
            ),

            const SizedBox(height: 8),

            ...List.generate(
              exercise.sets.length,
              (index) {
                return Padding(
                  padding:
                      const EdgeInsets.only(
                    bottom: 9,
                  ),
                  child: EditableSetRow(
                    number: index + 1,
                    set:
                        exercise.sets[index],
                    enabled: enabled,
                    onDelete: () {
                      onDeleteSet(index);
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

class EditableSetRow
    extends StatelessWidget {
  final int number;
  final EditableSet set;
  final bool enabled;

  final VoidCallback onDelete;

  const EditableSetRow({
    super.key,
    required this.number,
    required this.set,
    required this.enabled,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color:
                const Color(0xFF252525),
            borderRadius:
                BorderRadius.circular(8),
          ),
          child: Text(
            "$number",
            style: const TextStyle(
              fontWeight:
                  FontWeight.bold,
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
              enabled: enabled,
              keyboardType:
                  const TextInputType
                      .numberWithOptions(
                decimal: true,
              ),
              textAlign:
                  TextAlign.center,
              decoration:
                  const InputDecoration(
                hintText: "0",
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
              enabled: enabled,
              keyboardType:
                  TextInputType.number,
              textAlign:
                  TextAlign.center,
              decoration:
                  const InputDecoration(
                hintText: "0",
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
              color: Colors.grey,
              size: 19,
            ),
          ),
        ),
      ],
    );
  }
}

class _WorkoutInfoCard
    extends StatelessWidget {
  final WorkoutData workout;

  const _WorkoutInfoCard({
    required this.workout,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(
              Icons.edit_note_rounded,
              color: Colors.red,
              size: 30,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  const Text(
                    "Editing Completed Workout",
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    "Duration: "
                    "${formatEditorDuration(workout.durationSeconds)}",
                    style:
                        const TextStyle(
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

class _EmptyEditorState
    extends StatelessWidget {
  const _EmptyEditorState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(30),
      alignment: Alignment.center,
      child: const Text(
        "Add an exercise to continue.",
        style: TextStyle(
          color: Colors.grey,
        ),
      ),
    );
  }
}

class _EditorHeaderStyle {
  static const TextStyle style =
      TextStyle(
    color: Colors.grey,
    fontSize: 11,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.7,
  );
}

String formatEditableNumber(
  double value,
) {
  if (value ==
      value.roundToDouble()) {
    return value.toInt().toString();
  }

  return value.toStringAsFixed(1);
}

String formatEditorDuration(
  int seconds,
) {
  final hours = seconds ~/ 3600;
  final minutes =
      (seconds % 3600) ~/ 60;
  final remaining =
      seconds % 60;

  if (hours > 0) {
    return "${hours}h ${minutes}m";
  }

  if (minutes > 0) {
    return "${minutes}m ${remaining}s";
  }

  return "${remaining}s";
}