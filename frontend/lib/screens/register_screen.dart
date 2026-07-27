import 'package:flutter/material.dart';

import '../services/app_state.dart';
import '../services/auth_api.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {
  final _nameController =
      TextEditingController();

  final _emailController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  final _confirmPasswordController =
      TextEditingController();

  final _heightController =
      TextEditingController();

  final _weightController =
      TextEditingController();

  final _goalController =
      TextEditingController();

  bool _loading = false;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _goalController.dispose();

    super.dispose();
  }

  Future<void> _register() async {
    if (_loading) return;

    final name =
        _nameController.text.trim();

    final email =
        _emailController.text.trim();

    final password =
        _passwordController.text;

    final confirmPassword =
        _confirmPasswordController.text;

    final height =
        double.tryParse(
      _heightController.text.trim(),
    );

    final weight =
        double.tryParse(
      _weightController.text.trim(),
    );

    final goal =
        _goalController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        _heightController.text
            .trim()
            .isEmpty ||
        _weightController.text
            .trim()
            .isEmpty ||
        goal.isEmpty) {
      _showMessage(
        'Complete all fields.',
      );

      return;
    }

    if (!email.contains('@') ||
        !email.contains('.')) {
      _showMessage(
        'Enter a valid email address.',
      );

      return;
    }

    if (password.length < 8) {
      _showMessage(
        'Password must be at least 8 characters.',
      );

      return;
    }

    if (password != confirmPassword) {
      _showMessage(
        'Passwords do not match.',
      );

      return;
    }

    if (height == null ||
        height <= 0) {
      _showMessage(
        'Enter a valid height.',
      );

      return;
    }

    if (weight == null ||
        weight <= 0) {
      _showMessage(
        'Enter a valid weight.',
      );

      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final result =
          await AuthApi.register(
        name: name,
        email: email,
        password: password,
        height: height,
        weight: weight,
        goal: goal,
      );

      await AppState.instance.setAuth(
        token: result.token,
        userId: result.userId,
        name: result.name,
        email: result.email,
      );

      await Future.wait([
        AppState.instance.loadProfile(),
        AppState.instance.loadWorkouts(),
      ]);

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const DashboardScreen(),
        ),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;

      final message = error
          .toString()
          .replaceFirst(
            'Exception: ',
            '',
          );

      _showMessage(message);
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Account',
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      body: Center(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 420,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .stretch,
              children: [
                const Icon(
                  Icons.fitness_center,
                  size: 64,
                  color: Colors.red,
                ),

                const SizedBox(
                  height: 18,
                ),

                const Text(
                  'Join ForgeFit',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                const Text(
                  'Create your account and build your training profile.',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(
                  height: 28,
                ),

                TextField(
                  controller:
                      _nameController,
                  textInputAction:
                      TextInputAction.next,
                  autofillHints:
                      const [
                    AutofillHints.name,
                  ],
                  decoration:
                      const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(
                      Icons.person_outline,
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
                      _emailController,
                  keyboardType:
                      TextInputType
                          .emailAddress,
                  textInputAction:
                      TextInputAction.next,
                  autofillHints:
                      const [
                    AutofillHints.email,
                  ],
                  decoration:
                      const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(
                      Icons.email_outlined,
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
                      _passwordController,
                  obscureText:
                      _hidePassword,
                  textInputAction:
                      TextInputAction.next,
                  autofillHints:
                      const [
                    AutofillHints
                        .newPassword,
                  ],
                  decoration:
                      InputDecoration(
                    labelText: 'Password',
                    prefixIcon:
                        const Icon(
                      Icons.lock_outline,
                    ),
                    border:
                        const OutlineInputBorder(),
                    suffixIcon:
                        IconButton(
                      onPressed: () {
                        setState(() {
                          _hidePassword =
                              !_hidePassword;
                        });
                      },
                      icon: Icon(
                        _hidePassword
                            ? Icons
                                .visibility_outlined
                            : Icons
                                .visibility_off_outlined,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                TextField(
                  controller:
                      _confirmPasswordController,
                  obscureText:
                      _hideConfirmPassword,
                  textInputAction:
                      TextInputAction.next,
                  decoration:
                      InputDecoration(
                    labelText:
                        'Confirm Password',
                    prefixIcon:
                        const Icon(
                      Icons.lock_outline,
                    ),
                    border:
                        const OutlineInputBorder(),
                    suffixIcon:
                        IconButton(
                      onPressed: () {
                        setState(() {
                          _hideConfirmPassword =
                              !_hideConfirmPassword;
                        });
                      },
                      icon: Icon(
                        _hideConfirmPassword
                            ? Icons
                                .visibility_outlined
                            : Icons
                                .visibility_off_outlined,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 24,
                ),

                const Text(
                  'Your Profile',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 6,
                ),

                const Text(
                  'You can change these later from your profile.',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                TextField(
                  controller:
                      _heightController,
                  keyboardType:
                      const TextInputType
                          .numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction:
                      TextInputAction.next,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Height (cm)',
                    hintText: '175',
                    prefixIcon: Icon(
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
                      _weightController,
                  keyboardType:
                      const TextInputType
                          .numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction:
                      TextInputAction.next,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Weight (kg)',
                    hintText: '75',
                    prefixIcon: Icon(
                      Icons.monitor_weight_outlined,
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
                      _goalController,
                  textInputAction:
                      TextInputAction.done,
                  onSubmitted: (_) {
                    _register();
                  },
                  maxLines: 2,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Fitness Goal',
                    hintText:
                        'Build strength and muscle',
                    prefixIcon: Icon(
                      Icons.flag_outlined,
                    ),
                    border:
                        OutlineInputBorder(),
                  ),
                ),

                const SizedBox(
                  height: 22,
                ),

                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed:
                        _loading
                            ? null
                            : _register,
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child:
                                CircularProgressIndicator(
                              strokeWidth:
                                  2,
                            ),
                          )
                        : const Text(
                            'Create Account',
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

                TextButton(
                  onPressed:
                      _loading
                          ? null
                          : () {
                              Navigator
                                  .pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          const LoginScreen(),
                                ),
                              );
                            },
                  child: const Text(
                    'Already have an account? Login',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}