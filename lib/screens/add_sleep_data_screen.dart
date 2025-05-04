import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/sleep_data_model.dart';
import '../services/sleep_data_service.dart';
import '../utils/app_constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/custom_date_time_field.dart';

class AddSleepDataScreen extends StatefulWidget {
  const AddSleepDataScreen({Key? key}) : super(key: key);

  @override
  State<AddSleepDataScreen> createState() => _AddSleepDataScreenState();
}

class _AddSleepDataScreenState extends State<AddSleepDataScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sleepDataService = SleepDataService();
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _bedTime = TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _wakeTime = TimeOfDay(hour: 6, minute: 0);
  
  final _sleepLatencyController = TextEditingController(text: '15');
  final _wakeEpisodesController = TextEditingController(text: '0');
  
  final _deepSleepController = TextEditingController(text: '90');
  final _remSleepController = TextEditingController(text: '90');
  final _lightSleepController = TextEditingController(text: '180');
  
  final _caffeineController = TextEditingController(text: '0');
  final _exerciseController = TextEditingController(text: '0');
  final _screenTimeController = TextEditingController(text: '0');
  
  double _sleepQuality = 3.0;
  double _stressLevel = 2.0;
  final _notesController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;
  
  @override
  void dispose() {
    _sleepLatencyController.dispose();
    _wakeEpisodesController.dispose();
    _deepSleepController.dispose();
    _remSleepController.dispose();
    _lightSleepController.dispose();
    _caffeineController.dispose();
    _exerciseController.dispose();
    _screenTimeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectBedTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _bedTime,
    );
    if (picked != null && picked != _bedTime) {
      setState(() {
        _bedTime = picked;
      });
    }
  }

  Future<void> _selectWakeTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _wakeTime,
    );
    if (picked != null && picked != _wakeTime) {
      setState(() {
        _wakeTime = picked;
      });
    }
  }

  Duration _calculateTotalSleepDuration() {
    // Create DateTime objects for bedtime and wake time
    final now = DateTime.now();
    final bedDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _bedTime.hour,
      _bedTime.minute,
    );
    
    // If wake time is before bed time, assume it's the next day
    DateTime wakeDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _wakeTime.hour,
      _wakeTime.minute,
    );
    
    if (wakeDateTime.isBefore(bedDateTime)) {
      wakeDateTime = wakeDateTime.add(const Duration(days: 1));
    }
    
    return wakeDateTime.difference(bedDateTime);
  }

  double _calculateTotalSleepPercentages() {
    final deepSleep = int.tryParse(_deepSleepController.text) ?? 0;
    final remSleep = int.tryParse(_remSleepController.text) ?? 0;
    final lightSleep = int.tryParse(_lightSleepController.text) ?? 0;
    
    return deepSleep + remSleep + lightSleep;
  }

  Future<void> _saveSleepData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Convert TimeOfDay to DateTime
      final now = DateTime.now();
      final bedDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _bedTime.hour,
        _bedTime.minute,
      );
      
      // If wake time is before bed time, assume it's the next day
      DateTime wakeDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _wakeTime.hour,
        _wakeTime.minute,
      );
      
      if (wakeDateTime.isBefore(bedDateTime)) {
        wakeDateTime = wakeDateTime.add(const Duration(days: 1));
      }
      
      // Calculate total sleep duration
      final totalSleepDuration = wakeDateTime.difference(bedDateTime);
      
      // Calculate sleep stage percentages
      final deepSleepMinutes = int.tryParse(_deepSleepController.text) ?? 0;
      final remSleepMinutes = int.tryParse(_remSleepController.text) ?? 0;
      final lightSleepMinutes = int.tryParse(_lightSleepController.text) ?? 0;
      
      final totalSleepMinutes = totalSleepDuration.inMinutes;
      final totalTrackedMinutes = deepSleepMinutes + remSleepMinutes + lightSleepMinutes;
      
      double deepSleepPercentage;
      double remSleepPercentage;
      double lightSleepPercentage;
      
      if (totalTrackedMinutes > 0) {
        deepSleepPercentage = (deepSleepMinutes / totalTrackedMinutes) * 100;
        remSleepPercentage = (remSleepMinutes / totalTrackedMinutes) * 100;
        lightSleepPercentage = (lightSleepMinutes / totalTrackedMinutes) * 100;
      } else {
        deepSleepPercentage = 0;
        remSleepPercentage = 0;
        lightSleepPercentage = 0;
      }
      
      final sleepData = SleepDataModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: _selectedDate,
        bedTime: bedDateTime,
        wakeTime: wakeDateTime,
        totalSleepDuration: totalSleepDuration,
        sleepLatency: int.tryParse(_sleepLatencyController.text) ?? 0,
        wakeEpisodes: int.tryParse(_wakeEpisodesController.text) ?? 0,
        deepSleepPercentage: deepSleepPercentage,
        deepSleepMinutes: deepSleepMinutes,
        remSleepPercentage: remSleepPercentage,
        remSleepMinutes: remSleepMinutes,
        lightSleepPercentage: lightSleepPercentage,
        lightSleepMinutes: lightSleepMinutes,
        sleepQuality: _sleepQuality,
        caffeineIntake: int.tryParse(_caffeineController.text) ?? 0,
        exerciseDuration: int.tryParse(_exerciseController.text) ?? 0,
        screenTimeBeforeBed: int.tryParse(_screenTimeController.text) ?? 0,
        stressLevel: _stressLevel,
        notes: _notesController.text,
      );
      
      await _sleepDataService.addSleepData(sleepData);
      
      // Navigate back if successful
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sleep data saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save sleep data: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalSleepDuration = _calculateTotalSleepDuration();
    final sleepMinutes = _calculateTotalSleepPercentages();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Sleep Data'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sleep Information',
                        style: AppConstants.headingStyle,
                      ),
                      const SizedBox(height: 16),
                      
                      // Date and time selection
                      _buildDateSelector(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildBedTimeSelector()),
                          const SizedBox(width: 16),
                          Expanded(child: _buildWakeTimeSelector()),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total Sleep: ${_formatDuration(totalSleepDuration)}',
                        style: AppConstants.subheadingStyle.copyWith(
                          color: AppConstants.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Sleep latency and wake episodes
                      Row(
                        children: [
                          Expanded(
                            child: CustomInputField(
                              label: 'Time to fall asleep (minutes)',
                              controller: _sleepLatencyController,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a value';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomInputField(
                              label: 'Wake episodes',
                              controller: _wakeEpisodesController,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a value';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Sleep stages
                      const Text(
                        'Sleep Stages (minutes)',
                        style: AppConstants.subheadingStyle,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CustomInputField(
                              label: 'Deep Sleep',
                              controller: _deepSleepController,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomInputField(
                              label: 'REM Sleep',
                              controller: _remSleepController,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomInputField(
                              label: 'Light Sleep',
                              controller: _lightSleepController,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (sleepMinutes > 0)
                        Text(
                          'Total tracked minutes: ${sleepMinutes.toInt()}',
                          style: const TextStyle(
                            color: AppConstants.secondaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      const SizedBox(height: 24),
                      
                      // Sleep Quality
                      const Text(
                        'Sleep Quality (1-5)',
                        style: AppConstants.subheadingStyle,
                      ),
                      Slider(
                        value: _sleepQuality,
                        min: 1,
                        max: 5,
                        divisions: 8,
                        label: _sleepQuality.toStringAsFixed(1),
                        onChanged: (value) {
                          setState(() {
                            _sleepQuality = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Factors affecting sleep
                      const Text(
                        'Factors Affecting Sleep',
                        style: AppConstants.headingStyle,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CustomInputField(
                              label: 'Caffeine (mg)',
                              controller: _caffeineController,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomInputField(
                              label: 'Exercise (minutes)',
                              controller: _exerciseController,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomInputField(
                        label: 'Screen time before bed (minutes)',
                        controller: _screenTimeController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a value';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Stress Level
                      const Text(
                        'Stress Level (1-5)',
                        style: AppConstants.subheadingStyle,
                      ),
                      Slider(
                        value: _stressLevel,
                        min: 1,
                        max: 5,
                        divisions: 8,
                        label: _stressLevel.toStringAsFixed(1),
                        activeColor: _getStressColor(_stressLevel),
                        onChanged: (value) {
                          setState(() {
                            _stressLevel = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Notes
                      const Text(
                        'Notes',
                        style: AppConstants.subheadingStyle,
                      ),
                      const SizedBox(height: 8),
                      CustomInputField(
                        label: 'Additional notes',
                        hint: 'Any additional observations or notes...',
                        controller: _notesController,
                        maxLines: 3,
                      ),
                      
                      // Error message
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 24),
                      
                      // Save button
                      CustomButton(
                        text: 'Save Sleep Data',
                        onPressed: _saveSleepData,
                        isFullWidth: true,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return CustomDateTimeField(
      label: 'Date',
      value: DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
      icon: Icons.calendar_today,
      onTap: () => _selectDate(context),
    );
  }

  Widget _buildBedTimeSelector() {
    return CustomDateTimeField(
      label: 'Bed Time',
      value: _bedTime.format(context),
      icon: Icons.bedtime,
      onTap: () => _selectBedTime(context),
    );
  }

  Widget _buildWakeTimeSelector() {
    return CustomDateTimeField(
      label: 'Wake Time',
      value: _wakeTime.format(context),
      icon: Icons.wb_sunny,
      onTap: () => _selectWakeTime(context),
    );
  }

  Color _getStressColor(double level) {
    if (level <= 2) {
      return Colors.green;
    } else if (level <= 3.5) {
      return Colors.amber;
    } else {
      return Colors.red;
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '$hours hr $minutes min';
    } else {
      return '$minutes min';
    }
  }
} 