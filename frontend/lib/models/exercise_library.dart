class LibraryExercise {
  final String name;
  final String category;
  final String primaryMuscle;
  final String equipment;

  const LibraryExercise({
    required this.name,
    required this.category,
    required this.primaryMuscle,
    required this.equipment,
  });
}

class ExerciseLibrary {
  ExerciseLibrary._();

  static const List<String> categories = [
    'All',
    'Chest',
    'Back',
    'Shoulders',
    'Arms',
    'Legs',
    'Core',
    'Cardio',
  ];

  static const List<LibraryExercise> exercises = [
    // CHEST
    LibraryExercise(
      name: 'Barbell Bench Press',
      category: 'Chest',
      primaryMuscle: 'Chest',
      equipment: 'Barbell',
    ),
    LibraryExercise(
      name: 'Dumbbell Bench Press',
      category: 'Chest',
      primaryMuscle: 'Chest',
      equipment: 'Dumbbells',
    ),
    LibraryExercise(
      name: 'Incline Barbell Bench Press',
      category: 'Chest',
      primaryMuscle: 'Upper Chest',
      equipment: 'Barbell',
    ),
    LibraryExercise(
      name: 'Incline Dumbbell Press',
      category: 'Chest',
      primaryMuscle: 'Upper Chest',
      equipment: 'Dumbbells',
    ),
    LibraryExercise(
      name: 'Decline Bench Press',
      category: 'Chest',
      primaryMuscle: 'Lower Chest',
      equipment: 'Barbell',
    ),
    LibraryExercise(
      name: 'Chest Press Machine',
      category: 'Chest',
      primaryMuscle: 'Chest',
      equipment: 'Machine',
    ),
    LibraryExercise(
      name: 'Cable Chest Fly',
      category: 'Chest',
      primaryMuscle: 'Chest',
      equipment: 'Cable',
    ),
    LibraryExercise(
      name: 'Dumbbell Fly',
      category: 'Chest',
      primaryMuscle: 'Chest',
      equipment: 'Dumbbells',
    ),
    LibraryExercise(
      name: 'Push Up',
      category: 'Chest',
      primaryMuscle: 'Chest',
      equipment: 'Bodyweight',
    ),
    LibraryExercise(
      name: 'Chest Dip',
      category: 'Chest',
      primaryMuscle: 'Lower Chest',
      equipment: 'Bodyweight',
    ),

    // BACK
    LibraryExercise(
      name: 'Deadlift',
      category: 'Back',
      primaryMuscle: 'Posterior Chain',
      equipment: 'Barbell',
    ),
    LibraryExercise(
      name: 'Barbell Row',
      category: 'Back',
      primaryMuscle: 'Back',
      equipment: 'Barbell',
    ),
    LibraryExercise(
      name: 'Dumbbell Row',
      category: 'Back',
      primaryMuscle: 'Lats',
      equipment: 'Dumbbell',
    ),
    LibraryExercise(
      name: 'Lat Pulldown',
      category: 'Back',
      primaryMuscle: 'Lats',
      equipment: 'Cable',
    ),
    LibraryExercise(
      name: 'Pull Up',
      category: 'Back',
      primaryMuscle: 'Lats',
      equipment: 'Bodyweight',
    ),
    LibraryExercise(
      name: 'Chin Up',
      category: 'Back',
      primaryMuscle: 'Lats',
      equipment: 'Bodyweight',
    ),
    LibraryExercise(
      name: 'Seated Cable Row',
      category: 'Back',
      primaryMuscle: 'Mid Back',
      equipment: 'Cable',
    ),
    LibraryExercise(
      name: 'Chest Supported Row',
      category: 'Back',
      primaryMuscle: 'Upper Back',
      equipment: 'Machine',
    ),
    LibraryExercise(
      name: 'T-Bar Row',
      category: 'Back',
      primaryMuscle: 'Mid Back',
      equipment: 'Barbell',
    ),
    LibraryExercise(
      name: 'Straight Arm Pulldown',
      category: 'Back',
      primaryMuscle: 'Lats',
      equipment: 'Cable',
    ),

    // SHOULDERS
    LibraryExercise(
      name: 'Overhead Press',
      category: 'Shoulders',
      primaryMuscle: 'Shoulders',
      equipment: 'Barbell',
    ),
    LibraryExercise(
      name: 'Dumbbell Shoulder Press',
      category: 'Shoulders',
      primaryMuscle: 'Shoulders',
      equipment: 'Dumbbells',
    ),
    LibraryExercise(
      name: 'Arnold Press',
      category: 'Shoulders',
      primaryMuscle: 'Shoulders',
      equipment: 'Dumbbells',
    ),
    LibraryExercise(
      name: 'Lateral Raise',
      category: 'Shoulders',
      primaryMuscle: 'Side Delts',
      equipment: 'Dumbbells',
    ),
    LibraryExercise(
      name: 'Cable Lateral Raise',
      category: 'Shoulders',
      primaryMuscle: 'Side Delts',
      equipment: 'Cable',
    ),
    LibraryExercise(
      name: 'Front Raise',
      category: 'Shoulders',
      primaryMuscle: 'Front Delts',
      equipment: 'Dumbbells',
    ),
    LibraryExercise(
      name: 'Reverse Pec Deck',
      category: 'Shoulders',
      primaryMuscle: 'Rear Delts',
      equipment: 'Machine',
    ),
    LibraryExercise(
      name: 'Face Pull',
      category: 'Shoulders',
      primaryMuscle: 'Rear Delts',
      equipment: 'Cable',
    ),

    // ARMS
    LibraryExercise(
      name: 'Barbell Curl',
      category: 'Arms',
      primaryMuscle: 'Biceps',
      equipment: 'Barbell',
    ),
    LibraryExercise(
      name: 'Dumbbell Curl',
      category: 'Arms',
      primaryMuscle: 'Biceps',
      equipment: 'Dumbbells',
    ),
    LibraryExercise(
      name: 'Hammer Curl',
      category: 'Arms',
      primaryMuscle: 'Biceps',
      equipment: 'Dumbbells',
    ),
    LibraryExercise(
      name: 'Preacher Curl',
      category: 'Arms',
      primaryMuscle: 'Biceps',
      equipment: 'Machine',
    ),
    LibraryExercise(
      name: 'Cable Curl',
      category: 'Arms',
      primaryMuscle: 'Biceps',
      equipment: 'Cable',
    ),
    LibraryExercise(
      name: 'Tricep Pushdown',
      category: 'Arms',
      primaryMuscle: 'Triceps',
      equipment: 'Cable',
    ),
    LibraryExercise(
      name: 'Rope Pushdown',
      category: 'Arms',
      primaryMuscle: 'Triceps',
      equipment: 'Cable',
    ),
    LibraryExercise(
      name: 'Overhead Tricep Extension',
      category: 'Arms',
      primaryMuscle: 'Triceps',
      equipment: 'Cable',
    ),
    LibraryExercise(
      name: 'Skull Crusher',
      category: 'Arms',
      primaryMuscle: 'Triceps',
      equipment: 'EZ Bar',
    ),
    LibraryExercise(
      name: 'Close Grip Bench Press',
      category: 'Arms',
      primaryMuscle: 'Triceps',
      equipment: 'Barbell',
    ),

    // LEGS
    LibraryExercise(
      name: 'Barbell Squat',
      category: 'Legs',
      primaryMuscle: 'Quadriceps',
      equipment: 'Barbell',
    ),
    LibraryExercise(
      name: 'Front Squat',
      category: 'Legs',
      primaryMuscle: 'Quadriceps',
      equipment: 'Barbell',
    ),
    LibraryExercise(
      name: 'Hack Squat',
      category: 'Legs',
      primaryMuscle: 'Quadriceps',
      equipment: 'Machine',
    ),
    LibraryExercise(
      name: 'Leg Press',
      category: 'Legs',
      primaryMuscle: 'Quadriceps',
      equipment: 'Machine',
    ),
    LibraryExercise(
      name: 'Leg Extension',
      category: 'Legs',
      primaryMuscle: 'Quadriceps',
      equipment: 'Machine',
    ),
    LibraryExercise(
      name: 'Romanian Deadlift',
      category: 'Legs',
      primaryMuscle: 'Hamstrings',
      equipment: 'Barbell',
    ),
    LibraryExercise(
      name: 'Leg Curl',
      category: 'Legs',
      primaryMuscle: 'Hamstrings',
      equipment: 'Machine',
    ),
    LibraryExercise(
      name: 'Bulgarian Split Squat',
      category: 'Legs',
      primaryMuscle: 'Quadriceps',
      equipment: 'Dumbbells',
    ),
    LibraryExercise(
      name: 'Walking Lunge',
      category: 'Legs',
      primaryMuscle: 'Legs',
      equipment: 'Dumbbells',
    ),
    LibraryExercise(
      name: 'Hip Thrust',
      category: 'Legs',
      primaryMuscle: 'Glutes',
      equipment: 'Barbell',
    ),
    LibraryExercise(
      name: 'Standing Calf Raise',
      category: 'Legs',
      primaryMuscle: 'Calves',
      equipment: 'Machine',
    ),
    LibraryExercise(
      name: 'Seated Calf Raise',
      category: 'Legs',
      primaryMuscle: 'Calves',
      equipment: 'Machine',
    ),

    // CORE
    LibraryExercise(
      name: 'Plank',
      category: 'Core',
      primaryMuscle: 'Core',
      equipment: 'Bodyweight',
    ),
    LibraryExercise(
      name: 'Crunch',
      category: 'Core',
      primaryMuscle: 'Abs',
      equipment: 'Bodyweight',
    ),
    LibraryExercise(
      name: 'Cable Crunch',
      category: 'Core',
      primaryMuscle: 'Abs',
      equipment: 'Cable',
    ),
    LibraryExercise(
      name: 'Hanging Leg Raise',
      category: 'Core',
      primaryMuscle: 'Abs',
      equipment: 'Bodyweight',
    ),
    LibraryExercise(
      name: 'Russian Twist',
      category: 'Core',
      primaryMuscle: 'Obliques',
      equipment: 'Bodyweight',
    ),
    LibraryExercise(
      name: 'Ab Wheel Rollout',
      category: 'Core',
      primaryMuscle: 'Core',
      equipment: 'Ab Wheel',
    ),

    // CARDIO
    LibraryExercise(
      name: 'Treadmill Running',
      category: 'Cardio',
      primaryMuscle: 'Cardiovascular',
      equipment: 'Treadmill',
    ),
    LibraryExercise(
      name: 'Cycling',
      category: 'Cardio',
      primaryMuscle: 'Cardiovascular',
      equipment: 'Bike',
    ),
    LibraryExercise(
      name: 'Rowing Machine',
      category: 'Cardio',
      primaryMuscle: 'Cardiovascular',
      equipment: 'Rowing Machine',
    ),
    LibraryExercise(
      name: 'Stair Climber',
      category: 'Cardio',
      primaryMuscle: 'Cardiovascular',
      equipment: 'Machine',
    ),
  ];
}