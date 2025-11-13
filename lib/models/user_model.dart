/// Model untuk merepresentasikan data user dari API
class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isProfileComplete;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isProfileComplete,
  });

  /// Membuat instance UserModel dari JSON response API
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      isProfileComplete: json['isProfileComplete'] ?? false,
    );
  }

  /// Mengubah instance UserModel ke bentuk JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'isProfileComplete': isProfileComplete,
    };
  }

  /// Membuat salinan UserModel dengan beberapa field yang diubah
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    bool? isProfileComplete,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }
}
