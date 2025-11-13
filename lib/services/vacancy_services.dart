import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jobseeker_app/models/position_applied_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vacancy_model.dart';

class VacancyService {
  final String baseUrl = 'https://jobseeker-database.vercel.app/api/positions';

  // Helper untuk ambil token dari SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // 1️⃣ CREATE position (HRD)
  Future<VacancyModel?> createPosition({
    required String positionName,
    required int capacity,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required String token,
  }) async {
    try {
      final url = Uri.parse(baseUrl); // pastikan endpoint benar

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode({
          'position_name': positionName,
          'capacity': capacity,
          'description': description,
          // backend expects ISO 8601 string format
          'submission_start_date': startDate.toIso8601String(),
          'submission_end_date': endDate.toIso8601String(),
        }),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (body is Map<String, dynamic> &&
            body['data'] is Map<String, dynamic>) {
          return VacancyModel.fromJson(body['data']);
        } else {
          throw Exception('Unexpected response format: ${response.body}');
        }
      } else {
        final message =
            body['error'] ?? body['message'] ?? 'Failed to create position';
        throw Exception(message);
      }
    } catch (e, stacktrace) {
      print('Error in VacancyService.createPosition: $e');
      print(stacktrace);
      rethrow;
    }
  }

  // 2️⃣ GET all positions (public)
  Future<List<VacancyModel>> getAllPositions() async {
    final url = Uri.parse('$baseUrl/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => VacancyModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load positions');
    }
  }

  // 3️⃣ GET company positions (HRD)
  Future<List<VacancyModel>> getCompanyPositions() async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/company');
    final response = await http.get(url, headers: {
      'x-auth-token': token!,
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => VacancyModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load company positions');
    }
  }

  // 4️⃣ APPLY to position (Society)
  Future<void> applyToPosition(String positionId, String coverLetter) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/$positionId/apply');
    final response = await http.post(url,
        headers: {
          'x-auth-token': token!,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'cover_letter': coverLetter,
        }));

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['msg'] ?? 'Failed to apply');
    }
  }

  // 5️⃣ UPDATE application status (HRD)
  Future<void> updateApplicationStatus({
    required String applicationId,
    required String status, // ACCEPTED / REJECTED
    required String message,
  }) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/applications/$applicationId');
    final response = await http.put(
      url,
      headers: {
        'x-auth-token': token!,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'status': status,
        'message': message,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
          jsonDecode(response.body)['msg'] ?? 'Failed to update status');
    }
  }

  // 6️⃣ GET applicants (HRD)
  Future<List<dynamic>> getApplicants(String positionId) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/$positionId/applications');
    final response = await http.get(url, headers: {
      'x-auth-token': token!,
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load applicants');
    }
  }

  // 7️⃣ GET my applications (Society)

  // === Get all applications for current society ===
  Future<List<PositionAppliedModel>> getMyApplications(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/my-applications'),
      headers: {
        'x-auth-token': token,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => PositionAppliedModel.fromJson(json)).toList();
    } else {
      throw Exception(
          'Gagal mengambil data lamaran: ${response.statusCode} - ${response.body}');
    }
  }
}
