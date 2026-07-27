import 'package:flutter/material.dart';

import '../services/app_state.dart';
import '../services/auth_api.dart';
import 'dashboard_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  bool _loading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _login() async {
    if (_loading) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter your email and password.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final result = await AuthApi.login(
        email: email,
        password: password,
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

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const DashboardScreen(),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      final message = error
          .toString()
          .replaceFirst(
            'Exception: ',
            '',
          );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Login',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 420,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.fitness_center,
                  size: 70,
                  color: Colors.red,
                ),

                const SizedBox(height: 20),

                const Text(
                  'ForgeFit',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Sign in to continue training.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 32),

                TextField(
                  controller: _emailController,
                  keyboardType:
                      TextInputType.emailAddress,
                  textInputAction:
                      TextInputAction.next,
                  autofillHints: const [
                    AutofillHints.email,
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: _passwordController,
                  obscureText: _hidePassword,
                  textInputAction:
                      TextInputAction.done,
                  autofillHints: const [
                    AutofillHints.password,
                  ],
                  onSubmitted: (_) {
                    _login();
                  },
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                    ),
                    border:
                        const OutlineInputBorder(),
                    suffixIcon: IconButton(
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

                const SizedBox(height: 22),

                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed:
                        _loading ? null : _login,
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: _loading
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const RegisterScreen(),
                            ),
                          );
                        },
                  child: const Text(
                    'New to ForgeFit? Create Account',
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