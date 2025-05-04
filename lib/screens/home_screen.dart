import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_constants.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    print('Home Screen initState');
  }
  
  @override
  Widget build(BuildContext context) {
    print('Building Home Screen');
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Prediction'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await authProvider.signOut();
                if (!mounted) return;
                Navigator.of(context).pushReplacementNamed(AppConstants.loginRoute);
              } catch (e) {
                print('Sign out error: $e');
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.nights_stay,
              size: 80,
              color: AppConstants.primaryColor,
            ),
            const SizedBox(height: 24),
            const Text(
              'Sleep Prediction App',
              style: AppConstants.headingStyle,
            ),
            const SizedBox(height: 16),
            Text(
              'Welcome, ${authProvider.userModel?.name ?? 'User'}',
              style: AppConstants.bodyStyle,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed(AppConstants.loginRoute);
              },
              child: const Text('Go Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
} 