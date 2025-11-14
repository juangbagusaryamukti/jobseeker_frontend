import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

/// Service untuk menangani autentikasi user
class AuthService {
  // Base URL API
  static const String baseUrl = 'https://jobseeker-database.vercel.app/api';

  /// Fungsi untuk login user
  /// Mengembalikan Map berisi success, message, token, dan user
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      // Endpoint login
      final url = Uri.parse('$baseUrl/auth/login');

      // Body request
      final body = jsonEncode({
        'email': email,
        'password': password,
      });

      // Kirim POST request ke API
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      // Parse response body
      final responseData = jsonDecode(response.body);

      // Cek apakah login berhasil
      if (response.statusCode == 200 && responseData['success'] == true) {
        // Simpan token ke SharedPreferences
        final token = responseData['token'];
        await _saveToken(token);

        // Parse user data
        final user = UserModel.fromJson(responseData['user']);

        // Return response sukses
        return {
          'success': true,
          'message': responseData['message'] ?? 'Login successful',
          'token': token,
          'user': user,
        };
      } else {
        // Return response gagal dari API
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      // Handle error (network error, parsing error, dll)
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  /// Fungsi private untuk menyimpan token ke SharedPreferences
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  /// Fungsi untuk mengambil token dari SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Fungsi untuk register user baru
  /// Mengembalikan Map berisi success, message, token, dan user
  Future<Map<String, dynamic>> registerUser(
      String name, String email, String password, String role) async {
    try {
      // Endpoint register
      final url = Uri.parse('$baseUrl/auth/register');

      // Body request
      final body = jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      });

      // Kirim POST request ke API
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      // Parse response body
      final responseData = jsonDecode(response.body);

      // Cek apakah register berhasil
      if (response.statusCode == 201 && responseData['success'] == true) {
        // Simpan token ke SharedPreferences
        final token = responseData['token'];
        await _saveToken(token);

        // Parse user data
        final user = UserModel.fromJson(responseData['user']);

        // Return response sukses
        return {
          'success': true,
          'message': responseData['message'] ?? 'Registration successful',
          'token': token,
          'user': user,
        };
      } else {
        // Return response gagal dari API
        return {
          'success': false,
          'message': responseData['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      // Handle error (network error, parsing error, dll)
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  // Fungsi Logout
  Future<bool> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (response.statusCode == 200) {
        // Hapus token lokal
        await prefs.remove('token');
        await prefs.remove('user');
        return true;
      } else {
        print('Logout failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Logout error: $e');
      return false;
    }
  }
}
