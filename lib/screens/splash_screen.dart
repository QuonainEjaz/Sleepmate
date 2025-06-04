import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../utils/app_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Dispatch event to check authentication status
    context.read<AuthBloc>().add(AuthCheckRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushReplacementNamed(context, AppConstants.sleepPatternsRoute);
        } else if (state is AuthUnauthenticated || state is AuthInitial || state is AuthError) {
          // For AuthInitial or AuthError, we also go to WelcomeScreen to allow login/retry
          Navigator.pushReplacementNamed(context, AppConstants.welcomeRoute);
        }
        // AuthLoading state will show the splash screen UI until a definitive state is reached.
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF2A2438), // Dark purple background
          ),
          child: Center(
            child: Image.asset(
              'assets/icons/icon_large.png',
              width: 150,
              height: 150,
            ),
          ),
        ),
      ),
    );
  }
}
