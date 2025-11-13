import 'package:flutter/material.dart';
import 'package:jobseeker_app/controllers/society_controller.dart';
import 'package:jobseeker_app/models/society_model.dart';
import 'package:jobseeker_app/widgets/colors.dart';
import 'package:jobseeker_app/widgets/customtextfield.dart';
import 'package:jobseeker_app/widgets/society_bottom_nav.dart';
import 'package:jobseeker_app/widgets/society_dashboard_listview.dart';
import 'package:jobseeker_app/widgets/society_listview_dasboard.dart';

class SocietyDashboard extends StatefulWidget {
  const SocietyDashboard({super.key});

  @override
  State<SocietyDashboard> createState() => _SocietyDashboardState();
}

class _SocietyDashboardState extends State<SocietyDashboard> {
  final TextEditingController _searchcontroller = TextEditingController();
  final SocietyController _societyController = SocietyController();

  bool _isLoading = true;
  Society? _profile;
  String? _photoUrl;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      final profile = await _societyController.getProfile();
      final photoUrl = await _societyController.getProfilePhoto();

      setState(() {
        _profile = profile;
        _photoUrl = photoUrl;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = '❌ Gagal memuat data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsApp.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(child: Text(errorMessage!))
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        vertical: 24, horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ========================
                        // 👤 USER PROFILE SECTION
                        // ========================
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: _photoUrl != null &&
                                      _photoUrl!.isNotEmpty
                                  ? NetworkImage(_photoUrl!)
                                  : const AssetImage(
                                          "assets/images/default_profile.png")
                                      as ImageProvider,
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _profile?.name ?? "Unknown User",
                                  style: const TextStyle(
                                    fontFamily: "Lato",
                                    color: ColorsApp.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  "Society",
                                  style: TextStyle(
                                    fontFamily: "Lato",
                                    color: ColorsApp.primarydark,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // ========================
                        // 🔍 SEARCH BAR
                        // ========================
                        CustomTextField(
                          readOnly: true,
                          ontap: () {
                            Navigator.pushNamed(
                              context,
                              '/society_search',
                              arguments: {"fromdashboard": true},
                            );
                          },
                          controller: _searchcontroller,
                          hintText: "Search",
                          suffixIcon: Image.asset(
                            "assets/navbar/Search_on.png",
                            width: 20,
                            height: 20,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ========================
                        // 💼 Curated Jobs Section
                        // ========================
                        const Text(
                          "Curated Jobs For You",
                          style: TextStyle(
                            fontFamily: "Lato",
                            color: ColorsApp.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          height: 200,
                          margin: const EdgeInsets.symmetric(vertical: 24),
                          child: const SocietyDashboardListView(),
                        ),

                        // ========================
                        // ⭐ Recommendation Section
                        // ========================
                        const Text(
                          "Recommendation",
                          style: TextStyle(
                            fontFamily: "Lato",
                            color: ColorsApp.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const SocietyListViewDashboard(
                          limitItems: true,
                          maxLength: 5,
                        ),
                      ],
                    ),
                  ),
      ),
      bottomNavigationBar: SocietyBottomNav(0),
    );
  }
}
