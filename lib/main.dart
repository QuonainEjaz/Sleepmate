import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'utils/app_constants.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/test_firebase_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/sleep_quality_screen.dart';
import 'screens/sleep_duration_screen.dart';
import 'screens/sleep_goals_screen.dart';
import 'screens/dietary_habits_screen.dart';
import 'screens/environmental_factors_screen.dart';
import 'screens/sleep_patterns_screen.dart';
import 'screens/prediction_screen.dart';
import 'screens/prediction_graph_screen.dart';
import 'screens/recommendation_screen.dart';
import 'screens/sleep_quality_feedback_screen.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen1.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/account_information_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/progress_report_screen.dart';
import 'screens/schedule_screen.dart';

// Error widget for Firebase initialization failure
class ErrorScreen extends StatelessWidget {
  final String message;
  const ErrorScreen({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 60),
              SizedBox(height: 16),
              Text('Firebase Initialization Failed',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(message, textAlign: TextAlign.center),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Try to restart the app
                  main();
                },
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> initializeFirebase() async {
  try {
    // Check if Firebase is already initialized
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Firebase initialized successfully.');
    } else {
      // If Firebase is already initialized, get the default app
      var app = Firebase.app();
      print('Firebase already initialized with app: ${app.name}');
    }
  } catch (e) {
    print('Firebase initialization error: $e');
    // If there's a duplicate app error, try to get the existing app
    if (e.toString().contains('duplicate-app')) {
      try {
        var app = Firebase.app();
        print('Recovered from duplicate app error. Using existing app: ${app.name}');
        return;
      } catch (e2) {
        print('Failed to recover from duplicate app error: $e2');
        rethrow;
      }
    }
    rethrow;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await initializeFirebase();
    runApp(const MyApp());
  } catch (e) {
    print('Fatal error during app initialization: $e');
    runApp(ErrorScreen(message: e.toString()));
  }
}

// Route for testing Firebase - defined here to avoid adding to app_constants.dart
const String testFirebaseRoute = '/test-firebase';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Add other providers as needed
      ],
      child: MaterialApp(
        title: 'Sleep Prediction',
        theme: ThemeData(
          primaryColor: const Color(0xFF2A2438),
          scaffoldBackgroundColor: const Color(0xFF2A2438),
          textTheme: GoogleFonts.montserratAlternatesTextTheme(
            Theme.of(context).textTheme,
          ),
          // Apply Montserrat Alternates to all text styles
          useMaterial3: true,
        ),
        initialRoute: AppConstants.splashRoute,
        routes: {
          AppConstants.splashRoute: (context) => const SplashScreen(),
          AppConstants.splashScreen1Route: (context) => const SplashScreen1(),
          AppConstants.welcomeRoute: (context) => const WelcomeScreen(),
          AppConstants.loginRoute: (context) => const LoginScreen(),
          AppConstants.forgotPasswordRoute: (context) => const ForgotPasswordScreen(),
          AppConstants.registerRoute: (context) => const RegisterScreen(),
          AppConstants.onboardingRoute: (context) => const OnboardingScreen(),
          AppConstants.sleepQualityRoute: (context) => const SleepQualityScreen(),
          AppConstants.sleepDurationRoute: (context) => const SleepDurationScreen(),
          AppConstants.sleepGoalsRoute: (context) => const SleepGoalsScreen(),
          AppConstants.dietaryHabitsRoute: (context) => const DietaryHabitsScreen(),
          AppConstants.environmentalFactorsRoute: (context) => const EnvironmentalFactorsScreen(),
          AppConstants.sleepPatternsRoute: (context) => const SleepPatternsScreen(),
          AppConstants.homeRoute: (context) => const HomeScreen(),
          AppConstants.predictionRoute: (context) => const PredictionScreen(),
          AppConstants.predictionGraphRoute: (context) => const PredictionGraphScreen(),
          AppConstants.recommendationRoute: (context) => const RecommendationScreen(),
          AppConstants.sleepQualityFeedbackRoute: (context) => const SleepQualityFeedbackScreen(),
          testFirebaseRoute: (context) => const TestFirebaseScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/account-info': (context) => const AccountInformationScreen(),
          '/notifications': (context) => const NotificationScreen(),
          '/progress-report': (context) => const ProgressReportScreen(),
          AppConstants.scheduleRoute: (context) => const ScheduleScreen(),
          // Add more routes as they are implemented
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
