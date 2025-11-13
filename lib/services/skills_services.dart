import 'dart:convert';
import 'package:http/http.dart' as http;

class SkillService {
  static const String baseUrl =
      "https://jobseeker-database.vercel.app/api/skills";

  /// 🔹 Ambil semua skill (bisa pakai parameter search)
  Future<List<String>> getSkills({String? search}) async {
    try {
      final uri =
          Uri.parse(baseUrl + (search != null ? "?search=$search" : ""));
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List skills = data['data'];
          return skills.map<String>((item) => item['name'] as String).toList();
        } else {
          return [];
        }
      } else {
        print('❌ Failed to fetch skills. Code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching skills: $e');
      return [];
    }
  }
}
