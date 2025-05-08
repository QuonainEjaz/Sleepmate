import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_bottom_navigation.dart';
import '../widgets/custom_profile_drawer.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final notifications = [
      _NotificationItem(
        date: 'January, 11, 8:30pm',
        label: 'Break-fast',
        color: const Color(0xFFF7F7C6),
        icon: Icons.free_breakfast,
      ),
      _NotificationItem(
        date: 'January, 11, 2:30pm',
        label: 'Lunch',
        color: const Color(0xFFF7F7C6),
        icon: Icons.lunch_dining,
      ),
      _NotificationItem(
        date: 'January, 11, 8am',
        label: 'Wake Up',
        color: const Color(0xFFFFD6E0),
        icon: Icons.wb_twighlight,
      ),
      _NotificationItem(
        date: 'January, 11, 9:00pm',
        label: 'Diner',
        color: const Color(0xFFF7F7C6),
        icon: Icons.restaurant,
      ),
      _NotificationItem(
        date: 'January, 11, 9:00pm',
        label: 'Sleep Time',
        color: const Color(0xFFF7F7C6),
        icon: Icons.nightlight_round,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF2D2041),
      endDrawer: const CustomProfileDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 60),
              decoration: const BoxDecoration(
                color: Color(0xFF2D2041),
              ),
              child: const Text(
                'Notification',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontFamily: 'Montaga',
                  fontWeight: FontWeight.w400,
                  height: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  color: Colors.white,
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 50),
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 20),
                  itemBuilder: (context, index) => notifications[index],
                  physics: const BouncingScrollPhysics(),
                  clipBehavior: Clip.antiAlias,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: 2,
        screenColor: Colors.white,
        onTap: (index) {
          // Handle tab changes if needed
        },
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final String date;
  final String label;
  final Color color;
  final IconData icon;

  const _NotificationItem({
    required this.date,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontFamily: 'Montserrat Alternates',
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontFamily: 'Montserrat Alternates',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, color: Colors.black54, size: 28),
        ],
      ),
    );
  }
} 