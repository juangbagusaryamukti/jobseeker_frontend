import 'user_model.dart';

/// Model untuk merepresentasikan response dari endpoint login
/// POST https://jobseeker-database.vercel.app/api/auth/login
class LoginResponseModel {
  final bool success;
  final String token;
  final UserModel user;
  final String message;

  LoginResponseModel({
    required this.success,
    required this.token,
    required this.user,
    required this.message,
  });

  /// Membuat instance LoginResponseModel dari JSON
  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      success: json['success'] ?? false,
      token: json['token'] ?? '',
      user: UserModel.fromJson(json['user'] ?? {}),
      message: json['message'] ?? '',
    );
  }

  /// Mengubah instance LoginResponseModel ke bentuk JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'token': token,
      'user': user.toJson(),
      'message': message,
    };
  }

  /// Membuat salinan LoginResponseModel dengan beberapa field yang diubah
  LoginResponseModel copyWith({
    bool? success,
    String? token,
    UserModel? user,
    String? message,
  }) {
    return LoginResponseModel(
      success: success ?? this.success,
      token: token ?? this.token,
      user: user ?? this.user,
      message: message ?? this.message,
    );
  }
}
