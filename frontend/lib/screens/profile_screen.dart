import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/app_state.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {
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

  String formatNumber(double value) {
    if (value ==
        value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }

  String getInitial(String name) {
    final trimmed = name.trim();

    if (trimmed.isEmpty) {
      return '?';
    }

    return trimmed[0].toUpperCase();
  }

  String formatMemberSince(
    DateTime date,
  ) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} ${date.year}';
  }

  void _selectAll(
    TextEditingController controller,
  ) {
    controller.selection =
        TextSelection(
      baseOffset: 0,
      extentOffset:
          controller.text.length,
    );
  }

  Future<void> _logout() async {
    final shouldLogout =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Log out?',
          ),
          content: const Text(
            'You will need to sign in again to access your ForgeFit account.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: const Text(
                'Log Out',
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) {
      return;
    }

    try {
      await appState.logout();

      if (!mounted) {
        return;
      }

      Navigator.of(context)
          .pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) =>
              const LoginScreen(),
        ),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            error
                .toString()
                .replaceFirst(
                  'Exception: ',
                  '',
                ),
          ),
        ),
      );
    }
  }

  Future<void> _editProfile(
    UserProfile profile,
  ) async {
    final nameController =
        TextEditingController(
      text: profile.name,
    );

    final heightController =
        TextEditingController(
      text: formatNumber(
        profile.height,
      ),
    );

    final weightController =
        TextEditingController(
      text: formatNumber(
        profile.weight,
      ),
    );

    final goalController =
        TextEditingController(
      text: profile.goal,
    );

    bool saving = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            Future<void>
                saveProfile() async {
              if (saving) {
                return;
              }

              final name =
                  nameController.text
                      .trim();

              final height =
                  double.tryParse(
                heightController.text
                    .trim(),
              );

              final weight =
                  double.tryParse(
                weightController.text
                    .trim(),
              );

              final goal =
                  goalController.text
                      .trim();

              if (name.isEmpty ||
                  height == null ||
                  height <= 0 ||
                  weight == null ||
                  weight <= 0 ||
                  goal.isEmpty) {
                ScaffoldMessenger.of(
                  this.context,
                ).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Enter valid profile details.',
                    ),
                  ),
                );

                return;
              }

              setDialogState(() {
                saving = true;
              });

              try {
                await appState
                    .updateProfile(
                  name: name,
                  height: height,
                  weight: weight,
                  goal: goal,
                );

                if (!mounted) {
                  return;
                }

                if (dialogContext
                    .mounted) {
                  Navigator.of(
                    dialogContext,
                  ).pop();
                }

                ScaffoldMessenger.of(
                  this.context,
                ).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Profile updated successfully.',
                    ),
                  ),
                );
              } catch (error) {
                if (!mounted) {
                  return;
                }

                final message = error
                    .toString()
                    .replaceFirst(
                      'Exception: ',
                      '',
                    );

                ScaffoldMessenger.of(
                  this.context,
                ).showSnackBar(
                  SnackBar(
                    content:
                        Text(message),
                  ),
                );

                setDialogState(() {
                  saving = false;
                });
              }
            }

            return AlertDialog(
              title: const Text(
                'Edit Profile',
              ),
              content:
                  SingleChildScrollView(
                child: SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      TextField(
                        controller:
                            nameController,
                        onTap: () {
                          _selectAll(
                            nameController,
                          );
                        },
                        textCapitalization:
                            TextCapitalization
                                .words,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Name',
                          prefixIcon:
                              Icon(
                            Icons
                                .person_outline,
                          ),
                          border:
                              OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      TextField(
                        controller:
                            heightController,
                        onTap: () {
                          _selectAll(
                            heightController,
                          );
                        },
                        keyboardType:
                            const TextInputType
                                .numberWithOptions(
                          decimal: true,
                        ),
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Height',
                          suffixText:
                              'cm',
                          prefixIcon:
                              Icon(
                            Icons.height,
                          ),
                          border:
                              OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      TextField(
                        controller:
                            weightController,
                        onTap: () {
                          _selectAll(
                            weightController,
                          );
                        },
                        keyboardType:
                            const TextInputType
                                .numberWithOptions(
                          decimal: true,
                        ),
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Weight',
                          suffixText:
                              'kg',
                          prefixIcon:
                              Icon(
                            Icons
                                .monitor_weight_outlined,
                          ),
                          border:
                              OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      TextField(
                        controller:
                            goalController,
                        onTap: () {
                          _selectAll(
                            goalController,
                          );
                        },
                        textCapitalization:
                            TextCapitalization
                                .sentences,
                        maxLines: 3,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Training Goal',
                          hintText:
                              'What are you training for?',
                          prefixIcon:
                              Icon(
                            Icons
                                .flag_outlined,
                          ),
                          border:
                              OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      saving
                          ? null
                          : () {
                              Navigator.of(
                                dialogContext,
                              ).pop();
                            },
                  child: const Text(
                    'Cancel',
                  ),
                ),

                ElevatedButton(
                  onPressed:
                      saving
                          ? null
                          : saveProfile,
                  child: saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth:
                                2,
                          ),
                        )
                      : const Text(
                          'Save',
                        ),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    heightController.dispose();
    weightController.dispose();
    goalController.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final profile =
        appState.profile;

    if (appState.loadingProfile &&
        profile == null) {
      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    if (profile == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Profile',
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              const Text(
                'Profile could not be loaded.',
              ),

              const SizedBox(
                height: 16,
              ),

              ElevatedButton(
                onPressed: () async {
                  try {
                    await appState
                        .loadProfile();
                  } catch (error) {
                    if (!mounted) {
                      return;
                    }

                    ScaffoldMessenger
                            .of(context)
                        .showSnackBar(
                      SnackBar(
                        content: Text(
                          error
                              .toString()
                              .replaceFirst(
                                'Exception: ',
                                '',
                              ),
                        ),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Try Again',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Edit Profile',
            onPressed: () {
              _editProfile(
                profile,
              );
            },
            icon: const Icon(
              Icons.edit_outlined,
            ),
          ),

          IconButton(
            tooltip: 'Log Out',
            onPressed: _logout,
            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 650,
            ),
            child: Column(
              children: [
                const SizedBox(
                  height: 12,
                ),

                CircleAvatar(
                  radius: 54,
                  backgroundColor:
                      Colors.red,
                  child: Text(
                    getInitial(
                      profile.name,
                    ),
                    style:
                        const TextStyle(
                      fontSize: 40,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          Colors.white,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 18,
                ),

                Text(
                  profile.name,
                  textAlign:
                      TextAlign.center,
                  style:
                      const TextStyle(
                    fontSize: 28,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Text(
                  profile.goal,
                  textAlign:
                      TextAlign.center,
                  style:
                      const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(
                  height: 30,
                ),

                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        icon:
                            Icons.height,
                        title:
                            'Height',
                        value:
                            '${formatNumber(profile.height)} cm',
                      ),
                    ),

                    const SizedBox(
                      width: 16,
                    ),

                    Expanded(
                      child: _statCard(
                        icon: Icons
                            .monitor_weight_outlined,
                        title:
                            'Weight',
                        value:
                            '${formatNumber(profile.weight)} kg',
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 16,
                ),

                _infoCard(
                  icon: Icons
                      .flag_outlined,
                  title:
                      'Training Goal',
                  value:
                      profile.goal,
                ),

                const SizedBox(
                  height: 16,
                ),

                _infoCard(
                  icon: Icons
                      .calendar_month_outlined,
                  title:
                      'Member Since',
                  value:
                      formatMemberSince(
                    profile.memberSince,
                  ),
                ),

                const SizedBox(
                  height: 28,
                ),

                SizedBox(
                  width:
                      double.infinity,
                  height: 52,
                  child:
                      ElevatedButton.icon(
                    onPressed: () {
                      _editProfile(
                        profile,
                      );
                    },
                    icon: const Icon(
                      Icons
                          .edit_outlined,
                    ),
                    label:
                        const Text(
                      'Edit Profile',
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
                  height: 12,
                ),

                SizedBox(
                  width:
                      double.infinity,
                  height: 52,
                  child:
                      OutlinedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(
                      Icons.logout,
                    ),
                    label:
                        const Text(
                      'Log Out',
                      style:
                          TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: Colors.red,
            ),

            const SizedBox(
              height: 10,
            ),

            Text(
              value,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 5,
            ),

            Text(
              title,
              style:
                  const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              icon,
              size: 28,
              color: Colors.red,
            ),

            const SizedBox(
              width: 18,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    title,
                    style:
                        const TextStyle(
                      color:
                          Colors.grey,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    value,
                    style:
                        const TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.w600,
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