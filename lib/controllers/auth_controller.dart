import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class AuthController {
  final AuthService _authService = AuthService();

  Future<void> logout(BuildContext context) async {
    // Ambil token dari local storage
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      // Jika tidak ada token, langsung kembali ke login
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    // Panggil service logout ke backend
    final success = await _authService.logout();

    if (success) {
      // Hapus data lokal
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logout berhasil'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
      await prefs.remove('token');
      await prefs.remove('user');

      // Arahkan ke halaman login
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      // Tampilkan pesan error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logout gagal. Coba lagi.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
