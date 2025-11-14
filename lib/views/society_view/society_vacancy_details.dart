import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jobseeker_app/models/vacancy_model.dart';
import 'package:jobseeker_app/views/society_view/society_apply.dart';
import 'package:jobseeker_app/widgets/colors.dart';

class SocietyVacancyDetails extends StatefulWidget {
  final VacancyModel vacancy;

  const SocietyVacancyDetails({super.key, required this.vacancy});

  @override
  State<SocietyVacancyDetails> createState() => _SocietyVacancyDetailsState();
}

class _SocietyVacancyDetailsState extends State<SocietyVacancyDetails> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final vacancy = widget.vacancy;
    final companyname = vacancy.companyName;
    final companyaddress = vacancy.companyAddress;
    final companylogo = vacancy.companyLogo;

    // 🔹 Parsing tanggal & menghitung selisih
    final DateTime startDate = vacancy.submissionStartDate.toLocal();
    final DateTime endDate = vacancy.submissionEndDate.toLocal();
    final int daysAgo = DateTime.now().difference(startDate).inDays;

    final String updatedDateText = daysAgo < 0
        ? "Starts in ${daysAgo.abs()} days"
        : (daysAgo == 0 ? "Created today" : "Created $daysAgo days ago");

    final String startDateFormatted =
        DateFormat("dd MMM yyyy").format(startDate);
    final String endDateFormatted = DateFormat("dd MMM yyyy").format(endDate);

    return Scaffold(
      backgroundColor: ColorsApp.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back,
                          color: ColorsApp.primarydark, size: 20),
                    ),
                    const Text(
                      "Details",
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: "Lato",
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 20), // spacing
                  ],
                ),

                const SizedBox(height: 24),

                // Company Info
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: ColorsApp.Grey2,
                        borderRadius: BorderRadius.circular(10),
                        image: companylogo != null && companylogo.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(companylogo),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: companylogo == null || companylogo.isEmpty
                          ? const Icon(Icons.apartment, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          companyname ?? "",
                          style: const TextStyle(
                            fontFamily: "Lato",
                            color: ColorsApp.black,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          vacancy.positionName,
                          style: const TextStyle(
                            fontFamily: "Lato",
                            color: ColorsApp.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Location
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        color: ColorsApp.primarydark, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      companyaddress ?? "",
                      style: const TextStyle(
                        fontFamily: "Lato",
                        color: ColorsApp.Grey1,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Created ... days ago + status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      updatedDateText,
                      style: const TextStyle(
                        fontFamily: "Lato",
                        color: ColorsApp.Grey1,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      vacancy.status == "Active" ? "Active" : "Inactive",
                      style: TextStyle(
                        fontFamily: "Lato",
                        color: vacancy.status == "Active"
                            ? Colors.green
                            : Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Capacity & Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _infoBox(
                      title: "Capacity",
                      value: vacancy.capacity.toString(),
                      icon: Icons.people_alt_outlined,
                    ),
                    _infoBox(
                      title: "Registration",
                      value: "$startDateFormatted - $endDateFormatted",
                      icon: Icons.calendar_month_outlined,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Job Description
                const Text(
                  "Job Description",
                  style: TextStyle(
                    fontFamily: "Lato",
                    color: ColorsApp.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),

                _description(vacancy.description),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 30),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: ColorsApp.primarydark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SocietyApply(

                  vacancy: vacancy,
                ),
              ),
            );
          },
          child: const Text(
            'Apply',
            style: TextStyle(
              color: ColorsApp.white,
              fontFamily: "Lato",
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widget untuk info box kecil ---
  Widget _infoBox(
      {required String title, required String value, required IconData icon}) {
    return Expanded(
      child: Container(
        height: 80,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ColorsApp.primarydark.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: ColorsApp.primarydark),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: "Lato",
                      color: Colors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: "Lato",
                      color: ColorsApp.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Deskripsi expandable ---
  Widget _description(String text) {
    return SizedBox(
      height: 140,
      child: Stack(
        children: [
          Scrollbar(
            thumbVisibility: true,
            radius: const Radius.circular(10),
            thickness: 3,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    maxLines: isExpanded ? null : 5,
                    overflow:
                        isExpanded ? TextOverflow.visible : TextOverflow.clip,
                    style: const TextStyle(
                      wordSpacing: 2,
                      fontFamily: "Lato",
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => setState(() => isExpanded = !isExpanded),
                    child: Text(
                      isExpanded ? "See less" : "See more..",
                      style: const TextStyle(
                        fontFamily: "Lato",
                        color: ColorsApp.primarydark,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
