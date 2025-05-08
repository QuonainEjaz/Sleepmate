import 'package:flutter/material.dart';
import '../utils/app_constants.dart';
import '../utils/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_bottom_navigation.dart';
import '../widgets/custom_profile_drawer.dart';

class SleepPatternsScreen extends StatefulWidget {
  const SleepPatternsScreen({Key? key}) : super(key: key);

  @override
  State<SleepPatternsScreen> createState() => _SleepPatternsScreenState();
}

class _SleepPatternsScreenState extends State<SleepPatternsScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  TimeOfDay _weekdayBedtime = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay _weekdayWakeup = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _weekendBedtime = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _weekendWakeup = const TimeOfDay(hour: 10, minute: 0);
  int _sleepDuration = 6;
  int _awakenings = 3;
  int _rateSleepQuality = 1;
  int _relaxedBeforeSleep = 1;
  bool _useElectronics = true;
  double _stressLevel = 1.0;

  String _formatTime(TimeOfDay time) {
    String hour = time.hour.toString().padLeft(2, '0');
    String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _selectTime(BuildContext context, String type) async {
    TimeOfDay initialTime;
    switch (type) {
      case 'weekdayBedtime':
        initialTime = _weekdayBedtime;
        break;
      case 'weekdayWakeup':
        initialTime = _weekdayWakeup;
        break;
      case 'weekendBedtime':
        initialTime = _weekendBedtime;
        break;
      case 'weekendWakeup':
        initialTime = _weekendWakeup;
        break;
      default:
        initialTime = TimeOfDay.now();
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      setState(() {
        switch (type) {
          case 'weekdayBedtime':
            _weekdayBedtime = picked;
            break;
          case 'weekdayWakeup':
            _weekdayWakeup = picked;
            break;
          case 'weekendBedtime':
            _weekendBedtime = picked;
            break;
          case 'weekendWakeup':
            _weekendWakeup = picked;
            break;
        }
      });
    }
  }

  Widget _buildTimeSelector(String label, String type) {
    TimeOfDay time;
    switch (type) {
      case 'weekdayBedtime':
        time = _weekdayBedtime;
        break;
      case 'weekdayWakeup':
        time = _weekdayWakeup;
        break;
      case 'weekendBedtime':
        time = _weekendBedtime;
        break;
      case 'weekendWakeup':
        time = _weekendWakeup;
        break;
      default:
        time = TimeOfDay.now();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.montaga(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        InkWell(
          onTap: () => _selectTime(context, type),
          child: Container(
            width: 135,
            height: 35,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF31244C), width: 1),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatTime(time) + (time.period == DayPeriod.am ? ' am' : ' pm'),
                  style: GoogleFonts.montaga(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                Image.asset(
                  'assets/icons/timer.png',
                  width: 22,
                  height: 22,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepper(String label, int value, void Function(int) onChanged, {String? subtitle, int min = 0, int max = 100, bool showIcons = true, String? hintText}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.montaga(
                    fontSize: 16,
                    color: const Color(0xFF31244C),
                  ),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle,
                      style: GoogleFonts.montaga(
                        fontSize: 13,
                        color: const Color(0xFF31244C),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                width: 100,
                height: 46,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF31244C), width: 1),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                padding: const EdgeInsets.only(left: 15, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextField(
                          controller: TextEditingController(text: value.toString()),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montaga(
                          fontSize: 22,
                          color: const Color(0xFF31244C),
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          hintText: hintText,
                          hintStyle: GoogleFonts.montaga(
                            fontSize: 18,
                            color: const Color(0xFF31244C).withOpacity(0.5),
                          ),
                        ),
                        inputFormatters: showIcons ? null : [
                          FilteringTextInputFormatter.digitsOnly,
                          FilteringTextInputFormatter.allow(RegExp(r'^[1-5]?')),
                        ],
                        onSubmitted: (val) {
                          final int? newValue = int.tryParse(val);
                          if (newValue != null && newValue >= min && newValue <= max) {
                            onChanged(newValue);
                          }
                        },
                      ),
                    ),
                    if (showIcons) ...[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Transform.translate(
                            offset: const Offset(0, 6),
                            child: GestureDetector(
                              onTap: () {
                                if (value < max) onChanged(value + 1);
                              },
                              child: Icon(
                                Icons.expand_less,
                                size: 22,
                                color: const Color(0xFF31244C),
                              ),
                            ),
                          ),
                          Transform.translate(
                            offset: const Offset(0, -6),
                            child: GestureDetector(
                              onTap: () {
                                if (value > min) onChanged(value - 1);
                              },
                              child: Icon(
                                Icons.expand_more,
                                size: 22,
                                color: const Color(0xFF31244C),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ]  
                  ],
                ),
              ),
              const SizedBox(width: 30),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              child: Text(
                'Sleep Patterns',
                textAlign: TextAlign.center,
                style: GoogleFonts.montaga(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF3B1F52),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only( left: 24, right: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTimeSelector('Weekday Bedtime', 'weekdayBedtime'),
                    const SizedBox(height: 16),
                    _buildTimeSelector('Weekday Wake-up', 'weekdayWakeup'),
                    const SizedBox(height: 16),
                    _buildTimeSelector('Weekend Bedtime', 'weekendBedtime'),
                    const SizedBox(height: 16),
                    _buildTimeSelector('Weekend wake-up', 'weekendWakeup'),
                    const SizedBox(height: 16),
                    _buildStepper('Average Sleep Duration', _sleepDuration, (val) => setState(() => _sleepDuration = val)),
                    const SizedBox(height: 16),
                    _buildStepper('Awakenings during night', _awakenings, (val) => setState(() => _awakenings = val)),
                    const SizedBox(height: 16),
                    _buildStepper('Rate sleep quality', _rateSleepQuality, (val) => setState(() => _rateSleepQuality = val),
                      subtitle: '(1 for worst and 5 for best)',
                      min: 1,
                      max: 5,
                      showIcons: false,
                      hintText: '1 - 5'),
                    const SizedBox(height: 16),
                    Text(
                      'Use electronic devices before bed?',
                      style: GoogleFonts.montaga(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _useElectronics,
                                onChanged: (value) {
                                  setState(() {
                                    _useElectronics = value ?? false;
                                  });
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Yes',
                              style: GoogleFonts.montaga(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 64),
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: !_useElectronics,
                                onChanged: (value) {
                                  setState(() {
                                    _useElectronics = !(value ?? true);
                                  });
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'No',
                              style: GoogleFonts.montaga(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 90),

                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildStepper(
                      'How relaxed do you feel before sleep?',
                      _relaxedBeforeSleep,
                      (val) => setState(() => _relaxedBeforeSleep = val),
                      subtitle: '(1 for worst and 5 for best)',
                      min: 1,
                      max: 5,
                      showIcons: false,
                      hintText: '1 - 5',
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 24, right: 24),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppConstants.dietaryHabitsRoute);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF65558F),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Next',
                  style: GoogleFonts.montaga(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 18, bottom: 0),
              width: double.infinity,
              height: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 65,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFF5C5470),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 65,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey[350],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 65,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey[350],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigation(
        screenColor: Colors.white,
        currentIndex: 0,
        onTap: (index) {
          // Handle tab changes if needed
        },
      ),
      endDrawer: const CustomProfileDrawer(),
    );
  }
} 