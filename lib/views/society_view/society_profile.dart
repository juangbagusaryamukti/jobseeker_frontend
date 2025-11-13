import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jobseeker_app/controllers/auth_controller.dart';
import 'package:jobseeker_app/controllers/portofolio_controller.dart';
import 'package:jobseeker_app/controllers/skill_controller.dart';
import 'package:jobseeker_app/controllers/society_controller.dart';
import 'package:jobseeker_app/models/society_model.dart';
import 'package:jobseeker_app/utils/file_util.dart';
import 'package:jobseeker_app/views/society_view/society_update.dart';
import 'package:jobseeker_app/widgets/add_skill_bottomsheet.dart';
import 'package:jobseeker_app/widgets/colors.dart';
import 'package:jobseeker_app/widgets/customtextfield.dart';
import 'package:jobseeker_app/widgets/society_bottom_nav.dart';
import 'package:jobseeker_app/widgets/upload_cv_bottomsheet.dart';
import 'package:open_filex/open_filex.dart';

class SocietyProfile extends StatefulWidget {
  const SocietyProfile({super.key});

  @override
  State<SocietyProfile> createState() => _SocietyProfileState();
}

class _SocietyProfileState extends State<SocietyProfile> {
  final SocietyController _societyController = SocietyController();
  final PortfolioController _portfolioController = PortfolioController();
  final TextEditingController _descriptionController = TextEditingController();
  final AuthController _authController = AuthController();

  bool _isLoading = false;
  Society? societyProfile;
  File? _pickedImageFile;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _initProfile();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  /// 🔹 Ambil data profil + portfolio
  Future<void> _initProfile() async {
    setState(() => _isLoading = true);

    final profile = await _societyController.getProfile();
    final photoUrl = await _societyController.getProfilePhoto();
    await _portfolioController.loadPortfolio();

    setState(() {
      societyProfile = profile;
      _photoUrl = photoUrl ?? societyProfile?.profilePhoto;
      _descriptionController.text = _portfolioController.description;
      _isLoading = false;
    });
  }

  /// 🔹 Update foto profil
  Future<void> _pickAndUpdateProfilePhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() {
      _pickedImageFile = File(picked.path);
      _isLoading = true;
    });

    final result =
        await _societyController.pickAndUpdateProfilePhoto(picked.path);

    setState(() {
      _isLoading = false;
      if (result['success'] == true) {
        final updatedProfile = result['profile'] as Society;
        societyProfile = updatedProfile;
        _photoUrl = updatedProfile.profilePhoto;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Gagal update foto')),
        );
      }
    });
  }

  void _handleLogout() async {
    setState(() => _isLoading = true);
    await _authController.logout(context);
    setState(() => _isLoading = false);
  }

  Future<void> _refreshProfile() async => _initProfile();

  @override
  Widget build(BuildContext context) {
    // Tentukan image profile
    ImageProvider avatarImage;
    if (_pickedImageFile != null) {
      avatarImage = FileImage(_pickedImageFile!);
    } else if (_photoUrl?.isNotEmpty == true) {
      avatarImage = NetworkImage(_photoUrl!);
    } else {
      avatarImage = const AssetImage('assets/image/user.png');
    }

    return Scaffold(
      backgroundColor: ColorsApp.white,
      bottomNavigationBar: SocietyBottomNav(3),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ====================== HEADER ======================
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
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const UpdateSocietyProfileView(),
                          ),
                        );
                        if (result == true) _initProfile();
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

                // ====================== FOTO PROFIL ======================
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: ColorsApp.Grey3,
                      backgroundImage: avatarImage,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: InkWell(
                        onTap: _isLoading ? null : _pickAndUpdateProfilePhoto,
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

                const SizedBox(height: 24),

                // ====================== NAMA & ALAMAT ======================
                Text(
                  societyProfile?.name ?? '',
                  style: TextStyle(
                    color: ColorsApp.black,
                    fontFamily: "Lato",
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  societyProfile?.address ?? '',
                  style: TextStyle(
                    color: ColorsApp.Grey2,
                    fontFamily: "Lato",
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 32),

                // ====================== STATUS ======================
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text("Applied",
                            style: TextStyle(
                                color: ColorsApp.Grey2,
                                fontFamily: "Lato",
                                fontSize: 13)),
                        const Text("0 Jobs",
                            style: TextStyle(
                                color: Colors.black,
                                fontFamily: "Lato",
                                fontSize: 15)),
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
                        Text("Status",
                            style: TextStyle(
                                color: ColorsApp.Grey2,
                                fontFamily: "Lato",
                                fontSize: 13)),
                        const Text("Worked",
                            style: TextStyle(
                                color: Colors.green,
                                fontFamily: "Lato",
                                fontSize: 15)),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // ====================== DESCRIPTION ======================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Description",
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: "Lato",
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _portfolioController.toggleEditDescription();
                        });
                      },
                      child: Icon(
                        _portfolioController.isEditingDescription
                            ? Icons.close
                            : Icons.edit,
                        color: ColorsApp.primarydark,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _portfolioController.isEditingDescription
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextField(
                            controller: _descriptionController,
                            maxLines: 3,
                            label: "",
                            hintText: "Enter your description...",
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  _portfolioController.isSavingDescription
                                      ? null
                                      : () async {
                                          await _portfolioController
                                              .saveDescription(
                                            context,
                                            _descriptionController.text,
                                          );
                                          setState(() {});
                                        },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorsApp.primarydark,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _portfolioController.isSavingDescription
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      "Save",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: "Lato",
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      )
                    : (_portfolioController.description.isEmpty)
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Text(
                              "No description added yet",
                              style: TextStyle(
                                color: Colors.grey,
                                fontFamily: "Lato",
                                fontSize: 13,
                              ),
                            ),
                          )
                        : Text(
                            _portfolioController.description,
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: "Lato",
                              color: ColorsApp.Grey1,
                            ),
                          ),

                const SizedBox(height: 32),

                // ====================== SKILLS ======================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Skills",
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: "Lato",
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    GestureDetector(
                      onTap: _showAddSkillBottomSheet,
                      child: Icon(
                        Icons.edit,
                        color: ColorsApp.primarydark,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _portfolioController.selectedSkills.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          "No skills added yet",
                          style: TextStyle(
                            color: Colors.grey,
                            fontFamily: "Lato",
                            fontSize: 13,
                          ),
                        ),
                      )
                    : Wrap(
                        alignment: WrapAlignment.start,
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            _portfolioController.selectedSkills.map((skill) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: ColorsApp.white1,
                              border: Border.all(color: ColorsApp.Grey3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              skill,
                              style: const TextStyle(
                                color: ColorsApp.Grey1,
                                fontFamily: "Lato",
                                fontSize: 12,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "CV",
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: "Lato",
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(24)),
                          ),
                          builder: (context) {
                            return UploadCvBottomSheet(
                              portfolioController: _portfolioController,
                              onCvUploaded: (path) {
                                setState(() {
                                  _portfolioController.cvFilePath = path;
                                });
                              },
                            );
                          },
                        );
                      },
                      child: Text(
                        "Upload CV",
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
                const SizedBox(height: 16),
                if (_portfolioController.cvFilePath != null &&
                    _portfolioController.cvFilePath!.isNotEmpty)
                  GestureDetector(
                    onTap: () async {
                      try {
                        await openRemotePdf(
                          _portfolioController.cvFilePath!,
                          fileName: Uri.decodeComponent(
                            _portfolioController.cvFilePath!.split('/').last,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("❌ Failed to open CV file")),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 24),
                      decoration: BoxDecoration(
                        border: Border.all(color: ColorsApp.Grey3),
                        borderRadius: BorderRadius.circular(12),
                        color: ColorsApp.primarylight,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/image/pdf.png",
                            width: 32,
                            height: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  // 🔹 Bersihkan "%20" dari nama file
                                  Uri.decodeComponent(
                                    _portfolioController.cvFilePath!
                                        .split('/')
                                        .last,
                                  ),
                                  style: const TextStyle(
                                    fontFamily: "Lato",
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  const Text(
                    "No CV uploaded yet",
                    style: TextStyle(
                      fontFamily: "Lato",
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),

                SizedBox(height: 24),

                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        backgroundColor: ColorsApp.white,
                        foregroundColor: ColorsApp.primarydark,
                        side: const BorderSide(
                          width: 1,
                          color: ColorsApp.primarydark,
                        )),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        barrierDismissible:
                            false, // supaya harus pilih Ya / Tidak
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
                                fontWeight: FontWeight.w400,
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

                      // Jika user menekan "Ya, Keluar", baru eksekusi logout
                      if (confirm == true) {
                        _handleLogout();
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout,
                            size: 20, color: ColorsApp.primarydark),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Log Out",
                          style: TextStyle(
                            color: ColorsApp.primarydark,
                            fontFamily: "Lato",
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddSkillBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return AddSkillBottomSheet(
          portfolioController: _portfolioController,
          onSkillsUpdated: (skills) {
            setState(() {
              _portfolioController.selectedSkills = skills;
            });
          },
        );
      },
    );
  }
}
