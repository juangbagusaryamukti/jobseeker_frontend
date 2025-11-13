import 'package:flutter/material.dart';
import 'package:jobseeker_app/models/vacancy_model.dart';
import 'package:jobseeker_app/widgets/colors.dart';

class SocietyAppliedStatus extends StatelessWidget {
  final VacancyModel vacancy;
  const SocietyAppliedStatus({super.key, required this.vacancy});

  @override
  Widget build(BuildContext context) {
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
                // 🔹 Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back,
                        color: ColorsApp.primarydark,
                        size: 20,
                      ),
                    ),
                    const Text(
                      "Applied Job details",
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: "Lato",
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 20),
                  ],
                ),
                const SizedBox(height: 24),

                // 🔹 Info Lowongan
                vacancyInfo(vacancy),
                const SizedBox(height: 24),
                const Text(
                  "Track Your Application",
                  style: TextStyle(
                    fontFamily: "Lato",
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: ColorsApp.black,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget vacancyInfo(VacancyModel vacancy) {
    final companylogo = vacancy.companyLogo;
    final companyname = vacancy.companyName ?? "-";
    final position = vacancy.positionName;
    final address = vacancy.companyAddress ?? "-";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: ColorsApp.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🔹 Logo
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: ColorsApp.Grey2,
              borderRadius: BorderRadius.circular(8),
              image: companylogo != null && companylogo.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(companylogo),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: (companylogo == null || companylogo.isEmpty)
                ? const Icon(Icons.apartment, color: Colors.grey)
                : null,
          ),

          const SizedBox(width: 16),

          // 🔹 Text Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  companyname,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    fontFamily: "Lato",
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  position,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: "Lato",
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  address,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: ColorsApp.Grey1,
                    fontFamily: "Lato",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
