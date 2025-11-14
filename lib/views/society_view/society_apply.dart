import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:jobseeker_app/controllers/portofolio_controller.dart';
import 'package:jobseeker_app/controllers/vacancy_controller.dart';
import 'package:jobseeker_app/models/portofolio_model.dart';
import 'package:jobseeker_app/models/vacancy_model.dart';
import 'package:jobseeker_app/utils/file_util.dart';
import 'package:jobseeker_app/widgets/colors.dart';
import 'package:jobseeker_app/widgets/customtextfield.dart';
import 'package:open_filex/open_filex.dart';

class SocietyApply extends StatefulWidget {
  final VacancyModel vacancy;
  const SocietyApply({
    super.key,
    required this.vacancy,
  });

  @override
  State<SocietyApply> createState() => _SocietyApplyState();
}

class _SocietyApplyState extends State<SocietyApply> {
  final PortfolioController _portfolioController = PortfolioController();
  final VacancyController _vacancyController = VacancyController();

  final TextEditingController _coverLetterController = TextEditingController();

  File? _cvFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initProfile();
  }

  Future<void> _initProfile() async {
    setState(() => _isLoading = true);

    await _portfolioController.loadPortfolio();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _submitapply() async {
    setState(() => _isLoading = true);

    try {
      await _vacancyController.applyToPosition(
        widget.vacancy.id,
        _coverLetterController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Apply success"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
      if (mounted) {
        Navigator.pushReplacementNamed(context, "/society_vacancy");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vacancy = widget.vacancy;

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
                      "Apply",
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

                // 🔹 Upload Resume
                const Text(
                  "Upload Your Resume",
                  style: TextStyle(
                    fontFamily: "Lato",
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: ColorsApp.black,
                  ),
                ),
                const SizedBox(height: 12),

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

                const SizedBox(height: 24),
                const Text(
                  "Cover Letter",
                  style: TextStyle(
                    fontFamily: "Lato",
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: ColorsApp.black,
                  ),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _coverLetterController,
                  hintText: "Insert cover letter......",
                  maxLines: 10,
                  enabled: !_isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(vertical: 24, horizontal: 30),
        child: ElevatedButton(
          onPressed: _isLoading == true
              ? null
              : _cvFile != null || _portfolioController.cvFilePath != null
                  ? () {
                      _submitapply();
                    }
                  : null,
          style: _isLoading == false
              ? ElevatedButton.styleFrom(
                  backgroundColor: ColorsApp.primarydark,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                )
              : ElevatedButton.styleFrom(
                  backgroundColor: ColorsApp.Grey2,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
          child: _isLoading == false
              ? const Text(
                  "Apply Now",
                  style: TextStyle(
                    fontFamily: "Lato",
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  "Loading...",
                  style: TextStyle(
                    fontFamily: "Lato",
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  /// 🔹 Widget info perusahaan
  Widget vacancyInfo(VacancyModel vacancy) {
    final companylogo = vacancy.companyLogo;
    final companyname = vacancy.companyName ?? "-";
    final position = vacancy.positionName;
    final address = vacancy.companyAddress ?? "-";
    final status = vacancy.status ?? "Inactive";

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

          Text(
            status == 'Active' ? 'Active' : 'Expired',
            style: TextStyle(
              fontFamily: "Lato",
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: status == 'Active' ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Widget tampilan file PDF
  Widget _buildPdfCard({File? localFile, String? remoteUrl}) {
    final isLocal = localFile != null;
    final fileName =
        isLocal ? localFile.path.split('/').last : remoteUrl!.split('/').last;
    final fileSize = isLocal
        ? "${(localFile.lengthSync() / (1024 * 1024)).toStringAsFixed(2)} Mb"
        : "Server File";

    return GestureDetector(
      onTap: () async {
        if (isLocal) {
          await OpenFilex.open(localFile.path);
        } else {
          // kalau file dari server
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Opening $fileName from server...")),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: ColorsApp.Grey3),
          borderRadius: BorderRadius.circular(12),
          color: ColorsApp.white1,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset("assets/image/pdf.png", width: 30, height: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: const TextStyle(
                      fontFamily: "Lato",
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$fileSize - ${DateTime.now().toString().substring(0, 16)}",
                    style: const TextStyle(
                      fontFamily: "Lato",
                      fontSize: 11,
                      color: ColorsApp.Grey1,
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

  /// 🔹 Fungsi memilih file PDF baru
  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _cvFile = File(result.files.single.path!);
      });
    }
  }
}
