import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:safeguardian_ci_new/presentation/screens/auth/login_screen.dart';
import 'package:safeguardian_ci_new/presentation/screens/onboarding/onboarding_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late Future<bool> _onboardingCompleted;

  @override
  void initState() {
    super.initState();
    _onboardingCompleted = _checkOnboardingStatus();
  }

  Future<bool> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    // ✅ FORCER LA RÉINITIALISATION POUR TESTER
    await prefs.setBool('onboarding_completed', false);

    final completed = prefs.getBool('onboarding_completed') ?? false;
    debugPrint('📱 Onboarding status: $completed');
    return completed;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _onboardingCompleted,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shield_rounded,
                    size: 80,
                    color: Color(0xFF6366F1),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'SafeGuardian',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 40),
                  CircularProgressIndicator(
                    color: Color(0xFF6366F1),
                    strokeWidth: 3,
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data == true) {
          return const LoginScreen();
        }

        return const OnboardingScreen();
      },
    );
  }
}
