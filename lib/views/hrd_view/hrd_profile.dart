import 'dart:io';
import 'package:flutter/material.dart';
import 'package:jobseeker_app/controllers/auth_controller.dart';
import 'package:jobseeker_app/controllers/hrd_controller.dart';
import 'package:jobseeker_app/controllers/vacancy_controller.dart';
import 'package:jobseeker_app/models/hrd_model.dart';
import 'package:jobseeker_app/models/vacancy_model.dart';
import 'package:jobseeker_app/widgets/colors.dart';
import 'package:jobseeker_app/widgets/hrd_bottom_nav.dart';
import 'package:jobseeker_app/widgets/vacancy_listview.dart';

class HrdProfile extends StatefulWidget {
  const HrdProfile({super.key});

  @override
  State<HrdProfile> createState() => _HrdProfileState();
}

class _HrdProfileState extends State<HrdProfile> {
  final HrdController _controller = HrdController();
  final VacancyController _vacancyController = VacancyController();
  final AuthController _authController = AuthController();

  HrdModel? _profile;
  List<VacancyModel> _vacancies = [];
  List<dynamic> _applicants = [];

  File? _pickedImage;
  String? logoUrl;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initProfile();
  }

  /// 🔹 Fungsi utama untuk load semua data profil HRD
  Future<void> _initProfile() async {
    setState(() => _isLoading = true);

    try {
      // Ambil semua data dengan urutan yang benar
      final url = await _controller.loadInitialLogo();
      final profile = await _controller.getProfile();
      await _vacancyController.fetchCompanyVacancies();

      setState(() {
        logoUrl = url;
        _profile = profile;
        _vacancies = _vacancyController.companyVacancies;
        _errorMessage = (profile == null) ? 'Gagal memuat profil HRD' : null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan saat memuat data: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 🔹 Refresh data (tarik ke bawah)
  Future<void> _refreshProfile() async => await _initProfile();

  /// 🔹 Logout
  void _handleLogout() async {
    setState(() => _isLoading = true);
    await _authController.logout(context);
    setState(() => _isLoading = false);
  }

  /// 🔹 Update logo
  Future<void> _pickAndUpdateLogo() async {
    setState(() => _isLoading = true);
    final result = await _controller.pickAndUpdateLogo();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Terjadi kesalahan')),
      );
    }

    if (result['success'] == true) {
      setState(() {
        logoUrl = result['logoUrl'];
        _pickedImage = result['imageFile'];
      });
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsApp.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshProfile,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ================= HEADER =================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 40),
                          const Text(
                            'Profile',
                            style: TextStyle(
                              fontFamily: "Lato",
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final updated = await Navigator.pushNamed(
                                  context, '/hrd_update_profile');
                              if (updated == true) _initProfile();
                            },
                            child: Text(
                              "Edit",
                              style: TextStyle(
                                color: ColorsApp.primarydark,
                                fontFamily: "Lato",
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ================= AVATAR =================
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 55,
                            backgroundColor: ColorsApp.Grey3,
                            backgroundImage: _pickedImage != null
                                ? FileImage(_pickedImage!)
                                : (logoUrl != null &&
                                            logoUrl!.isNotEmpty &&
                                            logoUrl!.startsWith('http')
                                        ? NetworkImage(logoUrl!)
                                        : const AssetImage(
                                            'assets/image/house.png'))
                                    as ImageProvider,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 4,
                            child: InkWell(
                              onTap: _isLoading ? null : _pickAndUpdateLogo,
                              borderRadius: BorderRadius.circular(50),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: ColorsApp.primarydark,
                                  shape: BoxShape.circle,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 15,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // ================= NAMA & ALAMAT =================
                      Text(
                        _profile?.name ?? "",
                        style: TextStyle(
                          color: ColorsApp.black,
                          fontFamily: "Lato",
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _profile?.address ?? "",
                        style: TextStyle(
                          color: ColorsApp.Grey2,
                          fontFamily: "Lato",
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ================= STATUS =================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Text(
                                "Vacancies",
                                style: TextStyle(
                                  color: ColorsApp.Grey2,
                                  fontFamily: "Lato",
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                "${_vacancies.length} Jobs",
                                style: TextStyle(
                                  color: ColorsApp.black,
                                  fontFamily: "Lato",
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            height: 35,
                            width: 1,
                            color: ColorsApp.Grey2,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          Column(
                            children: [
                              Text(
                                "Applicant",
                                style: TextStyle(
                                  color: ColorsApp.Grey2,
                                  fontFamily: "Lato",
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                "${_applicants.length} People",
                                style: TextStyle(
                                  color: ColorsApp.black,
                                  fontFamily: "Lato",
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // ================= VACANCIES =================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "All Vacancies",
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: "Lato",
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.popAndPushNamed(
                                  context, "/hrd_create_vacancy");
                            },
                            child: Icon(
                              Icons.edit,
                              color: ColorsApp.primarydark,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // ================= LIST VACANCIES =================
                      Container(
                        height: MediaQuery.of(context).size.height * 0.4,
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 40),
                        child: VacancyListView(
                          vacancies: _vacancies,
                          hrd: _profile,
                        ),
                      ),

                      // ================= LOGOUT =================
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: ColorsApp.white,
                          foregroundColor: ColorsApp.primarydark,
                          side: const BorderSide(
                            width: 1,
                            color: ColorsApp.primarydark,
                          ),
                        ),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: ColorsApp.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                title: const Text(
                                  'Konfirmasi Logout',
                                  style: TextStyle(
                                    color: ColorsApp.primarydark,
                                    fontFamily: "Lato",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                content: const Text(
                                  'Apakah Anda yakin ingin keluar dari akun ini?',
                                  style: TextStyle(
                                    color: ColorsApp.Grey1,
                                    fontFamily: "Lato",
                                    fontSize: 13,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text(
                                      'Batal',
                                      style: TextStyle(color: ColorsApp.Grey1),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: ColorsApp.primarydark,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text(
                                      'Ya, Keluar',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirm == true) _handleLogout();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.logout,
                                size: 20, color: ColorsApp.primarydark),
                            const SizedBox(width: 10),
                            const Text(
                              "Log Out",
                              style: TextStyle(
                                color: ColorsApp.primarydark,
                                fontFamily: "Lato",
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
      bottomNavigationBar: HrdBottomNav(3),
    );
  }
}
