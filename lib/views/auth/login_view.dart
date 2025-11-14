import 'package:flutter/material.dart';
import 'package:jobseeker_app/widgets/colors.dart';
import 'package:jobseeker_app/widgets/customtextfield.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';

/// Halaman Login untuk user
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  // Controllers untuk TextFormField
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Instance AuthService
  final AuthService _authService = AuthService();

  // State untuk loading indicator
  bool _isLoading = false;

  // State untuk show/hide password
  bool _obscurePassword = true;

  // State untuk remember me checkbox
  bool _rememberMe = false;

  @override
  void dispose() {
    // Dispose controllers saat widget dihapus
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Fungsi untuk handle login
  Future<void> _handleLogin() async {
    // Ambil value dari text field
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Validasi input tidak boleh kosong
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Set loading state
    setState(() {
      _isLoading = true;
    });

    try {
      // Panggil fungsi login dari AuthService
      final result = await _authService.loginUser(email, password);

      // Cek hasil login
      if (result['success'] == true) {
        // Login berhasil
        final user = result['user'] as UserModel;
        final message = result['message'] as String;

        if (user.role == 'HRD') {
          Navigator.pushReplacementNamed(context, '/hrd_dashboard');
        } else if (user.role == 'Society') {
          Navigator.pushReplacementNamed(context, '/society_dashboard');
        }

        // Tampilkan snackbar sukses
        _showSnackBar("Login berhasil", isError: false);

        // TODO: Navigate to home screen
        // Navigator.pushReplacementNamed(context, '/home');

        // Debug: print user data
        debugPrint(
            'Login successful! User: ${user.name}, Email: ${user.email}');
      } else {
        // Login gagal - tampilkan pesan error dari API
        final message = result['message'] as String;
        _showSnackBar(message, isError: true);
      }
    } catch (e) {
      // Handle unexpected error
      _showSnackBar('An unexpected error occurred', isError: true);
    } finally {
      // Set loading state ke false
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Fungsi untuk menampilkan SnackBar
  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/image/bg_auth.png"),
                fit: BoxFit.cover)),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 48),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      "assets/image/Logo.png",
                      height: 50,
                    ),
                    SizedBox(height: 24),
                    // Header text
                    const Text(
                      'Welcome Back to Workscout',
                      style: TextStyle(
                        fontFamily: "Lato",
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Log in to your Workscout account to continue your job search, manage applications, and stay updated with the latest job opportunities.',
                      style: TextStyle(
                        fontFamily: "Lato",
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 64),

                    // Email TextField
                    CustomTextField(
                      controller: _emailController,
                      label: "Email",
                      hintText: "Please enter your email address",
                      keyboardType: TextInputType.emailAddress,
                      enabled: !_isLoading,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email address';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Password TextField dengan show/hide
                    CustomTextField(
                      controller: _passwordController,
                      label: "Password",
                      hintText: "Please enter your password",
                      keyboardType: TextInputType.visiblePassword,
                      enabled: !_isLoading,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters long';
                        }
                        return null;
                      },
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: ColorsApp.primarydark,
                          size: 18,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      "Password must be at least 8 characters long",
                      style: TextStyle(
                          fontSize: 12,
                          fontFamily: "Lato",
                          fontWeight: FontWeight.w700,
                          color: ColorsApp.Grey2),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    // ROW UNTUK CHECK BOX REMEMBER ME PADA BAGIAN KIRI, DAN FORGOT PASSWORD PADA BAGIAN KANAN
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Check Box dan Text Remember Me
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                              activeColor: ColorsApp.primarydark,
                              side: BorderSide(color: ColorsApp.Grey2),
                            ),
                            Text(
                              'Remember Me',
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: "Lato",
                                fontWeight: FontWeight.w400,
                                color: ColorsApp.Grey2,
                              ),
                            ),
                          ],
                        ),
                        // Text link untuk forgot password
                        TextButton(
                          onPressed: () {
                            // TODO: Navigate to forgot password page
                            debugPrint('Forgot password clicked');
                          },
                          child: Text(
                            'Forgot Password',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: "Lato",
                              fontWeight: FontWeight.w700,
                              color: ColorsApp.primarydark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Login Button dengan loading indicator
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsApp.primarydark,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(
                                fontFamily: "Lato",
                                color: ColorsApp.Grey4,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    // BUATKAN BUTTON TRANSPARANT UNTUK LOGIN MELALUI GOOGLE
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/image/google.png",
                          height: 30,
                          width: 30,
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: Implementasi Google Sign In
                            debugPrint('Google Sign In clicked');
                          },
                          child: Text(
                            'Login with Google',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: "Lato",
                              fontWeight: FontWeight.w700,
                              color: ColorsApp.Grey1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\' t Have Account?',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: "Lato",
                            color: ColorsApp.Grey1,
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/signup');
                          },
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              decorationColor: ColorsApp.primarydark,
                              decoration: TextDecoration.underline,
                              fontSize: 13,
                              fontFamily: "Lato",
                              fontWeight: FontWeight.w600,
                              color: ColorsApp.primarydark,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
