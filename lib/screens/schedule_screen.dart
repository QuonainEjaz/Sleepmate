import 'package:flutter/material.dart';
import '../widgets/custom_profile_drawer.dart';
import '../widgets/custom_bottom_navigation.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int selectedDay = 11;
  final List<int> days = List.generate(31, (index) => index + 1);
  final List<Map<String, dynamic>> schedule = [
    {
      'time': 'January, 11, 8am',
      'label': 'Wake Up',
      'color': Color(0xFFFFD6E0),
      'icon': Icons.wb_twighlight,
      'checked': false,
    },
    {
      'time': 'January, 11, 8:30pm',
      'label': 'Break-fast',
      'color': Color(0xFFF7F7C6),
      'icon': Icons.free_breakfast,
      'checked': true,
    },
    {
      'time': 'January, 11, 2:30pm',
      'label': 'Lunch',
      'color': Color(0xFFF7F7C6),
      'icon': Icons.lunch_dining,
      'checked': true,
    },
    {
      'time': 'January, 11, 9:00pm',
      'label': 'Diner',
      'color': Color(0xFFF7F7C6),
      'icon': Icons.restaurant,
      'checked': true,
    },
    {
      'time': 'January, 11, 9:00pm',
      'label': 'Sleep Time',
      'color': Color(0xFFF7F7C6),
      'icon': Icons.nightlight_round,
      'checked': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D2041),
      endDrawer: const CustomProfileDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: const Color(0xFF2D2041),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TODAY IS',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '11,January 2025',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontFamily: 'Montaga',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 2),
                        ),
                        child: Icon(Icons.chevron_left, color: Colors.white24, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(Icons.chevron_right, color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.arrow_back_ios, color: Colors.white54, size: 20),
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                for (var day in ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'])
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        day,
                                        style: const TextStyle(
                                          color: Colors.white54,
                                          fontSize: 13,
                                          fontFamily: 'Montserrat',
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                for (int i = 1; i <= 7; i++)
                                  Expanded(
                                    child: Center(
                                      child: GestureDetector(
                                        onTap: () => setState(() => selectedDay = i),
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: (selectedDay == i)
                                                ? const Color(0xFFFFD6E0)
                                                : Colors.transparent,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1.5,
                                            ),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Center(
                                            child: Text(
                                              i.toString(),
                                              style: TextStyle(
                                                color: (selectedDay == i)
                                                    ? const Color(0xFF2D2041)
                                                    : Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                for (int i = 8; i <= 14; i++)
                                  Expanded(
                                    child: Center(
                                      child: GestureDetector(
                                        onTap: () => setState(() => selectedDay = i),
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: (selectedDay == i)
                                                ? const Color(0xFFFFD6E0)
                                                : Colors.transparent,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1.5,
                                            ),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Center(
                                            child: Text(
                                              i.toString(),
                                              style: TextStyle(
                                                color: (selectedDay == i)
                                                    ? const Color(0xFF2D2041)
                                                    : Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 20),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    const Text(
                      'Your Schedule',
                      style: TextStyle(
                        color: Color(0xFF2D2041),
                        fontSize: 20,
                        fontFamily: 'Montaga',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: schedule.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final item = schedule[index];
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: item['color'],
                                      shape: BoxShape.circle,
                                    ),
                                    child: item['checked']
                                        ? const Icon(Icons.check, size: 12, color: Colors.black54)
                                        : null,
                                  ),
                                  if (index != schedule.length - 1)
                                    Container(
                                      width: 2,
                                      height: 48,
                                      color: const Color(0xFFDED6F3),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: item['color'],
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(item['icon'], color: Colors.black54, size: 24),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['time'],
                                              style: const TextStyle(
                                                color: Colors.black54,
                                                fontSize: 13,
                                                fontFamily: 'Montserrat',
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              item['label'],
                                              style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 18,
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: 1,
        screenColor: Colors.white,
        onTap: (index) {
          // Handle tab changes if needed
        },
      ),
    );
  }
} 