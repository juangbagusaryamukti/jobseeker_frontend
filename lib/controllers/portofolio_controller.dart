import 'package:flutter/material.dart';
import 'package:jobseeker_app/controllers/society_controller.dart';

class PortfolioController with ChangeNotifier {
  final SocietyController _societyController = SocietyController();

  List<String> selectedSkills = [];
  String description = "";
  String? cvFilePath;

  bool isEditingDescription = false;
  bool isSavingDescription = false;
  bool isUploadingCv = false;

  // =========================================================
  // 🔹 AMBIL SEMUA DATA PORTFOLIO
  // =========================================================
  Future<void> loadPortfolio() async {
    try {
      final portfolios = await _societyController.getAllPortfolios();

      if (portfolios.isNotEmpty) {
        final first = portfolios.first;
        selectedSkills = first.skills;
        description = first.description;
        cvFilePath = first.file; // file path/url dari server
      } else {
        selectedSkills = [];
        description = "";
        cvFilePath = null;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loadPortfolio: $e');
    }
  }

  // =========================================================
  // 🔹 SIMPAN / UPDATE DESKRIPSI PORTFOLIO
  // =========================================================
  Future<void> saveDescription(
      BuildContext context, String newDescription) async {
    if (newDescription.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Description cannot be empty")),
      );
      return;
    }

    isSavingDescription = true;
    notifyListeners();

    try {
      final portfolios = await _societyController.getAllPortfolios();

      if (portfolios.isNotEmpty) {
        await _societyController.updatePortfolio(
          id: portfolios.first.id,
          description: newDescription.trim(),
        );
      } else {
        await _societyController.addPortfolio(
            description: newDescription.trim());
      }

      description = newDescription.trim();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Description updated successfully")),
      );
    } catch (e) {
      debugPrint('❌ Error saveDescription: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to update description: $e")),
      );
    } finally {
      isSavingDescription = false;
      isEditingDescription = false;
      notifyListeners();
    }
  }

  // =========================================================
  // 🔹 SIMPAN / UPDATE SKILLS PORTFOLIO
  // =========================================================
  Future<void> saveSkills(BuildContext context, List<String> newSkills) async {
    if (newSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add at least one skill")),
      );
      return;
    }

    try {
      final portfolios = await _societyController.getAllPortfolios();

      if (portfolios.isNotEmpty) {
        await _societyController.updatePortfolio(
          id: portfolios.first.id,
          skills: newSkills,
        );
      } else {
        await _societyController.addPortfolio(skills: newSkills);
      }

      selectedSkills = newSkills;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Skills updated successfully")),
      );
    } catch (e) {
      debugPrint('❌ Error saveSkills: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to update skills: $e")),
      );
    }

    notifyListeners();
  }

  // =========================================================
  // 🔹 UPLOAD / REPLACE CV
  // =========================================================
  Future<bool> uploadCv(BuildContext context, String filePath,
      {String? fileName}) async {
    if (filePath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a CV file to upload")),
      );
      return false;
    }

    isUploadingCv = true;
    notifyListeners();

    try {
      final portfolios = await _societyController.getAllPortfolios();

      final cleanFileName = fileName ?? filePath.split('/').last;

      if (portfolios.isNotEmpty) {
        // Update CV (replace file lama)
        await _societyController.updatePortfolio(
          id: portfolios.first.id,
          newFilePath: filePath,
        );
      } else {
        // Tambah portofolio baru dengan CV
        await _societyController.addPortfolio(filePath: filePath);
      }

      // Pastikan nama file tidak berubah
      cvFilePath = cleanFileName;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ CV uploaded successfully")),
      );

      return true;
    } catch (e) {
      debugPrint('❌ Error uploadCv: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to upload CV: $e")),
      );
      return false;
    } finally {
      isUploadingCv = false;
      notifyListeners();
    }
  }

  // =========================================================
  // 🔹 HAPUS CV
  // =========================================================
  Future<void> deleteCv(BuildContext context) async {
    try {
      final portfolios = await _societyController.getAllPortfolios();

      if (portfolios.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No CV to delete")),
        );
        return;
      }

      // Panggil backend untuk hapus file CV
      await _societyController.updatePortfolio(
        id: portfolios.first.id,
        newFilePath: null,
      );

      cvFilePath = null;
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🗑️ CV deleted successfully")),
      );
    } catch (e) {
      debugPrint('❌ Error deleteCv: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to delete CV: $e")),
      );
    }
  }

  // =========================================================
  // 🔹 TOGGLE EDIT MODE
  // =========================================================
  void toggleEditDescription() {
    isEditingDescription = !isEditingDescription;
    notifyListeners();
  }
}
