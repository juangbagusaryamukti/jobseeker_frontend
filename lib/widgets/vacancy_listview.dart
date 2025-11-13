import 'package:flutter/material.dart';
import 'package:jobseeker_app/models/hrd_model.dart';
import 'package:jobseeker_app/models/vacancy_model.dart';
import 'package:jobseeker_app/views/hrd_view/hrd_vacancy_detail.dart';
import 'package:jobseeker_app/widgets/colors.dart';

class VacancyListView extends StatelessWidget {
  final List<VacancyModel> vacancies;
  final HrdModel? hrd;
  final String? status;

  const VacancyListView({
    super.key,
    required this.vacancies,
    required this.hrd,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    // 🔹 Filter berdasarkan status (jika ada)
    final filteredVacancies = (status == null || status == "All")
        ? vacancies
        : vacancies.where((v) => v.status == status).toList();

    if (filteredVacancies.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            'Tidak ada lowongan ${status ?? ''}',
            style: TextStyle(
              fontFamily: "Lato",
              fontSize: 15,
              color: ColorsApp.Grey2,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount: filteredVacancies.length,
      itemBuilder: (context, index) {
        final vacancy = filteredVacancies[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HrdVacancyDetail(
                  vacancy: vacancy,
                  hrd: hrd!,
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.network(hrd!.logo!, width: 40, height: 40),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hrd!.name!,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            fontFamily: "Lato")),
                    const SizedBox(height: 4),
                    Text(vacancy.positionName,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFamily: "Lato")),
                    const SizedBox(height: 4),
                    Text(hrd!.address!,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: ColorsApp.Grey1,
                            fontFamily: "Lato")),
                  ],
                ),
                Text(
                  vacancy.status == 'Active' ? 'Active' : 'Expired',
                  style: TextStyle(
                    fontFamily: "Lato",
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color:
                        vacancy.status == 'Active' ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
