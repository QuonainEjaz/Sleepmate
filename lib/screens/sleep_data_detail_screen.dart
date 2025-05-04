import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/sleep_data_model.dart';
import '../services/sleep_data_service.dart';
import '../utils/app_constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_loading_indicator.dart';

class SleepDataDetailScreen extends StatefulWidget {
  final String sleepDataId;
  
  const SleepDataDetailScreen({
    Key? key,
    required this.sleepDataId,
  }) : super(key: key);

  @override
  State<SleepDataDetailScreen> createState() => _SleepDataDetailScreenState();
}

class _SleepDataDetailScreenState extends State<SleepDataDetailScreen> {
  final SleepDataService _sleepDataService = SleepDataService();
  bool _isLoading = true;
  SleepDataModel? _sleepData;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _loadSleepData();
  }
  
  Future<void> _loadSleepData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final sleepData = await _sleepDataService.getSleepDataById(widget.sleepDataId);
      setState(() {
        _sleepData = sleepData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load sleep data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
  
  Future<void> _deleteSleepData() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Sleep Data'),
        content: const Text('Are you sure you want to delete this sleep record? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close dialog
              
              setState(() {
                _isLoading = true;
              });
              
              try {
                await _sleepDataService.deleteSleepData(widget.sleepDataId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sleep data deleted successfully')),
                  );
                  Navigator.of(context).pop(true); // Return true to indicate deletion
                }
              } catch (e) {
                if (mounted) {
                  setState(() {
                    _errorMessage = 'Failed to delete sleep data: ${e.toString()}';
                    _isLoading = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(_errorMessage!)),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  Future<void> _navigateToEdit() async {
    final result = await Navigator.of(context).pushNamed(
      '/edit-sleep-data',
      arguments: _sleepData,
    );
    
    if (result == true) {
      _loadSleepData(); // Refresh the data after editing
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Details'),
        backgroundColor: AppConstants.primaryColor,
        actions: [
          if (!_isLoading && _sleepData != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _navigateToEdit,
            ),
          if (!_isLoading && _sleepData != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteSleepData,
            ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const CustomLoadingIndicator()
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'Try Again',
                          onPressed: _loadSleepData,
                          isFullWidth: false,
                        ),
                      ],
                    ),
                  )
                : _buildSleepDataView(),
      ),
    );
  }

  Widget _buildSleepDataView() {
    final sleepData = _sleepData;
    if (sleepData == null) return const SizedBox.shrink();
    
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date and basic sleep info
          _buildSectionHeader('Date & Time'),
          _buildDateTimeCard(dateFormat, timeFormat, sleepData),
          const SizedBox(height: 24),
          
          // Sleep duration and quality
          _buildSectionHeader('Sleep Summary'),
          _buildSleepSummaryCard(sleepData),
          const SizedBox(height: 24),
          
          // Sleep Stages
          _buildSectionHeader('Sleep Stages'),
          _buildSleepStagesCard(sleepData),
          const SizedBox(height: 24),
          
          // Sleep Factors
          _buildSectionHeader('Sleep Factors'),
          _buildSleepFactorsCard(sleepData),
          const SizedBox(height: 24),
          
          // Notes
          if (sleepData.notes.isNotEmpty) ...[
            _buildSectionHeader('Notes'),
            _buildNotesCard(sleepData),
            const SizedBox(height: 24),
          ],
          
          // Insights
          if (sleepData.sleepEfficiency > 0) ...[
            _buildSectionHeader('Sleep Insights'),
            _buildInsightsCard(sleepData),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: AppConstants.headingStyle.copyWith(fontSize: 18),
      ),
    );
  }

  Widget _buildDateTimeCard(DateFormat dateFormat, DateFormat timeFormat, SleepDataModel sleepData) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: AppConstants.primaryColor),
                const SizedBox(width: 8),
                Text(
                  dateFormat.format(sleepData.date),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bedtime',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.bedtime, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            timeFormat.format(sleepData.bedTime),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Wake Time',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.wake_up, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            timeFormat.format(sleepData.wakeTime),
                            style: const TextStyle(fontSize: 16),
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
    );
  }

  Widget _buildSleepSummaryCard(SleepDataModel sleepData) {
    final hours = sleepData.totalSleepDuration.inHours;
    final minutes = sleepData.totalSleepDuration.inMinutes % 60;
    final durationText = '$hours hr ${minutes.toString().padLeft(2, '0')} min';
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Total Sleep',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        durationText,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: Colors.grey.shade300,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Sleep Quality',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            sleepData.sleepQuality.toString(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            '/10',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 4),
                          _getQualityIcon(sleepData.sleepQuality),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Time to Fall Asleep',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${sleepData.timeToFallAsleep} min',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Awakenings',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        sleepData.numberOfAwakenings.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepStagesCard(SleepDataModel sleepData) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSleepStageItem(
              label: 'Deep Sleep',
              percentage: sleepData.deepSleepPercentage,
              color: Colors.indigo,
            ),
            const SizedBox(height: 16),
            _buildSleepStageItem(
              label: 'Light Sleep',
              percentage: sleepData.lightSleepPercentage,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildSleepStageItem(
              label: 'REM Sleep',
              percentage: sleepData.remSleepPercentage,
              color: Colors.purple,
            ),
            const SizedBox(height: 16),
            _buildSleepStageItem(
              label: 'Awake',
              percentage: sleepData.awakePercentage,
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSleepStageItem({
    required String label,
    required double percentage,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14)),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
        ),
      ],
    );
  }

  Widget _buildSleepFactorsCard(SleepDataModel sleepData) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildFactorItem(
              icon: Icons.mood,
              label: 'Stress Level',
              value: '${sleepData.stressLevel}/10',
            ),
            const Divider(height: 24),
            _buildFactorItem(
              icon: Icons.fitness_center,
              label: 'Physical Activity',
              value: '${sleepData.physicalActivity} min',
            ),
            const Divider(height: 24),
            _buildFactorItem(
              icon: Icons.local_cafe,
              label: 'Caffeine Intake',
              value: '${sleepData.caffeineIntake} mg',
            ),
            const Divider(height: 24),
            _buildFactorItem(
              icon: Icons.wb_sunny,
              label: 'Screen Time Before Bed',
              value: '${sleepData.screenTimeBeforeSleep} min',
            ),
            if (sleepData.alcoholConsumption > 0) ...[
              const Divider(height: 24),
              _buildFactorItem(
                icon: Icons.liquor,
                label: 'Alcohol Consumption',
                value: '${sleepData.alcoholConsumption} drinks',
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildFactorItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppConstants.primaryColor, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildNotesCard(SleepDataModel sleepData) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.note, color: AppConstants.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Notes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              sleepData.notes,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsCard(SleepDataModel sleepData) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights, color: AppConstants.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Sleep Efficiency',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    children: [
                      Center(
                        child: SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            value: sleepData.sleepEfficiency / 100,
                            strokeWidth: 8,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getEfficiencyColor(sleepData.sleepEfficiency),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${sleepData.sleepEfficiency.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Efficiency',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _getSleepEfficiencyMessage(sleepData.sleepEfficiency),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _getQualityIcon(int quality) {
    if (quality >= 8) {
      return Icon(Icons.sentiment_very_satisfied, color: Colors.green);
    } else if (quality >= 6) {
      return Icon(Icons.sentiment_satisfied, color: Colors.amber);
    } else if (quality >= 4) {
      return Icon(Icons.sentiment_neutral, color: Colors.orange);
    } else {
      return Icon(Icons.sentiment_dissatisfied, color: Colors.red);
    }
  }
  
  Color _getEfficiencyColor(double efficiency) {
    if (efficiency >= 90) {
      return Colors.green;
    } else if (efficiency >= 80) {
      return Colors.lightGreen;
    } else if (efficiency >= 70) {
      return Colors.amber;
    } else if (efficiency >= 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
  
  String _getSleepEfficiencyMessage(double efficiency) {
    if (efficiency >= 90) {
      return 'Excellent sleep efficiency! Your sleep was very restful and restorative.';
    } else if (efficiency >= 80) {
      return 'Good sleep efficiency. You had a quality night of rest.';
    } else if (efficiency >= 70) {
      return 'Moderate sleep efficiency. There's room for improving your sleep quality.';
    } else if (efficiency >= 60) {
      return 'Fair sleep efficiency. Consider adjusting your sleep habits for better rest.';
    } else {
      return 'Low sleep efficiency. You may want to discuss your sleep patterns with a healthcare provider.';
    }
  }
} 