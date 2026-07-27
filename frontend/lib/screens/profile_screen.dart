import 'package:flutter/material.dart';

import '../services/app_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AppState appState = AppState.instance;

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

  Future<void> _editProfile() async {
    final profile = appState.profile;

    final nameController = TextEditingController(
      text: profile.name,
    );

    final heightController = TextEditingController(
      text: formatNumber(profile.height),
    );

    final weightController = TextEditingController(
      text: formatNumber(profile.weight),
    );

    final goalController = TextEditingController(
      text: profile.goal,
    );

    final result = await showDialog<ProfileEditResult>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Edit Profile"),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: "Name",
                    prefixIcon: Icon(
                      Icons.person_outline,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: heightController,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: "Height",
                    suffixText: "cm",
                    prefixIcon: Icon(Icons.height),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: weightController,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: "Weight",
                    suffixText: "kg",
                    prefixIcon: Icon(
                      Icons.monitor_weight_outlined,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: goalController,
                  textCapitalization:
                      TextCapitalization.sentences,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Training Goal",
                    hintText: "What are you training for?",
                    prefixIcon: Icon(
                      Icons.flag_outlined,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();

                final height = double.tryParse(
                  heightController.text.trim(),
                );

                final weight = double.tryParse(
                  weightController.text.trim(),
                );

                final goal = goalController.text.trim();

                if (name.isEmpty ||
                    goal.isEmpty ||
                    height == null ||
                    weight == null ||
                    height <= 0 ||
                    weight <= 0) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Enter valid profile details.",
                      ),
                    ),
                  );

                  return;
                }

                Navigator.pop(
                  dialogContext,
                  ProfileEditResult(
                    name: name,
                    height: height,
                    weight: weight,
                    goal: goal,
                  ),
                );
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    heightController.dispose();
    weightController.dispose();
    goalController.dispose();

    if (result == null) return;

    appState.updateProfile(
      name: result.name,
      height: result.height,
      weight: result.weight,
      goal: result.goal,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profile updated"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = appState.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: "Edit Profile",
            onPressed: _editProfile,
            icon: const Icon(
              Icons.edit_outlined,
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          12,
          20,
          30,
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),

            CircleAvatar(
              radius: 55,
              backgroundColor:
                  Colors.red.withValues(alpha: 0.12),
              child: Text(
                getInitial(profile.name),
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),

            const SizedBox(height: 18),

            Text(
              profile.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              profile.goal,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: ProfileStatCard(
                    icon: Icons.height,
                    value: formatNumber(
                      profile.height,
                    ),
                    label: "Height",
                    unit: "cm",
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ProfileStatCard(
                    icon:
                        Icons.monitor_weight_outlined,
                    value: formatNumber(
                      profile.weight,
                    ),
                    label: "Weight",
                    unit: "kg",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ProfileStatCard(
                    icon: Icons.fitness_center,
                    value:
                        "${appState.totalWorkouts}",
                    label: "Workouts",
                    unit: "",
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ProfileStatCard(
                    icon:
                        Icons.emoji_events_outlined,
                    value:
                        "${appState.totalPersonalRecords}",
                    label: "PRs",
                    unit: "",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            ProfileInfoCard(
              icon: Icons.flag_outlined,
              title: "Training Goal",
              value: profile.goal,
            ),

            const SizedBox(height: 12),

            ProfileInfoCard(
              icon:
                  Icons.calendar_month_outlined,
              title: "Member Since",
              value: formatMemberSince(
                profile.memberSince,
              ),
            ),

            const SizedBox(height: 12),

            ProfileInfoCard(
              icon: Icons.bar_chart_rounded,
              title: "Total Volume Lifted",
              value:
                  "${formatCompactVolume(appState.totalVolume)} kg",
            ),

            const SizedBox(height: 12),

            ProfileInfoCard(
              icon: Icons.timer_outlined,
              title: "Total Training Time",
              value: formatTrainingTime(
                appState.totalTrainingSeconds,
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton.icon(
                onPressed: _editProfile,
                icon: const Icon(
                  Icons.edit_outlined,
                ),
                label: const Text(
                  "Edit Profile",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileEditResult {
  final String name;
  final double height;
  final double weight;
  final String goal;

  const ProfileEditResult({
    required this.name,
    required this.height,
    required this.weight,
    required this.goal,
  });
}

class ProfileStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final String unit;

  const ProfileStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 22,
          horizontal: 12,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.red,
              size: 28,
            ),

            const SizedBox(height: 12),

            FittedBox(
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  if (unit.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Text(
                      unit,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 5),

            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const ProfileInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.red,
              size: 28,
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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

String getInitial(String name) {
  final trimmed = name.trim();

  if (trimmed.isEmpty) {
    return "?";
  }

  return trimmed[0].toUpperCase();
}

String formatMemberSince(DateTime date) {
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

  return "${months[date.month - 1]} ${date.year}";
}

String formatTrainingTime(int seconds) {
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  final remainingSeconds = seconds % 60;

  if (hours > 0) {
    return "${hours}h ${minutes}m";
  }

  if (minutes > 0) {
    return "${minutes}m";
  }

  return "${remainingSeconds}s";
}

String formatCompactVolume(double volume) {
  if (volume >= 1000000) {
    return "${(volume / 1000000).toStringAsFixed(1)}M";
  }

  if (volume >= 1000) {
    return "${(volume / 1000).toStringAsFixed(1)}k";
  }

  return formatNumber(volume);
}

String formatNumber(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }

  return value.toStringAsFixed(1);
}