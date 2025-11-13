import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jobseeker_app/services/hrd_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jobseeker_app/models/hrd_model.dart';
import 'package:jobseeker_app/widgets/colors.dart';
import '../../widgets/customtextfield.dart';

class CompleteHrdProfileView extends StatefulWidget {
  const CompleteHrdProfileView({super.key});

  @override
  State<CompleteHrdProfileView> createState() => _CompleteHrdProfileViewState();
}

class _CompleteHrdProfileViewState extends State<CompleteHrdProfileView> {
  final _formKey = GlobalKey<FormState>();
  final HrdService _hrdService = HrdService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isLoading = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  HrdModel? _profile;

  /// ✅ Pilih image dari gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  /// ✅ Submit profile HRD ke backend (dengan default image jika user tidak upload)
  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Gunakan image dari user atau default dari assets
      String base64Logo;
      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        base64Logo = base64Encode(bytes);
      } else {
        final byteData =
            await DefaultAssetBundle.of(context).load('assets/image/house.png');
        base64Logo = base64Encode(byteData.buffer.asUint8List());
      }

      final result = await _hrdService.completeHrdProfile(
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        description: _descriptionController.text.trim(),
        defaultAssetPath: "assets/image/house.png",
      );

      print("✅ Response dari server: $result");

      setState(() => _isLoading = false);

      final snackBar = SnackBar(
        content: Text(
          result['message'] ??
              (result['success']
                  ? 'Profile updated successfully'
                  : 'Failed to update profile'),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: result['success'] ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      if (result['success']) {
        _profile = result['profile'] as HrdModel?;
        Navigator.pushReplacementNamed(context, "/login");
      }
    } catch (e, stackTrace) {
      print("❌ Error submit HRD profile: $e");
      print("📄 StackTrace: $stackTrace");

      setState(() => _isLoading = false);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: ${e.toString()}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider =
        const AssetImage("assets/image/house.png") as ImageProvider;

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
                  'Company Information',
                  style: TextStyle(
                    fontFamily: "Lato",
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 28),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _nameController,
                        label: "Company Name",
                        hintText: "Enter your company name",
                        enabled: !_isLoading,
                        validator: (v) =>
                            v!.isEmpty ? "Please enter institution name" : null,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _addressController,
                        label: "Address",
                        hintText: "Enter your address",
                        enabled: !_isLoading,
                        validator: (v) =>
                            v!.isEmpty ? "Please enter address" : null,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _phoneController,
                        label: "Phone",
                        hintText: "Enter your phone number",
                        keyboardType: TextInputType.phone,
                        enabled: !_isLoading,
                        validator: (v) =>
                            v!.isEmpty ? "Please enter phone number" : null,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _descriptionController,
                        label: "Description",
                        hintText: "Brief description about your company",
                        maxLines: 3,
                        enabled: !_isLoading,
                        validator: (v) =>
                            v!.isEmpty ? "Please enter description" : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitProfile,
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
                            'Submit',
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
