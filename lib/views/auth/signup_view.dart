import 'package:flutter/material.dart';
import 'package:jobseeker_app/widgets/colors.dart';
import 'package:jobseeker_app/widgets/customtextfield.dart';
import '../../models/signup_data.dart';
import 'signup_role_view.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isEmailValid = true;
  String? _emailErrorText;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  void _validateForm() {
    if (_formKey.currentState!.validate()) {
      _goToNextStep();
    } else {
      return;
    }
  }

  void _goToNextStep() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Validate email format
    if (!_isValidEmail(email)) {
      setState(() {
        _isEmailValid = false;
        _emailErrorText = 'Please enter a valid email address';
      });
      return;
    } else {
      setState(() {
        _isEmailValid = true;
        _emailErrorText = null;
      });
    }
    if (password.length < 8) {
      _showSnackBar('Password must be at least 8 characters long',
          isError: true);
      return;
    }

    final signupData = SignupData(name: name, email: email, password: password);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SignupRoleView(signUpData: signupData),
      ),
    );
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
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
              fit: BoxFit.cover,
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 48),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Image.asset("assets/image/Logo.png", height: 50),
                      const SizedBox(height: 24),
                      const Text(
                        'Create Your Workscout Account',
                        style: TextStyle(
                          fontFamily: "Lato",
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Join Workscout to find your perfect job. Create an account for personalized matches and career resources.',
                        style: TextStyle(
                          fontFamily: "Lato",
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 64),

                      // Name Field
                      CustomTextField(
                        controller: _nameController,
                        label: "Full Name",
                        hintText: "Please enter your full name",
                        keyboardType: TextInputType.name,
                        enabled: !_isLoading,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      // Email Field
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

                      // Email validation error message
                      if (_emailErrorText != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _emailErrorText!,
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: "Lato",
                              fontWeight: FontWeight.w400,
                              color: Colors.red,
                            ),
                          ),
                        ),

                      const SizedBox(height: 18),

                      // Password Field
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
                      const SizedBox(height: 8),
                      Text(
                        "Password must be at least 8 characters long",
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: "Lato",
                          fontWeight: FontWeight.w700,
                          color: ColorsApp.Grey2,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // NEXT BUTTON
                      ElevatedButton(
                        onPressed: _isLoading ? null : _validateForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorsApp.primarydark,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : const Text(
                                'Next',
                                style: TextStyle(
                                  fontFamily: "Lato",
                                  color: ColorsApp.Grey4,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      const SizedBox(height: 12),

                      // Link ke login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account?',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: "Lato",
                              color: ColorsApp.Grey1,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            child: Text(
                              'Log in',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                decorationColor: ColorsApp.primarydark,
                                fontSize: 13,
                                fontFamily: "Lato",
                                fontWeight: FontWeight.w600,
                                color: ColorsApp.primarydark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }
}
