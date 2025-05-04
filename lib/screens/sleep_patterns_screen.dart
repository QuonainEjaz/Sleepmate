import 'package:flutter/material.dart';
import '../utils/app_constants.dart';
import '../utils/app_theme.dart';

class SleepPatternsScreen extends StatefulWidget {
  const SleepPatternsScreen({Key? key}) : super(key: key);

  @override
  State<SleepPatternsScreen> createState() => _SleepPatternsScreenState();
}

class _SleepPatternsScreenState extends State<SleepPatternsScreen> {
  TimeOfDay _weekdayBedtime = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay _weekdayWakeup = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _weekendBedtime = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _weekendWakeup = const TimeOfDay(hour: 10, minute: 0);
  int _sleepDuration = 6;
  int _awakenings = 3;
  double _sleepQuality = 1.0;
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
          style: AppTheme.modifyStyle(
            AppTheme.bodyMedium,
            color: Colors.black87,
          ),
        ),
        InkWell(
          onTap: () => _selectTime(context, type),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Text(
                  _formatTime(time),
                  style: AppTheme.modifyStyle(
                    AppTheme.bodyMedium,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.modifyStyle(
            AppTheme.bodyMedium,
            color: Colors.black87,
          ),
        ),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              subtitle,
              style: AppTheme.modifyStyle(
                AppTheme.bodySmall,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
            color: Colors.white,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: AppTheme.modifyStyle(
                  AppTheme.bodyMedium,
                  color: Colors.black87,
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                color: Colors.grey.shade600,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: const BoxDecoration(
                color: Color(0xFF2D2041),
              ),
              child: Text(
                'Sleep Patterns',
                style: AppTheme.modifyStyle(
                  AppTheme.titleMedium,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
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
                    _buildDropdown('Average Sleep Duration', '$_sleepDuration'),
                    const SizedBox(height: 16),
                    _buildDropdown('Awakenings during night', '$_awakenings'),
                    const SizedBox(height: 16),
                    _buildDropdown('Rate sleep quality', '1-5',
                        subtitle: '(1 for worst and 5 for best)'),
                    const SizedBox(height: 16),
                    Text(
                      'Use electronic devices before bed?',
                      style: AppTheme.modifyStyle(
                        AppTheme.bodyMedium,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
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
                            const Text(
                              'Yes',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 24),
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
                            const Text(
                              'No',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      'How relaxed do you feel before sleep?',
                      '1-5',
                      subtitle: '(1 for worst and 5 for best)',
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppConstants.dietaryHabitsRoute);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5C5470),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 