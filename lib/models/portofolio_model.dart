class Portfolio {
  final String id;
  final List<String> skills;
  final String description;
  final String file;
  final String societyId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Portfolio({
    required this.id,
    required this.skills,
    required this.description,
    required this.file,
    required this.societyId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Portfolio.fromJson(Map<String, dynamic> json) {
    return Portfolio(
      id: json['_id'] ?? '',
      skills: List<String>.from(json['skills'] ?? []),
      description: json['description'] ?? '',
      file: json['file'] ?? '',
      societyId: json['society'] ?? '',
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
        'skills': skills,
        'description': description,
        'file': file,
        'society': societyId,
      };
}
