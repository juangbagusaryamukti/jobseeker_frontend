import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:jobseeker_app/models/portofolio_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/society_model.dart';

class SocietyService {
  static const String baseUrl =
      'https://jobseeker-database.vercel.app/api/auth';

  static const String societyUrl =
      "https://jobseeker-database.vercel.app/api/societies";

  /// ✅ Lengkapi profil society (upload image ke Vercel Blob via backend)
  Future<Map<String, dynamic>> completeSocietyProfile({
    required String name,
    required String address,
    required String phone,
    required String dateOfBirth,
    required String gender,
    required String defaultAssetPath, // ex: 'assets/image/user.png'
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {
          'success': false,
          'message': 'No token found. Please login first.'
        };
      }

      final byteData = await rootBundle.load(defaultAssetPath);
      final bytes = byteData.buffer.asUint8List();
      final base64Image = base64Encode(bytes);

      final uri = Uri.parse('$baseUrl/complete-society-profile');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode({
          'name': name,
          'address': address,
          'phone': phone,
          'date_of_birth': dateOfBirth,
          'gender': gender,
          'profile_photo': base64Image,
        }),
      );

      Map<String, dynamic> responseData = {};
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        return {
          'success': false,
          'message': 'Invalid response format from server.',
        };
      }

      if (response.statusCode == 200 && responseData['success'] == true) {
        final profile = Society.fromJson(responseData['profile']);
        return {
          'success': true,
          'message': responseData['message'] ?? 'Profile updated successfully',
          'profile': profile,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to complete profile',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  Future<Society?> getCurrentSociety() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return null;

      final uri = Uri.parse('$societyUrl/me');
      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // ✅ Cek apakah formatnya seperti {"success":true,"data":{...}}
        if (data['data'] != null) {
          return Society.fromJson(data['data']);
        }

        // ✅ Jika backend langsung kirim field tanpa "data"
        if (data['_id'] != null) {
          return Society.fromJson(data);
        }

        print("⚠️ Unexpected response format: ${response.body}");
        return null;
      }

      print("❌ Failed getCurrentSociety: ${response.statusCode}");
      return null;
    } catch (e) {
      print('❌ Error fetching society: $e');
      return null;
    }
  }

  /// 🔹 Update tanpa profile photo
  Future<Map<String, dynamic>> updateSociety({
    required String name,
    required String address,
    required String phone,
    required String dateOfBirth,
    required String gender,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return {'success': false, 'message': 'Token missing'};

      final uri = Uri.parse('$societyUrl/me');
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode({
          'name': name,
          'address': address,
          'phone': phone,
          'date_of_birth': dateOfBirth,
          'gender': gender,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'profile': Society.fromJson(data)};
      } else {
        return {'success': false, 'message': data['msg'] ?? 'Failed to update'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// 🔹 Update profile picture
  Future<Map<String, dynamic>> updateSocietyPhoto({
    required String imagePath,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {
          'success': false,
          'message': 'No token found. Please login first.',
        };
      }

      final uri = Uri.parse('$societyUrl/me');
      final request = http.MultipartRequest('PUT', uri)
        ..headers['x-auth-token'] = token
        ..files
            .add(await http.MultipartFile.fromPath('profile_photo', imagePath));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);

      if (response.statusCode == 200 && data['success'] == true) {
        final profile = Society.fromJson(data['profile']);
        return {
          'success': true,
          'message': data['message'] ?? 'Profile photo updated successfully',
          'profile': profile,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update photo',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // =========================================================
  // ================= PORTFOLIO FUNCTIONS ===================
  // =========================================================

  /// ✅ Add portfolio (Create)
  Future<Map<String, dynamic>> addPortfolio({
    List<String>? skills,
    String? description,
    String? filePath,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        return {'success': false, 'message': 'No auth token found'};
      }

      final uri = Uri.parse('$societyUrl/portfolio');
      final request = http.MultipartRequest('POST', uri);
      request.headers['x-auth-token'] = token;

      // kirim field hanya jika tidak null
      if (skills != null && skills.isNotEmpty) {
        request.fields['skills'] = jsonEncode(skills);
      }
      if (description != null && description.isNotEmpty) {
        request.fields['description'] = description;
      }

      // kirim file jika ada
      if (filePath != null && filePath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('file', filePath));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print("✅ Portfolio added: ${data['message']}");
        return {'success': true, 'portfolio': Portfolio.fromJson(data['data'])};
      } else {
        print("❌ Add portfolio failed: ${response.body}");
        return {
          'success': false,
          'message':
              jsonDecode(response.body)['message'] ?? 'Failed to add portfolio'
        };
      }
    } catch (e) {
      print('❌ Error adding portfolio: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// ✅ Get all portfolios
  Future<List<Portfolio>> getPortfolios() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return [];

      final uri = Uri.parse('$societyUrl/portfolio');
      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = data['data'];
        return list.map((e) => Portfolio.fromJson(e)).toList();
      } else {
        print("⚠️ Failed to fetch portfolios: ${response.body}");
        return [];
      }
    } catch (e) {
      print('❌ Error fetching portfolios: $e');
      return [];
    }
  }

  /// ✅ Get portfolio by ID
  Future<Portfolio?> getPortfolioById(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return null;

      final uri = Uri.parse('$societyUrl/portfolio/$id');
      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Portfolio.fromJson(data['data']);
      } else {
        print('⚠️ Failed to fetch portfolio by ID: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error getting portfolio: $e');
      return null;
    }
  }

  /// ✅ Update portfolio (skills, description, file)
  Future<Map<String, dynamic>> updatePortfolio({
    required String id,
    List<String>? skills,
    String? description,
    String? newFilePath,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        return {'success': false, 'message': 'Token not found'};
      }

      final uri = Uri.parse('$societyUrl/portfolio/$id');
      final request = http.MultipartRequest('PUT', uri)
        ..headers['x-auth-token'] = token;

      // kirim field yang diubah
      if (skills != null) request.fields['skills'] = jsonEncode(skills);
      if (description != null) request.fields['description'] = description;

      // jika file baru diberikan, ganti file lama di server
      if (newFilePath != null && newFilePath.isNotEmpty) {
        request.files
            .add(await http.MultipartFile.fromPath('file', newFilePath));
      }

      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();
      final data = jsonDecode(responseBody);

      if (streamedResponse.statusCode == 200 && data['success'] == true) {
        print("✅ Portfolio updated successfully");
        final portfolio = Portfolio.fromJson(data['data']);
        return {
          'success': true,
          'portfolio': portfolio,
          'message': data['message']
        };
      } else {
        print("❌ Update failed: ${data['message']}");
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update portfolio'
        };
      }
    } catch (e) {
      print("❌ Error updating portfolio: $e");
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  /// ✅ Delete portfolio (hapus termasuk file PDF di server)
  Future<Map<String, dynamic>> deletePortfolio(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        return {'success': false, 'message': 'Token not found'};
      }

      final uri = Uri.parse('$societyUrl/portfolio/$id');
      final response = await http.delete(uri, headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      });

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        print("🗑️ Portfolio deleted successfully");
        return {'success': true, 'message': data['message']};
      } else {
        print("⚠️ Delete failed: ${data['message']}");
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to delete portfolio'
        };
      }
    } catch (e) {
      print("❌ Error deleting portfolio: $e");
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }
}
