class VacancyModel {
  final String id;
  final String positionName;
  final int capacity;
  final String description;
  final DateTime submissionStartDate;
  final DateTime submissionEndDate;
  final String companyId;

  // Tambahan baru
  final String? companyName;
  final String? companyAddress;
  final String? companyLogo;
  final String? status; // Active / Inactive

  VacancyModel({
    required this.id,
    required this.positionName,
    required this.capacity,
    required this.description,
    required this.submissionStartDate,
    required this.submissionEndDate,
    required this.companyId,
    this.companyName,
    this.companyAddress,
    this.companyLogo,
    this.status,
  });

  factory VacancyModel.fromJson(Map<String, dynamic> json) {
    final companyData = json['company'] is Map ? json['company'] : null;

    return VacancyModel(
      id: json['_id'] ?? '',
      positionName: json['position_name'] ?? '',
      capacity: json['capacity'] ?? 0,
      description: json['description'] ?? '',
      submissionStartDate: DateTime.parse(json['submission_start_date']),
      submissionEndDate: DateTime.parse(json['submission_end_date']),
      companyId: json['company'] is String
          ? json['company']
          : companyData?['_id'] ?? '',

      // Data tambahan (optional, aman jika null)
      companyName: companyData?['name'] ?? 'Unknown Company',
      companyAddress: companyData?['address'] ?? 'Unknown Address',
      companyLogo: companyData?['logo'],
      status: json['status'] ?? 'Active', // default Active
    );
  }

  VacancyModel copyWith({
    String? id,
    String? positionName,
    int? capacity,
    String? description,
    DateTime? submissionStartDate,
    DateTime? submissionEndDate,
    String? companyId,
    String? companyName,
    String? companyAddress,
    String? companyLogo,
    String? status,
  }) {
    return VacancyModel(
      id: id ?? this.id,
      positionName: positionName ?? this.positionName,
      capacity: capacity ?? this.capacity,
      description: description ?? this.description,
      submissionStartDate: submissionStartDate ?? this.submissionStartDate,
      submissionEndDate: submissionEndDate ?? this.submissionEndDate,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      companyAddress: companyAddress ?? this.companyAddress,
      companyLogo: companyLogo ?? this.companyLogo,
      status: status ?? this.status,
    );
  }
}
