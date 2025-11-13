class PositionAppliedModel {
  final String id;
  final String status;
  final String? message; // dari HRD ke society
  final String? coverLetter; // dari society ke HRD
  final DateTime applyDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final Map<String, dynamic>? availablePosition;
  final Map<String, dynamic>? society;
  final Map<String, dynamic>? portfolio;

  PositionAppliedModel({
    required this.id,
    required this.status,
    required this.applyDate,
    this.message,
    this.coverLetter,
    this.createdAt,
    this.updatedAt,
    this.availablePosition,
    this.society,
    this.portfolio,
  });

  factory PositionAppliedModel.fromJson(Map<String, dynamic> json) {
    return PositionAppliedModel(
      id: json['_id'] ?? '',
      status: json['status'] ?? 'PENDING',
      message: json['message'],
      coverLetter: json['cover_letter'],
      applyDate: DateTime.tryParse(json['apply_date'] ?? '') ?? DateTime.now(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      availablePosition:
          json['available_position'] is Map ? json['available_position'] : null,
      society: json['society'] is Map ? json['society'] : null,
      portfolio: json['portfolio'] is Map ? json['portfolio'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'status': status,
      'message': message,
      'cover_letter': coverLetter,
      'apply_date': applyDate.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'available_position': availablePosition,
      'society': society,
      'portfolio': portfolio,
    };
  }
}
