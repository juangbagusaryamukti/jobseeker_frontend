import 'package:flutter/material.dart';
import 'package:jobseeker_app/widgets/colors.dart';
import 'package:jobseeker_app/widgets/customtextfield.dart';
import 'package:jobseeker_app/controllers/vacancy_controller.dart';
import 'package:jobseeker_app/models/vacancy_model.dart';

class HrdCreateVacancyView extends StatefulWidget {
  const HrdCreateVacancyView({super.key});

  @override
  State<HrdCreateVacancyView> createState() => _HrdCreateVacancyViewState();
}

class _HrdCreateVacancyViewState extends State<HrdCreateVacancyView> {
  final VacancyController _controller = VacancyController();

  bool _isLoading = false;

  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _jobDescriptionController =
      TextEditingController();
  final TextEditingController _capacityController = TextEditingController();

  // Controllers untuk tanggal
  final TextEditingController _startDayController = TextEditingController();
  final TextEditingController _startMonthController = TextEditingController();
  final TextEditingController _startYearController = TextEditingController();

  final TextEditingController _endDayController = TextEditingController();
  final TextEditingController _endMonthController = TextEditingController();
  final TextEditingController _endYearController = TextEditingController();

  DateTime? _submissionStartDate;
  DateTime? _submissionEndDate;

  @override
  void initState() {
    super.initState();
    // Set default start date ke waktu saat ini
    final now = DateTime.now();
    _submissionStartDate = now;
    _startDayController.text = now.day.toString().padLeft(2, '0');
    _startMonthController.text = now.month.toString().padLeft(2, '0');
    _startYearController.text = now.year.toString();
  }

  Future<void> _selectEndDate() async {
    if (_isLoading) return; // ⛔ tidak bisa pilih tanggal kalau sedang loading

    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _submissionEndDate = picked;
        _endDayController.text = picked.day.toString().padLeft(2, '0');
        _endMonthController.text = picked.month.toString().padLeft(2, '0');
        _endYearController.text = picked.year.toString();
      });
    }
  }

  Future<void> _createVacancy() async {
    if (_jobTitleController.text.isEmpty ||
        _jobDescriptionController.text.isEmpty ||
        _capacityController.text.isEmpty ||
        _submissionEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all required fields.'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final VacancyModel? result = await _controller.createVacancy(
        positionName: _jobTitleController.text.trim(),
        capacity: int.parse(_capacityController.text.trim()),
        description: _jobDescriptionController.text.trim(),
        startDate: _submissionStartDate ?? DateTime.now(),
        endDate: _submissionEndDate!,
      );

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Vacancy created successfully!'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Tunggu sedikit agar user melihat snackbar-nya
        await Future.delayed(const Duration(milliseconds: 800));

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/hrd_profile');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _controller.errorMessage ??
                  'Failed to create vacancy. Please try again.',
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error creating vacancy: $e'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      print('Error creating vacancy: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildDateBox({
    required String hint,
    required TextEditingController controller,
    required VoidCallback onTap,
    bool hasError = false,
  }) {
    return SizedBox(
      height: 50,
      width: 80,
      child: TextFormField(
        controller: controller,
        textAlign: TextAlign.center,
        readOnly: true,
        enabled: !_isLoading, // ⛔ disable input saat loading
        onTap: onTap,
        style: TextStyle(
          fontSize: 13,
          fontFamily: "Lato",
          fontWeight: FontWeight.w700,
          color: ColorsApp.Grey1,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: ColorsApp.white1,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: hasError ? Colors.red : ColorsApp.Grey3,
            ),
            borderRadius: BorderRadius.circular(11),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: hasError ? Colors.red : ColorsApp.Grey3,
            ),
            borderRadius: BorderRadius.circular(11),
          ),
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 13,
            fontFamily: "Lato",
            fontWeight: FontWeight.w700,
            color: ColorsApp.Grey2,
          ),
        ),
      ),
    );
  }

  Widget _buildDateRow({
    required String label,
    required TextEditingController dayCtrl,
    required TextEditingController monthCtrl,
    required TextEditingController yearCtrl,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontFamily: "Lato",
            fontWeight: FontWeight.w700,
            color: ColorsApp.black,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDateBox(hint: "DD", controller: dayCtrl, onTap: onTap),
            Container(height: 1, width: 8, color: ColorsApp.Grey3),
            _buildDateBox(hint: "MM", controller: monthCtrl, onTap: onTap),
            Container(height: 1, width: 8, color: ColorsApp.Grey3),
            _buildDateBox(hint: "YYYY", controller: yearCtrl, onTap: onTap),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsApp.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: _isLoading
                          ? null
                          : () => Navigator.pushReplacementNamed(
                              context, '/hrd_profile'),
                      child: Icon(Icons.arrow_back,
                          color: ColorsApp.primarydark, size: 20),
                    ),
                    const Text(
                      "Create Vacancies",
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: "Lato",
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(Icons.arrow_back, color: ColorsApp.white, size: 20),
                  ],
                ),
                const SizedBox(height: 42),
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                  // Input fields
                  CustomTextField(
                    controller: _jobTitleController,
                    label: "Job title",
                    hintText: "e.g Software Engineer",
                    enabled: !_isLoading, // ⛔ disable input saat loading
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: _jobDescriptionController,
                    label: "Job description",
                    hintText: "Details Job",
                    maxLines: 4,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: _capacityController,
                    label: "Capacity",
                    hintText: "e.g 10",
                    keyboardType: TextInputType.number,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 24),

                  _buildDateRow(
                    label: "End Submission Date",
                    dayCtrl: _endDayController,
                    monthCtrl: _endMonthController,
                    yearCtrl: _endYearController,
                    onTap: _selectEndDate,
                  ),
                ]),
                const SizedBox(height: 120),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createVacancy,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: ColorsApp.primarydark,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Create Vacancy',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              fontFamily: "Lato",
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
