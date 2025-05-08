import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_constants.dart';
import '../widgets/custom_bottom_navigation.dart';
import '../widgets/custom_profile_drawer.dart';


class EnvironmentalFactorsScreen extends StatefulWidget {
  const EnvironmentalFactorsScreen({super.key});

  @override
  State<EnvironmentalFactorsScreen> createState() => _EnvironmentalFactorsScreenState();
}

class _EnvironmentalFactorsScreenState extends State<EnvironmentalFactorsScreen> {
  String _lightIntensity = '450 lux';
  String _temperature = '22 °C';
  String _soundExposure = 'Quiet (< 30 dB)';

  Widget _buildInputField(String label, String value, {IconData? icon}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Montaga',
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        Container(
          width: 170,
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF31244C), width: 2),
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Montaga',
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 70),
                Icon(
                  icon,
                  size: 22,
                  color: Colors.grey.shade600,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const CustomProfileDrawer(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: const BoxDecoration(
                color: Color(0xFF2D2041),
              ),
              child: const Text(
                'Environmental Factors',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(left: 30, right: 30, top: 100, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputField('Light Intensity', _lightIntensity, icon: Icons.wb_sunny_outlined),
                    const SizedBox(height: 16),
                    _buildInputField('Temperature', _temperature),
                    const SizedBox(height: 16),
                    const Text(
                      'Sound Exposure',
                      style: TextStyle(
                        fontFamily: 'Montaga',
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 100.0),
                          child: RadioListTile<String>(
                            title: const Text(
                              'Quiet (< 30 dB)',
                              style: TextStyle(
                                fontFamily: 'Montaga',
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            value: 'Quiet (< 30 dB)',
                            groupValue: _soundExposure,
                            onChanged: (value) {
                              setState(() {
                                _soundExposure = value!;
                              });
                            },
                            activeColor: const Color(0xFF2D2041),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 100.0),
                          child: RadioListTile<String>(
                            title: const Text(
                              'Moderate (30-60 dB)',
                              style: TextStyle(
                                fontFamily: 'Montaga',
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            value: 'Moderate (30-60 dB)',
                            groupValue: _soundExposure,
                            onChanged: (value) {
                              setState(() {
                                _soundExposure = value!;
                              });
                            },
                            activeColor: const Color(0xFF2D2041),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 100.0),
                          child: RadioListTile<String>(
                            title: const Text(
                              'Loud (> 60 dB)',
                              style: TextStyle(
                                fontFamily: 'Montaga',
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            value: 'Loud (> 60 dB)',
                            groupValue: _soundExposure,
                            onChanged: (value) {
                              setState(() {
                                _soundExposure = value!;
                              });
                            },
                            activeColor: const Color(0xFF2D2041),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 16, left: 24, right: 24),
              child: ElevatedButton(
                onPressed: () {
                  // Save environmental factors data
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  // Navigate to the prediction screen
                  Navigator.pushReplacementNamed(context, AppConstants.predictionRoute);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF65558F),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'View Prediction',
                  style: TextStyle(
                    fontFamily: 'Montaga',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
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
                  const SizedBox(width: 10),
                  Container(
                    width: 65,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFF5C5470),
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
    );
  }
} 