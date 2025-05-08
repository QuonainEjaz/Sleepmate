import 'package:flutter/material.dart';
import '../utils/app_constants.dart';

class CustomProfileDrawer extends StatelessWidget {
  const CustomProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.55,
          color: const Color(0xFF262135),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 50),
                // Profile picture and name
                CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Color(0xFF2D2041),
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Youssef\nLabidi',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 32),
                // Menu options
                _DrawerOption(
                  icon: Icons.settings,
                  label: 'Setting',
                  onTap: () {
                    final currentRoute = ModalRoute.of(context)?.settings.name;
                    if (currentRoute != '/settings') {
                      Navigator.of(context).pushNamed('/settings');
                    }
                    Navigator.of(context).maybePop();
                  },
                ),
                _DrawerOption(
                  icon: Icons.calendar_today,
                  label: 'Schedule',
                  onTap: () {
                    final currentRoute = ModalRoute.of(context)?.settings.name;
                    if (currentRoute != AppConstants.scheduleRoute) {
                      Navigator.of(context).pushNamed(AppConstants.scheduleRoute);
                    }
                    Navigator.of(context).maybePop();
                  },
                ),
                _DrawerOption(
                  icon: Icons.description,
                  label: 'Report',
                  onTap: () {
                    final currentRoute = ModalRoute.of(context)?.settings.name;
                    if (currentRoute != '/progress-report') {
                      Navigator.of(context).pushNamed('/progress-report');
                    }
                    Navigator.of(context).maybePop();
                  },
                ),
                _DrawerOption(
                  icon: Icons.notifications_none,
                  label: 'Notification',
                  onTap: () {
                    final currentRoute = ModalRoute.of(context)?.settings.name;
                    if (currentRoute != '/notifications') {
                      Navigator.of(context).pushNamed('/notifications');
                    }
                    Navigator.of(context).maybePop();
                  },
                ),
                const Spacer(),
                // Logout
                _DrawerOption(
                  icon: Icons.logout,
                  label: '   Log out',
                  onTap: () {
                    // Add logout logic
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppConstants.loginRoute,
                      (route) => false,
                    );
                  },
                  isLogout: true,
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLogout;

  const _DrawerOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 28),
      title: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: isLogout ? FontWeight.w500 : FontWeight.normal,
          fontFamily: 'Montaga',
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 0),
      horizontalTitleGap: 16,
    );
  }
} 