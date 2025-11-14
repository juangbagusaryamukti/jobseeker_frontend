import 'package:flutter/material.dart';
import 'package:jobseeker_app/controllers/society_controller.dart';
import 'package:jobseeker_app/models/society_model.dart';
import 'package:jobseeker_app/widgets/colors.dart';
import 'package:jobseeker_app/widgets/customtextfield.dart';

class UpdateSocietyProfileView extends StatefulWidget {
  const UpdateSocietyProfileView({super.key});

  @override
  State<UpdateSocietyProfileView> createState() =>
      _UpdateSocietyProfileViewState();
}

class _UpdateSocietyProfileViewState extends State<UpdateSocietyProfileView> {
  final _formKey = GlobalKey<FormState>();
  final SocietyController _controller = SocietyController();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();

  bool _isLoading = false;
  bool _isFetching = true;
  Society? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  /// 🔹 Ambil data profil Society dari backend
  Future<void> _loadProfileData() async {
    final result =
        await _controller.getProfile(); // asumsi getProfile() sudah ada

    if (result != null) {
      setState(() {
        _profile = result;
        _nameController.text = result.name ?? '';
        _addressController.text = result.address ?? '';
        _phoneController.text = result.phone ?? '';
        _dobController.text = result.dateOfBirth!.split('T').first;
        _genderController.text = result.gender ?? '';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memuat data profil.'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isFetching = false);
  }

  /// 🔹 Simpan perubahan ke backend
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final success = await _controller.updateSocietyData(
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      dateOfBirth: _dobController.text.trim(),
      gender: _genderController.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Profile updated successfully' : 'Failed to update profile',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: success ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    if (success) Navigator.pop(context, true);

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isFetching) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/image/bg_auth.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header logo
                Row(
                  children: [
                    Image.asset("assets/image/Logo.png", height: 30),
                    const SizedBox(width: 5),
                    const Text(
                      "Workscout",
                      style: TextStyle(
                        fontFamily: "Lato",
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                const Text(
                  'Update Profile',
                  style: TextStyle(
                    fontFamily: "Lato",
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 28),

                // 🔹 Form Fields
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _nameController,
                        label: "Full Name",
                        hintText: _profile?.name ?? "Enter your full name",
                        enabled: !_isLoading,
                        validator: (v) =>
                            v!.isEmpty ? "Please enter your name" : null,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _addressController,
                        label: "Address",
                        hintText: _profile?.address ?? "Enter your address",
                        enabled: !_isLoading,
                        validator: (v) =>
                            v!.isEmpty ? "Please enter your address" : null,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _phoneController,
                        label: "Phone",
                        hintText: _profile?.phone ?? "Enter your phone number",
                        keyboardType: TextInputType.phone,
                        enabled: !_isLoading,
                        validator: (v) => v!.isEmpty
                            ? "Please enter your phone number"
                            : null,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _dobController,
                        label: "Date of Birth (YYYY-MM-DD)",
                        hintText: _profile?.dateOfBirth.split('T').first ??
                            "2000-01-01",
                        enabled: !_isLoading,
                        validator: (v) =>
                            v!.isEmpty ? "Please enter your birth date" : null,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _genderController,
                        label: "Gender",
                        hintText: _profile?.gender ?? "Male / Female",
                        enabled: !_isLoading,
                        validator: (v) =>
                            v!.isEmpty ? "Please enter your gender" : null,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 🔹 Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateProfile,
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
                            'Update Profile',
                            style: TextStyle(
                              fontSize: 14,
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
