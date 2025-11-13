import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jobseeker_app/controllers/vacancy_controller.dart';
import 'package:jobseeker_app/views/society_view/society_vacancy_details.dart';
import 'package:jobseeker_app/widgets/colors.dart';

class SocietyDashboardListView extends StatefulWidget {
  const SocietyDashboardListView({super.key});

  @override
  State<SocietyDashboardListView> createState() =>
      _SocietyDashboardListViewState();
}

class _SocietyDashboardListViewState extends State<SocietyDashboardListView> {
  final VacancyController _controller = VacancyController();

  @override
  void initState() {
    super.initState();
    _fetchVacancies();
  }

  Future<void> _fetchVacancies() async {
    await _controller.fetchAllVacancies();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.errorMessage != null) {
      return Center(child: Text("Error: ${_controller.errorMessage}"));
    }

    final vacancies = List.from(_controller.vacancies)..shuffle();

    if (vacancies.isEmpty) {
      return const Center(child: Text("No vacancies available"));
    }

    final int maxLength = 5;
    final visibleJobs = vacancies.length > maxLength
        ? vacancies.sublist(0, maxLength)
        : vacancies;

    return SizedBox(
      height: 230,
      child: ListView.builder(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(right: 16),
        itemCount: visibleJobs.length + (vacancies.length > maxLength ? 1 : 0),
        itemBuilder: (context, index) {
          // == "See More" button ==
          if (index == visibleJobs.length && vacancies.length > maxLength) {
            return GestureDetector(
              onTap: () =>
                  Navigator.pushReplacementNamed(context, "/society_search"),
              child: Container(
                width: 80,
                margin: const EdgeInsets.only(right: 8),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: ColorsApp.primarydark,
                      child: Icon(Icons.arrow_forward_ios,
                          size: 14, color: ColorsApp.white),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "See More",
                      style: TextStyle(
                        fontSize: 11,
                        color: ColorsApp.primarydark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final job = visibleJobs[index];
          final companyname = job.companyName;
          final companyaddress = job.companyAddress;
          final companylogo = job.companyLogo;

          // === Extract data ===
          final String companyName = companyname ?? '-';
          final String companyAddress = companyaddress ?? '-';
          final String? companyLogo = companylogo;
          final String positionName = job.positionName ?? '-';

          // === Parse submission date ===
          final DateTime startDate = job.submissionStartDate;
          final int daysAgo = DateTime.now().difference(startDate).inDays;

          final String updatedDateText = daysAgo < 0
              ? "Starts in ${daysAgo.abs()} days"
              : (daysAgo == 0 ? "Created today" : "Created $daysAgo days ago");

          // === UI Card ===
          return Container(
            width: 220,
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorsApp.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  spreadRadius: 4,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === Company Logo ===
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: ColorsApp.primarydark.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: companyLogo != null && companyLogo.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            companyLogo,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image_not_supported,
                                    color: ColorsApp.primarydark),
                          ),
                        )
                      : const Icon(Icons.work_outline,
                          color: ColorsApp.primarydark),
                ),
                const SizedBox(height: 12),

                // === Company Name ===
                Text(
                  companyName,
                  style: const TextStyle(
                    fontFamily: "Lato",
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // === Position ===
                Text(
                  positionName,
                  style: const TextStyle(
                    fontFamily: "Lato",
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ColorsApp.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // === Address ===
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        companyAddress,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const Spacer(),

                // === Footer: Date + Detail Button ===
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      updatedDateText,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SocietyVacancyDetails(vacancy: job),
                          ),
                        );
                      },
                      child: const Text(
                        "Details",
                        style: TextStyle(
                          fontSize: 11,
                          color: ColorsApp.primarydark,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
