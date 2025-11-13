  class SignupData {
    final String name;
    final String email;
    final String password;
    String? role;

    SignupData({
      required this.name,
      required this.email,
      required this.password,
      this.role,
    });
  }
