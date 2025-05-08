import 'package:flutter/material.dart';
import '../widgets/custom_bottom_navigation.dart';
import '../widgets/custom_profile_drawer.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF262135),
      endDrawer: const CustomProfileDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Profile picture
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 56,
                backgroundColor: const Color(0xFF2D2041),
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 60,
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Youssef Labidi',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w500,
                fontFamily: 'Montaga',
              ),
            ),
            const SizedBox(height: 40),
            // App Settings Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _SettingsTile(
                      title: 'Account Informations',
                      onTap: () {
                        Navigator.of(context).pushNamed('/account-info');
                      },
                    ),
                    const Divider(color: Colors.white24, height: 1),
                    _SettingsTile(
                      title: 'Notifications',
                      onTap: () {
                        Navigator.of(context).pushNamed('/notifications');
                      },
                    ),
                    const Divider(color: Colors.white24, height: 1),
                    _SettingsTile(
                      title: 'Text Size',
                      trailing: Text(
                        'Medium',
                        style: TextStyle(
                          color: Colors.white54,
                          fontFamily: 'Montaga',
                          fontSize: 16,
                        ),
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: 2,
        screenColor: Colors.purple,
        onTap: (index) {
          // Handle tab changes if needed
        },
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.title,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'Montaga',
          fontSize: 18,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.white, size: 24),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
    );
  }
} 