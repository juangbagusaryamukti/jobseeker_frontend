import 'package:flutter/material.dart';
import 'package:jobseeker_app/widgets/colors.dart';
import '../../models/signup_data.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';

class SignupRoleView extends StatefulWidget {
  final SignupData signUpData;
  const SignupRoleView({super.key, required this.signUpData});

  @override
  State<SignupRoleView> createState() => _SignupRoleViewState();
}

class _SignupRoleViewState extends State<SignupRoleView> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _selectedRole;

  Future<void> _handleRegister() async {
    if (_selectedRole == null) {
      _showSnackBar('Please select a role', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    widget.signUpData.role = _selectedRole;

    try {
      final result = await _authService.registerUser(
        widget.signUpData.name,
        widget.signUpData.email,
        widget.signUpData.password,
        widget.signUpData.role!,
      );

      if (result['success'] == true) {
        final user = result['user'] as UserModel;
        final message = result['message'] as String;

        _showSnackBar(message, isError: false);

        if (_selectedRole == 'HRD') {
          Navigator.pushReplacementNamed(context, '/completehrd');
          debugPrint("ini adalah token hrd: ${result['token']}");
        } else if (_selectedRole == "Society") {
          Navigator.pushReplacementNamed(context, '/completesociety');
        }

        debugPrint(
            'Registration successful! User: ${user.name}, Role: ${user.role}');
      } else {
        _showSnackBar(result['message'] as String, isError: true);
      }
    } catch (e) {
      _showSnackBar('Unexpected error occurred', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
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
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/image/bg_auth.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset("assets/image/Logo.png", height: 30),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Workscout",
                          style: TextStyle(
                            fontFamily: "Lato",
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Are you currently looking for new opportunities',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontFamily: "Lato",
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(
                      height: 32,
                    ),
                    // Role Selection Buttons
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () =>
                                setState(() => _selectedRole = 'Society'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedRole == 'Society'
                                  ? ColorsApp.primarydark
                                  : Colors.white,
                              side: BorderSide(color: ColorsApp.Grey3),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 22, horizontal: 32),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Yes, Actively looking',
                                  style: TextStyle(
                                    fontFamily: "Lato",
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: _selectedRole == 'Society'
                                        ? Colors.white
                                        : ColorsApp.black,
                                  ),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  'Recive exlusive job invites and get contracted by employers',
                                  style: TextStyle(
                                    fontFamily: "Lato",
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _selectedRole == 'Society'
                                        ? Colors.white
                                        : ColorsApp.Grey1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () =>
                                setState(() => _selectedRole = 'HRD'),
                            style: ElevatedButton.styleFrom(
                              alignment: Alignment.centerLeft,
                              backgroundColor: _selectedRole == 'HRD'
                                  ? ColorsApp.primarydark
                                  : Colors.white,
                              side: BorderSide(color: ColorsApp.Grey3),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 22, horizontal: 32),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'I\'m Open Job For Seeking',
                                  style: TextStyle(
                                    fontFamily: "Lato",
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: _selectedRole == 'HRD'
                                        ? Colors.white
                                        : ColorsApp.black,
                                  ),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  'Choose this to occasionally receive exclusive job invites.',
                                  style: TextStyle(
                                    fontFamily: "Lato",
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _selectedRole == 'HRD'
                                        ? Colors.white
                                        : ColorsApp.Grey1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
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
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Next",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: "Lato",
                                  color: ColorsApp.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward,
                                color: ColorsApp.white,
                                size: 18,
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
