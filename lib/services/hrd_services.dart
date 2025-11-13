import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hrd_model.dart';

class HrdService {
  static const String baseUrl =
      'https://jobseeker-database.vercel.app/api/auth';

  static const String hrdUrl =
      'https://jobseeker-database.vercel.app/api/companies';

  /// ✅ Lengkapi profil HRD (dengan upload logo default)
  Future<Map<String, dynamic>> completeHrdProfile({
    required String name,
    required String address,
    required String phone,
    required String description,
    String defaultAssetPath =
        'assets/image/house.png', // contoh: 'assets/image/company.png'
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

      // Ambil file default logo dari assets
      final byteData = await rootBundle.load(defaultAssetPath);
      final bytes = byteData.buffer.asUint8List();

      // Encode base64 (backend akan upload ke Blob)
      final base64Logo = base64Encode(bytes);

      final uri = Uri.parse('$hrdUrl/me'); // gunakan endpoint companies
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
          'description': description,
          'logo': base64Logo,
        }),
      );

      print('📥 Status Code: ${response.statusCode}');
      print('📥 Response Body Raw: ${response.body}');

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
        final profile = HrdModel.fromJson(responseData['data']);
        return {
          'success': true,
          'message': responseData['message'] ?? 'Profile updated successfully',
          'data': profile,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to update profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  /// ✅ Update hanya logo HRD
  Future<Map<String, dynamic>> updateHrdLogo({
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

      final uri = Uri.parse('$hrdUrl/me');
      final request = http.MultipartRequest('PUT', uri)
        ..headers['x-auth-token'] = token
        ..files.add(await http.MultipartFile.fromPath('logo', imagePath));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('📤 Status Code: ${response.statusCode}');
      print('📤 Response: $responseBody');

      final data = jsonDecode(responseBody);

      if (response.statusCode == 200 && data['success'] == true) {
        final profile = HrdModel.fromJson(data['data']);
        return {
          'success': true,
          'message': data['message'] ?? 'Logo updated successfully',
          'profile': profile,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update logo',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> getHrdProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {
          'success': false,
          'message': 'No token found. Please login first.',
        };
      }

      // 🔁 Ubah ke endpoint company
      final uri = Uri.parse('$hrdUrl/me');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      print('📥 Fetch HRD Profile: ${response.statusCode}');
      print('📥 Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final profile = HrdModel.fromJson(data['data']);
        return {
          'success': true,
          'data': profile,
        };
      } else {
        final body = jsonDecode(response.body);
        return {
          'success': false,
          'message': body['message'] ?? 'Failed to load profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  /// ✅ Update data profil HRD (tanpa logo)
  Future<Map<String, dynamic>> updateHrdProfile({
    required String name,
    required String address,
    required String phone,
    required String description,
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

      final uri = Uri.parse('$hrdUrl/me'); // Endpoint update HRD profile
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
          'description': description,
        }),
      );

      print('📤 Update HRD Profile Status: ${response.statusCode}');
      print('📤 Response Body: ${response.body}');

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
        final profile = HrdModel.fromJson(responseData['data']);
        return {
          'success': true,
          'message':
              responseData['message'] ?? 'Profile updated successfully ✅',
          'profile': profile,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to update profile ❌',
        };
      }
    } catch (e) {
      print('⚠️ Error updateHrdProfile: $e');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }
}
