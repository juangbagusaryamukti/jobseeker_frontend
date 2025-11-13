import 'package:flutter/material.dart';
import 'package:jobseeker_app/controllers/hrd_controller.dart';
import 'package:jobseeker_app/models/hrd_model.dart';
import 'package:jobseeker_app/widgets/colors.dart';
import 'package:jobseeker_app/widgets/customtextfield.dart';

class UpdateHrdProfileView extends StatefulWidget {
  const UpdateHrdProfileView({super.key});

  @override
  State<UpdateHrdProfileView> createState() => _UpdateHrdProfileViewState();
}

class _UpdateHrdProfileViewState extends State<UpdateHrdProfileView> {
  final _formKey = GlobalKey<FormState>();
  final HrdController _controller = HrdController();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isLoading = false;
  bool _isFetching = true; // indikator untuk loading awal data

  HrdModel? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  /// 🔹 Ambil data HRD dari backend (berdasarkan token)
  Future<void> _loadProfileData() async {
    final result = await _controller.getProfile();

    if (result != null) {
      setState(() {
        _profile = result;
        _nameController.text = result.name ?? '';
        _addressController.text = result.address ?? '';
        _phoneController.text = result.phone ?? '';
        _descriptionController.text = result.description ?? '';
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

    final result = await _controller.updateProfile(
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result['message'] ?? 'Terjadi kesalahan',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: result['success'] ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    if (result['success']) {
      Navigator.pop(context, true); // kembali ke halaman sebelumnya
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isFetching) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
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
                // Header logo Workscout
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
                  'Update Company Profile',
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
                        hintText: _profile?.name ?? "Enter your company name",
                        enabled: !_isLoading,
                        validator: (v) =>
                            v!.isEmpty ? "Please enter company name" : null,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _addressController,
                        label: "Address",
                        hintText: _profile?.address ?? "Enter your address",
                        enabled: !_isLoading,
                        validator: (v) =>
                            v!.isEmpty ? "Please enter address" : null,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _phoneController,
                        label: "Phone",
                        hintText: _profile?.phone ?? "Enter your phone number",
                        keyboardType: TextInputType.phone,
                        enabled: !_isLoading,
                        validator: (v) =>
                            v!.isEmpty ? "Please enter phone number" : null,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _descriptionController,
                        label: "Description",
                        hintText: _profile?.description ??
                            "Brief description about your company",
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
