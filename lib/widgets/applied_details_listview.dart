import 'package:flutter/material.dart';
import 'package:jobseeker_app/models/position_applied_model.dart';
import 'package:jobseeker_app/models/vacancy_model.dart';
import 'package:jobseeker_app/views/society_view/society_applied_status.dart';
import 'package:jobseeker_app/widgets/colors.dart';

class AppliedDetailsListview extends StatelessWidget {
  final List<PositionAppliedModel> applications;
  final String? status;

  const AppliedDetailsListview({
    super.key,
    required this.applications,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    // 🔹 Filter berdasarkan status (kecuali All)
    final filtered = (status == null || status == "All")
        ? applications
        : applications
            .where((a) =>
                a.status.toLowerCase() == status!.toLowerCase() ||
                a.status.toUpperCase() == status!.toUpperCase())
            .toList();

    if (filtered.isEmpty) {
      return const Center(
        child: Text(
          "No Data",
          style: TextStyle(fontFamily: "Lato", color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final app = filtered[index];

        // 🔹 Data aman dari null dengan default kosong
        final company = app.availablePosition?['company']?['name'] ?? '-';
        final position = app.availablePosition?['position_name'] ?? '-';
        final logoUrl = app.availablePosition?['company']?['logo'];
        final statusText = app.status;

        // 🔹 Tentukan warna status
        Color statusColor;
        switch (statusText.toUpperCase()) {
          case "PENDING":
          case "SUBMITTED":
            statusColor = Colors.amber;
            break;
          case "ACCEPTED":
            statusColor = Colors.green;
            break;
          case "REJECTED":
            statusColor = Colors.red;
            break;
          default:
            statusColor = ColorsApp.Grey2;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: ColorsApp.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                spreadRadius: 2,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // 🔹 Logo perusahaan (fallback ke asset)
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: logoUrl != null && logoUrl.isNotEmpty
                            ? NetworkImage(logoUrl) as ImageProvider
                            : const AssetImage('assets/dummy/netflix.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 30),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company,
                        style: const TextStyle(
                          fontFamily: "Lato",
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        position,
                        style: const TextStyle(
                          fontFamily: "Lato",
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                height: 1,
                width: double.infinity,
                color: ColorsApp.Grey2,
                margin: const EdgeInsets.symmetric(vertical: 24),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.circle, size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontFamily: "Lato",
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      final vacancydata =
                          applications[index].availablePosition!;

                      final vacancy = VacancyModel.fromJson(vacancydata);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SocietyAppliedStatus(
                            vacancy: vacancy,
                          ),
                        ),
                      );
                    },
                    child: const Row(
                      children: [
                        Text(
                          "View Details",
                          style: TextStyle(
                            fontFamily: "Lato",
                            fontSize: 12,
                            color: ColorsApp.primarydark,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          color: ColorsApp.primarydark,
                          size: 18,
                        ),
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
