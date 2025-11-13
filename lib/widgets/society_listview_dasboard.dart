import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jobseeker_app/controllers/vacancy_controller.dart';
import 'package:jobseeker_app/models/vacancy_model.dart';
import 'package:jobseeker_app/views/society_view/society_vacancy_details.dart';
import 'package:jobseeker_app/widgets/colors.dart';

class SocietyListViewDashboard extends StatefulWidget {
  final bool limitItems;
  final int maxLength;

  /// Jika [vacancies] diberikan, widget akan menampilkan daftar tersebut.
  /// Jika null, akan fallback ke controller internal.
  final List<VacancyModel>? vacancies;

  const SocietyListViewDashboard({
    super.key,
    this.limitItems = true,
    this.maxLength = 5,
    this.vacancies,
  });

  @override
  State<SocietyListViewDashboard> createState() =>
      _SocietyListViewDashboardState();
}

class _SocietyListViewDashboardState extends State<SocietyListViewDashboard> {
  final VacancyController _controller = VacancyController();

  @override
  void initState() {
    super.initState();
    // Hanya fetch jika widget.vacancies == null (kalo kita memakai controller internal)
    if (widget.vacancies == null) {
      _fetchVacancies();
    }
  }

  Future<void> _fetchVacancies() async {
    await _controller.fetchAllVacancies();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Pilih sumber data: param > controller
    final List<VacancyModel> sourceVacancies =
        widget.vacancies ?? List.from(_controller.vacancies);

    if (widget.vacancies == null && _controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.vacancies == null && _controller.errorMessage != null) {
      return Center(child: Text("Error: ${_controller.errorMessage}"));
    }

    final List<VacancyModel> vacancies = List.from(sourceVacancies)..shuffle();

    if (vacancies.isEmpty) {
      return const Center(child: Text("No vacancies available"));
    }

    final visibleJobs = widget.limitItems && vacancies.length > widget.maxLength
        ? vacancies.sublist(0, widget.maxLength)
        : vacancies;

    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            clipBehavior: Clip.none,
            itemCount: visibleJobs.length,
            itemBuilder: (context, index) {
              final job = visibleJobs[index];

              final String companyName = job.companyName ?? "-";
              final String companyAddress = job.companyAddress ?? "-";
              final String positionName = job.positionName ?? "-";
              final String? companyLogo = job.companyLogo;

              final DateTime startDate = job.submissionStartDate;
              final int daysAgo = DateTime.now().difference(startDate).inDays;

              final String updatedDateText = daysAgo < 0
                  ? "Starts in ${daysAgo.abs()} days"
                  : (daysAgo == 0
                      ? "Created today"
                      : "Created $daysAgo days ago");

              return Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                height: 140,
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
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: ColorsApp.primarydark.withOpacity(0.2),
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
                                  color: ColorsApp.primarydark, size: 22),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                companyName,
                                style: const TextStyle(
                                  fontFamily: "Lato",
                                  fontSize: 11,
                                  color: ColorsApp.black,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                positionName,
                                style: const TextStyle(
                                  fontFamily: "Lato",
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: ColorsApp.black,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                companyAddress,
                                style: const TextStyle(
                                  fontFamily: "Lato",
                                  fontSize: 11,
                                  color: ColorsApp.Grey1,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          updatedDateText,
                          style: const TextStyle(
                            fontSize: 11,
                            color: ColorsApp.Grey1,
                          ),
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
                            "View Details",
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
          if (widget.limitItems && vacancies.length > widget.maxLength)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsApp.white,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      color: ColorsApp.primarydark,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, "/society_search"),
                child: const Text(
                  'See more',
                  style: TextStyle(color: ColorsApp.primarydark),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
