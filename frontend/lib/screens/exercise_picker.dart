import 'package:flutter/material.dart';

import '../models/exercise_library.dart';

class ExercisePicker extends StatefulWidget {
  final Set<String> excludedExercises;

  const ExercisePicker({
    super.key,
    this.excludedExercises = const {},
  });

  @override
  State<ExercisePicker> createState() =>
      _ExercisePickerState();
}

class _ExercisePickerState
    extends State<ExercisePicker> {
  final TextEditingController searchController =
      TextEditingController();

  String selectedCategory = 'All';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<LibraryExercise> get filteredExercises {
    final query =
        searchController.text.trim().toLowerCase();

    return ExerciseLibrary.exercises.where(
      (exercise) {
        final categoryMatches =
            selectedCategory == 'All' ||
                exercise.category ==
                    selectedCategory;

        final searchMatches =
            query.isEmpty ||
                exercise.name
                    .toLowerCase()
                    .contains(query) ||
                exercise.primaryMuscle
                    .toLowerCase()
                    .contains(query) ||
                exercise.equipment
                    .toLowerCase()
                    .contains(query);

        return categoryMatches && searchMatches;
      },
    ).toList();
  }

  bool isExcluded(String name) {
    return widget.excludedExercises.any(
      (existing) =>
          existing.trim().toLowerCase() ==
          name.trim().toLowerCase(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exercises = filteredExercises;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Exercise Library',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                14,
                20,
                10,
              ),
              child: TextField(
                controller: searchController,
                autofocus: true,
                onChanged: (_) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText:
                      'Search exercises, muscles or equipment',
                  prefixIcon:
                      const Icon(Icons.search),
                  suffixIcon:
                      searchController.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                searchController.clear();
                                setState(() {});
                              },
                              icon: const Icon(
                                Icons.close,
                              ),
                            ),
                  border:
                      const OutlineInputBorder(),
                ),
              ),
            ),

            SizedBox(
              height: 48,
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                scrollDirection: Axis.horizontal,
                itemCount:
                    ExerciseLibrary.categories.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category =
                      ExerciseLibrary.categories[
                          index];

                  final selected =
                      selectedCategory == category;

                  return ChoiceChip(
                    label: Text(category),
                    selected: selected,
                    showCheckmark: false,
                    selectedColor: Colors.red
                        .withValues(alpha: 0.20),
                    side: BorderSide(
                      color: selected
                          ? Colors.red
                          : const Color(
                              0xFF444444,
                            ),
                    ),
                    labelStyle: TextStyle(
                      color: selected
                          ? Colors.red
                          : Colors.grey,
                      fontWeight: selected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    onSelected: (_) {
                      setState(() {
                        selectedCategory =
                            category;
                      });
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Row(
                children: [
                  Text(
                    '${exercises.length} exercises',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Tap to select',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: exercises.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off,
                            color: Colors.grey,
                            size: 44,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No exercises found',
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Try another search or category.',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding:
                          const EdgeInsets.fromLTRB(
                        20,
                        8,
                        20,
                        30,
                      ),
                      itemCount: exercises.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(
                        height: 8,
                      ),
                      itemBuilder: (
                        context,
                        index,
                      ) {
                        final exercise =
                            exercises[index];

                        final excluded =
                            isExcluded(
                          exercise.name,
                        );

                        return Card(
                          child: ListTile(
                            enabled: !excluded,
                            contentPadding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 16,
                              vertical: 7,
                            ),
                            leading: CircleAvatar(
                              backgroundColor:
                                  excluded
                                      ? const Color(
                                          0xFF242424,
                                        )
                                      : const Color(
                                          0xFF341010,
                                        ),
                              child: Icon(
                                categoryIcon(
                                  exercise.category,
                                ),
                                color: excluded
                                    ? Colors.grey
                                    : Colors.red,
                              ),
                            ),
                            title: Text(
                              exercise.name,
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                                color: excluded
                                    ? Colors.grey
                                    : null,
                              ),
                            ),
                            subtitle: Padding(
                              padding:
                                  const EdgeInsets.only(
                                top: 4,
                              ),
                              child: Text(
                                '${exercise.primaryMuscle}'
                                ' • '
                                '${exercise.equipment}',
                              ),
                            ),
                            trailing: excluded
                                ? const Chip(
                                    label: Text(
                                      'Added',
                                    ),
                                  )
                                : const Icon(
                                    Icons
                                        .add_circle_outline,
                                    color: Colors.red,
                                  ),
                            onTap: excluded
                                ? null
                                : () {
                                    Navigator.pop(
                                      context,
                                      exercise,
                                    );
                                  },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData categoryIcon(
  String category,
) {
  switch (category) {
    case 'Chest':
      return Icons.fitness_center;

    case 'Back':
      return Icons.accessibility_new;

    case 'Shoulders':
      return Icons.sports_gymnastics;

    case 'Arms':
      return Icons.fitness_center;

    case 'Legs':
      return Icons.directions_run;

    case 'Core':
      return Icons.accessibility;

    case 'Cardio':
      return Icons.favorite_outline;

    default:
      return Icons.fitness_center;
  }
}