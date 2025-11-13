import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:jobseeker_app/models/portofolio_model.dart';
import 'package:jobseeker_app/models/society_model.dart';
import 'package:jobseeker_app/services/society_services.dart';

class SocietyController {
  final SocietyService _service = SocietyService();
  final ImagePicker _picker = ImagePicker();

  // =========================================================
  // ================ SOCIETY PROFILE SECTION ================
  // =========================================================

  Future<Society?> getProfile() async {
    return await _service.getCurrentSociety();
  }

  Future<bool> updateSocietyData({
    required String name,
    required String address,
    required String phone,
    required String dateOfBirth,
    required String gender,
  }) async {
    final result = await _service.updateSociety(
      name: name,
      address: address,
      phone: phone,
      dateOfBirth: dateOfBirth,
      gender: gender,
    );
    return result['success'] == true;
  }

  Future<Map<String, dynamic>> pickAndUpdateProfilePhoto(
      String imagePath) async {
    try {
      final result = await _service.updateSocietyPhoto(imagePath: imagePath);

      if (result['success'] == true && result['profile'] != null) {
        final updatedProfile = result['profile'] as Society;
        return {
          'success': true,
          'message':
              result['message'] ?? 'Profile photo updated successfully ✅',
          'profile': updatedProfile,
          'imageFile': File(imagePath),
        };
      } else {
        return {
          'success': false,
          'message': result['message'] ?? 'Failed to update profile photo ❌',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// 🧩 Ambil URL foto profil dari database
  Future<String?> getProfilePhoto() async {
    final profile = await _service.getCurrentSociety();
    if (profile == null) {
      print("⚠️ Profile not found");
      return null;
    }
    return profile.profilePhoto;
  }

  // =========================================================
  // ================= PORTFOLIO SECTION =====================
  // =========================================================

  /// ✅ Tambah portofolio baru
  Future<Map<String, dynamic>> addPortfolio({
    List<String>? skills,
    String? description,
    String? filePath,
  }) async {
    try {
      final result = await _service.addPortfolio(
        skills: skills,
        description: description,
        filePath: filePath,
      );

      if (result['success'] == true) {
        return {
          'success': true,
          'portfolio': result['portfolio'] as Portfolio,
          'message': result['message'] ?? 'Portfolio added successfully ✅',
        };
      } else {
        return {
          'success': false,
          'message': result['message'] ?? 'Failed to add portfolio ❌',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// ✅ Ambil semua portfolio society
  Future<List<Portfolio>> getAllPortfolios() async {
    try {
      return await _service.getPortfolios();
    } catch (e) {
      print('❌ Error getAllPortfolios: $e');
      return [];
    }
  }

  /// ✅ Ambil detail 1 portfolio by ID
  Future<Portfolio?> getPortfolioDetail(String id) async {
    try {
      return await _service.getPortfolioById(id);
    } catch (e) {
      print('❌ Error getPortfolioDetail: $e');
      return null;
    }
  }

  /// ✅ Update portfolio
  Future<Map<String, dynamic>> updatePortfolio({
    required String id,
    List<String>? skills,
    String? description,
    String? newFilePath,
  }) async {
    try {
      final result = await _service.updatePortfolio(
        id: id,
        skills: skills,
        description: description,
        newFilePath: newFilePath,
      );

      if (result['success'] == true) {
        return {
          'success': true,
          'portfolio': result['portfolio'] as Portfolio,
          'message': result['message'] ?? 'Portfolio updated successfully ✅',
        };
      } else {
        return {
          'success': false,
          'message': result['message'] ?? 'Failed to update portfolio ❌',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// ✅ Delete portfolio
  Future<Map<String, dynamic>> deletePortfolio(String id) async {
    try {
      final result = await _service.deletePortfolio(id);
      return {
        'success': result['success'] == true,
        'message': result['message'] ??
            (result['success'] == true
                ? 'Portfolio deleted successfully ✅'
                : 'Failed to delete portfolio ❌'),
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // =========================================================
  // ================ HELPER (AMBIL FILE) ====================
  // =========================================================

  /// 📸 Ambil file (gambar/dokumen) dari galeri
  Future<File?> pickPortfolioFile() async {
    try {
      final XFile? picked =
          await _picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        return File(picked.path);
      }
      return null;
    } catch (e) {
      print('❌ Error picking portfolio file: $e');
      return null;
    }
  }
}
