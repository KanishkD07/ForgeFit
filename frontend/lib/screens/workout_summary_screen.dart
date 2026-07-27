import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

class WorkoutSummaryScreen extends StatelessWidget {
  final int totalExercises;
  final int totalSets;
  final double totalVolume;
  final int durationSeconds;
  final bool newPR;

  const WorkoutSummaryScreen({
    super.key,
    required this.totalExercises,
    required this.totalSets,
    required this.totalVolume,
    required this.durationSeconds,
    required this.newPR,
  });

  String get formattedDuration {
    final hours = durationSeconds ~/ 3600;
    final minutes = (durationSeconds % 3600) ~/ 60;
    final seconds = durationSeconds % 60;

    if (hours > 0) {
      return "${hours}h ${minutes}m ${seconds}s";
    }

    if (minutes > 0) {
      return "${minutes}m ${seconds}s";
    }

    return "${seconds}s";
  }

  String get formattedVolume {
    if (totalVolume == totalVolume.roundToDouble()) {
      return totalVolume.toInt().toString();
    }

    return totalVolume.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            30,
            20,
            24,
          ),
          child: Column(
            children: [
              const Spacer(),

              Container(
                width: 105,
                height: 105,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(
                    alpha: 0.12,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.red,
                  size: 64,
                ),
              ),

              const SizedBox(height: 26),

              const Text(
                "Workout Complete!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Another session in the books.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 36),

              Row(
                children: [
                  Expanded(
                    child: SummaryCard(
                      icon: Icons.timer_outlined,
                      value: formattedDuration,
                      label: "Duration",
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: SummaryCard(
                      icon: Icons.fitness_center,
                      value: "$totalExercises",
                      label: "Exercises",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: SummaryCard(
                      icon: Icons.checklist_rounded,
                      value: "$totalSets",
                      label: "Sets",
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: SummaryCard(
                      icon: Icons.bar_chart_rounded,
                      value: "$formattedVolume kg",
                      label: "Volume",
                    ),
                  ),
                ],
              ),

              if (newPR) ...[
                const SizedBox(height: 18),

                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor:
                              Color(0xFF352900),
                          child: Icon(
                            Icons.emoji_events,
                            color: Colors.amber,
                          ),
                        ),

                        SizedBox(width: 15),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                "New Personal Record!",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              SizedBox(height: 4),

                              Text(
                                "You hit a new milestone today.",
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
                ),
              ],

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const DashboardScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text(
                    "Back to Dashboard",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
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

class SummaryCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const SummaryCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 12,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.red,
              size: 26,
            ),

            const SizedBox(height: 12),

            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 5),

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