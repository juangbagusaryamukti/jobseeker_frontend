import '../services/skills_services.dart';

class SkillController {
  final SkillService _service = SkillService();

  /// 🔹 Ambil semua skill dari backend
  Future<List<String>> fetchSkills({String? search}) async {
    final skills = await _service.getSkills(search: search);
    return skills;
  }
}
