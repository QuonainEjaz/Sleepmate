import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/sleep_data_model.dart';
import '../utils/app_constants.dart';
import '../widgets/custom_button.dart';

class SleepDetailScreen extends StatelessWidget {
  final SleepDataModel sleepData;

  const SleepDetailScreen({
    Key? key,
    required this.sleepData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Details'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSleepSummaryCard(),
              const SizedBox(height: 24),
              const Text(
                'Sleep Metrics',
                style: AppConstants.headingStyle,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _buildSleepDetailsList(),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'View Sleep Prediction',
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    AppConstants.predictionDetailRoute,
                    arguments: sleepData.id,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSleepSummaryCard() {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateFormat.format(sleepData.date),
                  style: AppConstants.subheadingStyle.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildSleepQualityBadge(sleepData.sleepQuality),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.bedtime, color: AppConstants.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Bedtime: ${timeFormat.format(sleepData.bedTime)}',
                  style: AppConstants.bodyStyle,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.wb_sunny, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'Wake time: ${timeFormat.format(sleepData.wakeTime)}',
                  style: AppConstants.bodyStyle,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.timer, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Total Sleep: ${_formatDuration(sleepData.totalSleepDuration)}',
                  style: AppConstants.bodyStyle.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepQualityBadge(double quality) {
    Color color;
    String text;

    if (quality >= 4) {
      color = Colors.green;
      text = 'Excellent';
    } else if (quality >= 3) {
      color = Colors.lightGreen;
      text = 'Good';
    } else if (quality >= 2) {
      color = Colors.amber;
      text = 'Fair';
    } else {
      color = Colors.red;
      text = 'Poor';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSleepDetailsList() {
    return ListView(
      children: [
        _buildDetailTile(
          icon: Icons.nightlight_round,
          title: 'Sleep Quality',
          value: '${sleepData.sleepQuality.toStringAsFixed(1)}/5',
          iconColor: Colors.indigo,
        ),
        _buildDetailTile(
          icon: Icons.access_time,
          title: 'Sleep Latency',
          value: '${sleepData.sleepLatency} minutes',
          subtitle: 'Time to fall asleep',
          iconColor: Colors.purple,
        ),
        _buildDetailTile(
          icon: Icons.remove_circle_outline,
          title: 'Wake Episodes',
          value: '${sleepData.wakeEpisodes} times',
          subtitle: 'Number of times woken up',
          iconColor: Colors.red,
        ),
        _buildDetailTile(
          icon: Icons.self_improvement,
          title: 'Deep Sleep',
          value: '${sleepData.deepSleepPercentage.toStringAsFixed(1)}%',
          subtitle: '${_formatDuration(Duration(minutes: sleepData.deepSleepMinutes))}',
          iconColor: Colors.blue[800],
        ),
        _buildDetailTile(
          icon: Icons.remove_red_eye_outlined,
          title: 'REM Sleep',
          value: '${sleepData.remSleepPercentage.toStringAsFixed(1)}%',
          subtitle: '${_formatDuration(Duration(minutes: sleepData.remSleepMinutes))}',
          iconColor: Colors.teal,
        ),
        _buildDetailTile(
          icon: Icons.star_border,
          title: 'Light Sleep',
          value: '${sleepData.lightSleepPercentage.toStringAsFixed(1)}%',
          subtitle: '${_formatDuration(Duration(minutes: sleepData.lightSleepMinutes))}',
          iconColor: Colors.cyan,
        ),
        _buildDetailTile(
          icon: Icons.local_drink,
          title: 'Caffeine Intake',
          value: '${sleepData.caffeineIntake} mg',
          subtitle: sleepData.caffeineIntake > 200 ? 'High intake' : 'Moderate intake',
          iconColor: Colors.brown,
        ),
        _buildDetailTile(
          icon: Icons.directions_run,
          title: 'Exercise Duration',
          value: '${sleepData.exerciseDuration} minutes',
          iconColor: Colors.green,
        ),
        _buildDetailTile(
          icon: Icons.smartphone,
          title: 'Screen Time Before Bed',
          value: '${sleepData.screenTimeBeforeBed} minutes',
          iconColor: Colors.blueGrey,
        ),
        _buildDetailTile(
          icon: Icons.mood,
          title: 'Stress Level',
          value: '${sleepData.stressLevel.toStringAsFixed(1)}/5',
          iconColor: Colors.orange,
        ),
        if (sleepData.notes.isNotEmpty)
          _buildNotesTile(
            notes: sleepData.notes,
          ),
      ],
    );
  }

  Widget _buildDetailTile({
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
    required Color iconColor,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.2),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: AppConstants.bodyStyle),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: Text(
          value,
          style: AppConstants.subheadingStyle.copyWith(
            fontWeight: FontWeight.w500,
            color: AppConstants.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildNotesTile({required String notes}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.note, color: Colors.grey),
                const SizedBox(width: 8),
                Text('Notes', style: AppConstants.bodyStyle.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              notes,
              style: AppConstants.bodyStyle,
            ),
          ],
        ),
      ),
    );
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