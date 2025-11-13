import 'package:flutter/material.dart';
import 'package:jobseeker_app/controllers/vacancy_controller.dart';
import 'package:jobseeker_app/models/position_applied_model.dart';
import 'package:jobseeker_app/widgets/applied_details_listview.dart';
import 'package:jobseeker_app/widgets/colors.dart';
import 'package:jobseeker_app/widgets/society_bottom_nav.dart';

class SocietyVacancy extends StatefulWidget {
  const SocietyVacancy({
    super.key,
  });

  @override
  State<SocietyVacancy> createState() => _SocietyVacancyState();
}

class _SocietyVacancyState extends State<SocietyVacancy> {
  bool _appliedActive = true;
  bool _chatActive = false;
  int selectedStatus = 0;

  final List<String> statuses = ["All", "Submitted", "Rejected", "Accepted"];

  final VacancyController _controller = VacancyController();

  List<PositionAppliedModel> _applications = [];

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    await _controller.fetchMyApplications();
    setState(() {
      _applications = _controller.myApplication;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsApp.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // --- TAB: Applied / Chat ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildTabButton(
                        title: "Applied Job Details",
                        isActive: _appliedActive,
                        onTap: () {
                          setState(() {
                            _appliedActive = true;
                            _chatActive = false;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: _buildTabButton(
                        title: "Chat",
                        isActive: _chatActive,
                        onTap: () {
                          setState(() {
                            _appliedActive = false;
                            _chatActive = true;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // === KONTEN UTAMA ===
                Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 40),
                  child: _appliedActive
                      ? _controller.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _applications.isEmpty
                              ? const Center(
                                  child:
                                      Text("Belum ada lamaran yang dikirim."),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: List.generate(statuses.length,
                                            (index) {
                                          return statusButton(
                                            statuses[index],
                                            selectedStatus == index,
                                            () {
                                              setState(() {
                                                selectedStatus = index;
                                              });
                                            },
                                          );
                                        }),
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // === LIST LAMARAN ===
                                    Expanded(
                                      child: ListView.builder(
                                        itemCount: _filteredApplications()
                                            .length, // filter by status
                                        itemBuilder: (context, index) {
                                          return AppliedDetailsListview(
                                            applications: _applications,
                                            status: statuses[selectedStatus],
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                )
                      : const Center(child: Text("Chat belum tersedia.")),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SocietyBottomNav(2),
    );
  }

  // 🔹 Filter data sesuai tab status
  List<PositionAppliedModel> _filteredApplications() {
    if (selectedStatus == 0) return _applications; // All
    final selected = statuses[selectedStatus].toUpperCase();
    return _applications
        .where((app) => app.status.toUpperCase() == selected)
        .toList();
  }

  // 🔹 Tab tombol atas
  Widget _buildTabButton({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isActive ? ColorsApp.primarydark : ColorsApp.Grey2,
            width: 2,
          ),
        ),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          overlayColor: Colors.transparent,
          elevation: 0,
          side: BorderSide.none,
          backgroundColor: ColorsApp.white,
        ),
        onPressed: onTap,
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? ColorsApp.primarydark : ColorsApp.Grey2,
            fontFamily: "Lato",
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // 🔹 Tombol status (All, Submitted, Rejected, Accepted)
  Widget statusButton(String text, bool isSelected, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? ColorsApp.primarydark : ColorsApp.white,
        foregroundColor: isSelected ? ColorsApp.white : ColorsApp.primarydark,
        side: BorderSide(
          color: isSelected ? ColorsApp.primarydark : ColorsApp.Grey2,
          width: 1.3,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: "Lato",
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
