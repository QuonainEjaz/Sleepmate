import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../utils/app_constants.dart';

class TestFirebaseScreen extends StatefulWidget {
  const TestFirebaseScreen({Key? key}) : super(key: key);

  @override
  State<TestFirebaseScreen> createState() => _TestFirebaseScreenState();
}

class _TestFirebaseScreenState extends State<TestFirebaseScreen> {
  String _status = 'Checking Firebase status...';
  String _detailedInfo = '';
  bool _isLoading = true;
  bool _isAuthEnabled = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkFirebaseStatus();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkFirebaseStatus() async {
    try {
      setState(() {
        _isLoading = true;
        _status = 'Checking Firebase status...';
        _detailedInfo = '';
      });

      // Wait a moment to ensure Firebase is initialized
      await Future.delayed(const Duration(milliseconds: 500));

      // Check if Firebase is initialized
      bool isInitialized = Firebase.apps.isNotEmpty;
      
      if (!isInitialized) {
        _status = 'Firebase not initialized!';
        _detailedInfo = 'Error: Firebase is not initialized yet. This is unexpected since it should be initialized in main.dart.';
        return;
      }

      _status = 'Firebase is properly initialized!';

      // Get Firebase app info first
      try {
        var app = Firebase.app();
        _detailedInfo += 'Firebase App Information:\n';
        _detailedInfo += 'App Name: ${app.name}\n';
        _detailedInfo += 'App Options: \n';
        _detailedInfo += '- API Key: ${app.options.apiKey}\n';
        _detailedInfo += '- Project ID: ${app.options.projectId}\n';
        _detailedInfo += '- Messaging Sender ID: ${app.options.messagingSenderId}\n';
        _detailedInfo += '- App ID: ${app.options.appId}\n\n';
      } catch (e) {
        _detailedInfo += 'Error getting Firebase app info: $e\n\n';
      }

      // Check Firebase Auth
      try {
        var auth = FirebaseAuth.instance;
        _isAuthEnabled = true;
        _detailedInfo += 'Firebase Auth Status:\n';
        _detailedInfo += '- Auth Instance Available: ✅\n';
        _detailedInfo += '- Current User: ${auth.currentUser != null ? 'Logged in' : 'Not logged in'}\n';
        
        if (auth.currentUser != null) {
          _detailedInfo += '\nUser Information:\n';
          _detailedInfo += '- User ID: ${auth.currentUser!.uid}\n';
          _detailedInfo += '- Email: ${auth.currentUser!.email}\n';
          _detailedInfo += '- Email verified: ${auth.currentUser!.emailVerified}\n';
          _detailedInfo += '- Phone: ${auth.currentUser!.phoneNumber ?? 'N/A'}\n';
          _detailedInfo += '- Created: ${auth.currentUser!.metadata.creationTime}\n';
          _detailedInfo += '- Last signed in: ${auth.currentUser!.metadata.lastSignInTime}\n';
        }

      } catch (e) {
        _isAuthEnabled = false;
        _detailedInfo += '\nFirebase Auth Error: $e\n';
      }
      
    } catch (e) {
      _status = 'Firebase test failed';
      _detailedInfo = 'Error: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testSignIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _detailedInfo += '\nAttempting to sign in...\n';
    });

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      
      setState(() {
        _detailedInfo += '✅ Sign in successful!\n';
        _detailedInfo += '- User ID: ${credential.user?.uid}\n';
        _detailedInfo += '- Email: ${credential.user?.email}\n';
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _detailedInfo += '❌ Sign in failed: ${e.message}\n';
        if (e.code == 'invalid-credential') {
          _detailedInfo += 'The supplied credentials are invalid.\n';
        } else if (e.code == 'too-many-requests') {
          _detailedInfo += 'Too many sign-in attempts. Please try again later.\n';
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign in failed: ${e.message}')),
      );
    } catch (e) {
      setState(() {
        _detailedInfo += '❌ Error during sign in: $e\n';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Firebase Initialization Test',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _status.contains('failed') 
                    ? Colors.red.shade100
                    : _status.contains('properly initialized') 
                        ? Colors.green.shade100
                        : Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _isLoading 
                      ? const CircularProgressIndicator()
                      : Icon(
                          _status.contains('failed') 
                              ? Icons.error
                              : _status.contains('properly initialized') 
                                  ? Icons.check_circle
                                  : Icons.info,
                          color: _status.contains('failed') 
                              ? Colors.red
                              : _status.contains('properly initialized') 
                                  ? Colors.green
                                  : Colors.blue,
                        ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _status,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (_isAuthEnabled) ...[
              const Text(
                'Test Authentication',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _testSignIn,
                  child: Text(_isLoading ? 'Testing...' : 'Test Sign In'),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Detailed Information:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (_isAuthEnabled)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, color: Colors.green.shade700, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Auth Enabled',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _detailedInfo,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _checkFirebaseStatus,
                    child: Text(_isLoading ? 'Checking...' : 'Recheck Status'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (FirebaseAuth.instance.currentUser != null) {
                        await FirebaseAuth.instance.signOut();
                        _checkFirebaseStatus();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Sign Out'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppConstants.loginRoute);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Go to Login'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppConstants.registerRoute);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Go to Register'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(AppConstants.splashRoute);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Go to Normal App Flow'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 