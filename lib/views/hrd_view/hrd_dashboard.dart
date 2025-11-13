import 'package:flutter/material.dart';
import 'package:jobseeker_app/controllers/hrd_controller.dart';
import 'package:jobseeker_app/controllers/vacancy_controller.dart';
import 'package:jobseeker_app/models/hrd_model.dart';
import 'package:jobseeker_app/models/vacancy_model.dart';
import 'package:jobseeker_app/widgets/applied_list_view.dart';
import 'package:jobseeker_app/widgets/colors.dart';
import 'package:jobseeker_app/widgets/customtextfield.dart';
import 'package:jobseeker_app/widgets/hrd_bottom_nav.dart';
import 'package:jobseeker_app/widgets/vacancy_listview.dart';

class HrdDashboard extends StatefulWidget {
  const HrdDashboard({super.key});

  @override
  State<HrdDashboard> createState() => _HrdDashboardState();
}

class _HrdDashboardState extends State<HrdDashboard> {
  List<VacancyModel> _vacancies = [];
  HrdModel? _profile;
  final VacancyController _vacancyController = VacancyController();
  final HrdController _controller = HrdController();

  TextEditingController _searchcontroller = TextEditingController();

  bool _isLoading = true;
  bool _isLoadingVacancies = true;
  String _errorMessage = '';
  String? logoUrl;

  Future<void> _loadLogo() async {
    final url = await _controller.loadInitialLogo();
    setState(() => logoUrl = url);
  }

  // LOAD PROFILE
  Future<void> _loadProfile() async {
    final profile = await _controller.getProfile();
    setState(() {
      _isLoading = false;
      if (profile != null) {
        _profile = profile;
      } else {
        _errorMessage = 'Gagal memuat profil HRD';
      }
    });
  }

  Future<void> _loadVacancies() async {
    setState(() => _isLoadingVacancies = true);
    try {
      await _vacancyController.fetchCompanyVacancies(); // fetch dulu
      setState(() {
        _vacancies = _vacancyController
            .companyVacancies; // ambil datanya dari controller
        _isLoadingVacancies = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingVacancies = false;
      });
      print('Error load vacancies: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadLogo();
    _loadProfile();
    _loadVacancies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsApp.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // USER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(logoUrl ?? ""),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _profile?.name ?? "",
                              style: const TextStyle(
                                fontFamily: "Lato",
                                color: ColorsApp.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "HRD",
                              style: const TextStyle(
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
                    IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.notifications_none,
                          color: ColorsApp.primarydark,
                          size: 28,
                        ))
                  ],
                ),
                SizedBox(
                  height: 36,
                ),
                CustomTextField(
                    controller: _searchcontroller,
                    hintText: "Search",
                    suffixIcon: Image.asset("assets/navbar/Search_on.png",
                        width: 20, height: 20)),
                SizedBox(height: 36),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "My Vacancies",
                      style: TextStyle(
                        fontFamily: "Lato",
                        color: ColorsApp.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, "/hrd_vacancy");
                      },
                      child: Text(
                        "See All",
                        style: TextStyle(
                          fontFamily: "Lato",
                          color: ColorsApp.primarydark,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Container(
                  height: 200,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 40),
                  child: VacancyListView(
                    vacancies: _vacancies,
                    hrd: _profile,
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Recent People Applied",
                      style: TextStyle(
                        fontFamily: "Lato",
                        color: ColorsApp.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Container(
                  height: 400,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 40),
                  child: AppliedListView(),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: HrdBottomNav(0),
    );
  }
}
