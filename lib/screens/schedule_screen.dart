import 'package:flutter/material.dart';
import '../widgets/custom_profile_drawer.dart';
import '../widgets/custom_bottom_navigation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime selectedDate = DateTime.now();
  int weekOffset = 0; // 0: days 1-14, 1: days 15-28, 2: days 29-31
  static const int daysPerPage = 14;
  final int totalDays = 31;
  final Map<int, List<Map<String, dynamic>>> scheduleByDay = {
    11: [
      {
        'time': '8:00am',
        'label': 'Wake Up',
        'color': Color(0xFFFFD6E0),
        'icon': Icons.wb_twighlight,
        'checked': false,
      },
      {
        'time': '8:30am',
        'label': 'Break-fast',
        'color': Color(0xFFF7F7C6),
        'icon': Icons.free_breakfast,
        'checked': true,
      },
      {
        'time': '2:30pm',
        'label': 'Lunch',
        'color': Color(0xFFF7F7C6),
        'icon': Icons.lunch_dining,
        'checked': true,
      },
      {
        'time': '9:00pm',
        'label': 'Diner',
        'color': Color(0xFFF7F7C6),
        'icon': Icons.restaurant,
        'checked': true,
      },
      {
        'time': '9:00pm',
        'label': 'Sleep Time',
        'color': Color(0xFFF7F7C6),
        'icon': Icons.nightlight_round,
        'checked': false,
      },
    ],
    12: [
      {
        'time': '8:00am',
        'label': 'Wake Up',
        'color': Color(0xFFFFD6E0),
        'icon': Icons.wb_twighlight,
        'checked': false,
      },
      {
        'time': '8:30am',
        'label': 'Break-fast',
        'color': Color(0xFFF7F7C6),
        'icon': Icons.free_breakfast,
        'checked': false,
      },
    ],
    // Add more days as needed
  };

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));
  }

  void _goToPrevDay() {
    setState(() {
      selectedDate = selectedDate.subtract(const Duration(days: 1));
    });
  }

  void _goToNextDay() {
    setState(() {
      selectedDate = selectedDate.add(const Duration(days: 1));
    });
  }

  @override
  Widget build(BuildContext context) {
    final String day = DateFormat('d').format(selectedDate);
    final String monthYear = DateFormat('MMMM yyyy').format(selectedDate);
    final String todayLabel = 'TODAY IS';
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '$day, $monthYear',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontFamily: 'Montaga',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
                        onPressed: _goToPrevDay,
                        splashRadius: 20,
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: Colors.white, size: 28),
                        onPressed: _goToNextDay,
                        splashRadius: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                                      child: Builder(
                                        builder: (context) {
                                          int day = weekOffset * daysPerPage + i;
                                          if (day > totalDays) return const SizedBox();
                                          return GestureDetector(
                                            onTap: () => setState(() => selectedDate = DateTime(selectedDate.year, selectedDate.month, day)),
                                            child: Container(
                                              width: 32,
                                              height: 32,
                                              margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: (selectedDate.day == day)
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
                                                  day.toString(),
                                                  style: TextStyle(
                                                    color: (selectedDate.day == day)
                                                        ? const Color(0xFF2D2041)
                                                        : Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
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
                                      child: Builder(
                                        builder: (context) {
                                          int day = weekOffset * daysPerPage + i;
                                          if (day > totalDays) return const SizedBox();
                                          return GestureDetector(
                                            onTap: () => setState(() => selectedDate = DateTime(selectedDate.year, selectedDate.month, day)),
                                            child: Container(
                                              width: 32,
                                              height: 32,
                                              margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: (selectedDate.day == day)
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
                                                  day.toString(),
                                                  style: TextStyle(
                                                    color: (selectedDate.day == day)
                                                        ? const Color(0xFF2D2041)
                                                        : Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
                      child: Builder(
                        builder: (context) {
                          final schedule = scheduleByDay[selectedDate.day] ?? [];
                          if (schedule.isEmpty) {
                            return const Center(
                              child: Text(
                                'No events for this day.',
                                style: TextStyle(color: Color(0xFF2D2041), fontSize: 16),
                              ),
                            );
                          }
                          return ListView.separated(
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