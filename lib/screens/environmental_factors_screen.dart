import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_constants.dart';
import '../widgets/custom_bottom_navigation.dart';
import '../widgets/custom_profile_drawer.dart';
import '../services/prediction_service.dart';
import '../models/prediction_model.dart';
import '../widgets/loading_indicator.dart';

class EnvironmentalFactorsScreen extends StatefulWidget {
  final bool onSaveOnly;
  final Map<String, dynamic>? sleepData;
  final Map<String, dynamic>? dietaryData;

  const EnvironmentalFactorsScreen({
    super.key, 
    this.onSaveOnly = false,
    this.sleepData,
    this.dietaryData,
  });

  @override
  State<EnvironmentalFactorsScreen> createState() => _EnvironmentalFactorsScreenState();
}

class _EnvironmentalFactorsScreenState extends State<EnvironmentalFactorsScreen> {
  // Text controllers for inputable fields
  final TextEditingController _lightIntensityController = TextEditingController(text: '450');
  final TextEditingController _temperatureController = TextEditingController(text: '22');
  String _soundExposure = 'Quiet (< 30 dB)';
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
  }
  
  @override
  void dispose() {
    _lightIntensityController.dispose();
    _temperatureController.dispose();
    super.dispose();
  }

  // Helper method to build environmental data object
  Map<String, dynamic> _buildEnvironmentalData() {
    // Get light intensity value from controller
    final lightValue = int.tryParse(_lightIntensityController.text) ?? 450;
    
    // Get temperature value from controller
    final tempValue = int.tryParse(_temperatureController.text) ?? 22;

    // Map sound exposure to numerical value
    int soundValue;
    switch (_soundExposure) {
      case 'Quiet (< 30 dB)':
        soundValue = 25;
        break;
      case 'Moderate (30-60 dB)':
        soundValue = 45;
        break;
      case 'Loud (> 60 dB)':
        soundValue = 70;
        break;
      default:
        soundValue = 45;
    }

    return {
      'lightIntensity': lightValue,
      'temperature': tempValue,
      'noiseLevel': soundValue,
      'humidity': 50, // Default value
      'airQuality': 'Good' // Default value
    };
  }

  Widget _buildInputField(String label, {TextEditingController? controller, IconData? icon, String? suffix}) {
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF31244C), width: 2),
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Row(
            children: [
              // Use TextField for inputable fields when controller is provided
              if (controller != null) ...[              
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            fontFamily: 'Montaga',
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                            isDense: true,
                          ),
                        ),
                      ),
                      if (suffix != null)
                        Text(
                          ' $suffix',
                          style: const TextStyle(
                            fontFamily: 'Montaga',
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              if (icon != null) ...[                
                const SizedBox(width: 10),
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

  // Save environmental data, send to backend ML model, and navigate to PredictionScreen
  Future<void> _saveAndContinue() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final envData = _buildEnvironmentalData();
      
      if (widget.onSaveOnly) {
        // Return data without saving if in onSaveOnly mode
        Navigator.pop(context, envData);
        return;
      }
      
      // If sleepData or dietaryData is null, use empty maps instead of showing an error
      // This allows default values in the form to be used
      final sleepData = widget.sleepData ?? {};
      final dietaryData = widget.dietaryData ?? {};
      
      // Send data to backend ML model for prediction
      final prediction = await Provider.of<PredictionService>(context, listen: false).makePrediction(
        sleepData: sleepData,
        environmentalData: envData,
        dietaryData: dietaryData,
      );
      
      if (mounted) {
        // Navigate to PredictionScreen with prediction results, clearing the stack
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppConstants.predictionRoute,
          (Route<dynamic> route) => false, // This predicate removes all previous routes
          arguments: {
            'sleepData': sleepData,
            'dietaryData': dietaryData,
            'environmentalData': envData,
            'prediction': prediction?.toJson(),
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending data to ML model: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
                    // Light Intensity Input
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Light Intensity',
                          style: TextStyle(
                            fontFamily: 'Montaga',
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                        Container(
                          width: 170,
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF31244C), width: 2),
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 50,
                                child: TextFormField(
                                  controller: _lightIntensityController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(
                                    fontFamily: 'Montaga',
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                                    isDense: true,
                                  ),
                                ),
                              ),
                              const Text(
                                ' lux',
                                style: TextStyle(
                                  fontFamily: 'Montaga',
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.wb_sunny_outlined,
                                size: 22,
                                color: Colors.grey.shade600,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Temperature Input
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Temperature',
                          style: TextStyle(
                            fontFamily: 'Montaga',
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                        Container(
                          width: 170,
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF31244C), width: 2),
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 50,
                                child: TextFormField(
                                  controller: _temperatureController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(
                                    fontFamily: 'Montaga',
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                                    isDense: true,
                                  ),
                                ),
                              ),
                              const Text(
                                ' °C',
                                style: TextStyle(
                                  fontFamily: 'Montaga',
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.90,
                padding: const EdgeInsets.only(top: 16, left: 24, right: 24),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveAndContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF65558F),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading 
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.0,
                        ),
                      )
                    : const Text(
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