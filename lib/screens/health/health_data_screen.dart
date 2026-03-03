import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

class HealthDataScreen extends StatefulWidget {
  const HealthDataScreen({super.key});

  @override
  State<HealthDataScreen> createState() => _HealthDataScreenState();
}

class _HealthDataScreenState extends State<HealthDataScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form Controllers
  final _heartRateController = TextEditingController();
  final _weightController = TextEditingController();
  final _bpSystolicController = TextEditingController();
  final _bpDiastolicController = TextEditingController();
  final _glucoseController = TextEditingController();
  final _oxygenController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTodayData();
  }

  @override
  void dispose() {
    _heartRateController.dispose();
    _weightController.dispose();
    _bpSystolicController.dispose();
    _bpDiastolicController.dispose();
    _glucoseController.dispose();
    _oxygenController.dispose();
    super.dispose();
  }

  Future<void> _loadTodayData() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    try {
      final firestoreService = FirestoreService();
      // We read once rather than stream since this is a data entry form
      final metricStream = firestoreService.streamTodayMetrics(user.uid);
      final todayMetrics = await metricStream.first;
      
      if (mounted) {
        setState(() {
          if (todayMetrics.heartRate > 0) _heartRateController.text = todayMetrics.heartRate.toString();
          if (todayMetrics.weight > 0) _weightController.text = todayMetrics.weight.toString();
          if (todayMetrics.bloodPressureSystolic > 0) _bpSystolicController.text = todayMetrics.bloodPressureSystolic.toString();
          if (todayMetrics.bloodPressureDiastolic > 0) _bpDiastolicController.text = todayMetrics.bloodPressureDiastolic.toString();
          if (todayMetrics.bloodGlucose > 0) _glucoseController.text = todayMetrics.bloodGlucose.toString();
          if (todayMetrics.oxygenSaturation > 0) _oxygenController.text = todayMetrics.oxygenSaturation.toString();
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Failed to load current data";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    try {
      final int? hr = int.tryParse(_heartRateController.text);
      final double? weight = double.tryParse(_weightController.text);
      final int? sys = int.tryParse(_bpSystolicController.text);
      final int? dia = int.tryParse(_bpDiastolicController.text);
      final double? glucose = double.tryParse(_glucoseController.text);
      final double? o2 = double.tryParse(_oxygenController.text);

      await FirestoreService().updateMetric(
        userId: user.uid,
        heartRate: hr,
        weight: weight,
        bloodPressureSystolic: sys,
        bloodPressureDiastolic: dia,
        bloodGlucose: glucose,
        oxygenSaturation: o2,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Health data saved successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, {String? suffix, bool isDouble = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: isDouble),
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: AppColors.surface,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return null; // Optional fields
          if (isDouble) {
            if (double.tryParse(value) == null) return 'Enter a valid number';
          } else {
            if (int.tryParse(value) == null) return 'Enter a valid whole number';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Log Health Data'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.withAlpha(25), // ~0.1 opacity
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                      
                    const Text(
                      'Daily Vitals',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    
                    _buildTextField('Heart Rate', _heartRateController, suffix: 'bpm'),
                    _buildTextField('Weight', _weightController, suffix: 'kg', isDouble: true),
                    
                    // Blood Pressure Row
                    Row(
                      children: [
                        Expanded(child: _buildTextField('BP Systolic', _bpSystolicController, suffix: 'mmHg')),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTextField('BP Diastolic', _bpDiastolicController, suffix: 'mmHg')),
                      ],
                    ),
                    
                    _buildTextField('Blood Glucose', _glucoseController, suffix: 'mg/dL', isDouble: true),
                    _buildTextField('Oxygen Saturation', _oxygenController, suffix: '%', isDouble: true),
                    
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20, 
                              width: 20, 
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            )
                          : const Text(
                              'Save Data',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
