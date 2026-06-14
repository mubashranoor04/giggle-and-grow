import 'package:finalproject/features/authentication/presentation/pages/resetPassword.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ✅ KEEP ONLY ONE IMPORT (correct one)

// Other imports
import 'signup.dart';
import '../../../../core/utils/size_extension.dart';
import '../provider/auth_provider.dart';
import '../../../onboarding/presentation/pages/onboarding_page.dart';

class AccurateLoginScreen extends StatefulWidget {
  const AccurateLoginScreen({super.key});

  @override
  State<AccurateLoginScreen> createState() => _AccurateLoginScreenState();
}

class _AccurateLoginScreenState extends State<AccurateLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(AuthNotifier auth) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    final navigator = Navigator.of(context);

    final success = await auth.signIn(email, password);

    if (!mounted) return;

    if (success) {
      navigator.pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();

    return Scaffold(
      backgroundColor: const Color(0xFFE1FFC1),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: context.w(24)),
          child: Column(
            children: [
              SizedBox(height: context.h(60)),

              // BEAR AVATAR
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: context.w(155),
                      height: context.w(155),
                      decoration: const BoxDecoration(
                        color: Color(0xFF75FF68),
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Image.asset('assets/images/lbear.png'),
                      ),
                    ),
                    Positioned(
                      right: context.w(-5),
                      top: context.h(5),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA8216E),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Hi Friend!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: context.sp(11),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),

              SizedBox(height: context.h(40)),

              // LOGIN FORM
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(32),
                  vertical: context.h(40),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(context.w(48)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Welcome Back!",
                      style: TextStyle(
                        fontSize: context.sp(30),
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF003802),
                      ),
                    ),

                    SizedBox(height: context.h(32)),

                    if (auth.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            auth.errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: context.sp(12),
                            ),
                          ),
                        ),
                      ),

                    _buildLabel("Email"),
                    _customTextField(
                      hint: "hello@example.com",
                      icon: Icons.email_outlined,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    SizedBox(height: context.h(20)),

                    _buildLabel("Password"),
                    _customTextField(
                      hint: "Top secret code",
                      icon: Icons.lock_outline,
                      isPassword: !_isPasswordVisible,
                      hasSuffix: true,
                      controller: _passwordController,
                      onSuffixTap: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ResetPassword(), // ✅ matches your file
                            ),
                          );
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: const Color(0xFFA8216E),
                            fontWeight: FontWeight.bold,
                            fontSize: context.sp(13),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: context.h(24)),

                    auth.isLoading
                        ? const CircularProgressIndicator(color: Color(0xFFFFD709))
                        : GestureDetector(
                      onTap: () => _handleLogin(auth),
                      child: Container(
                        width: context.w(278),
                        height: context.h(80),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD709),
                          borderRadius: BorderRadius.circular(context.w(48)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFF5B4B00),
                              offset: Offset(0, 5),
                            )
                          ],
                        ),
                        child: Center(
                          child: Text(
                            "LOGIN",
                            style: TextStyle(
                              fontSize: context.sp(22),
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF5B4B00),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: context.h(24)),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(color: Colors.grey, fontSize: context.sp(14)),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const SignupPage()),
                            );
                          },
                          child: Text(
                            "Sign Up",
                            style: TextStyle(
                              color: const Color(0xFF04647D),
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              fontSize: context.sp(14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.h(40)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(left: 12, bottom: context.h(6)),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: context.sp(13),
            color: const Color(0xFF003802),
          ),
        ),
      ),
    );
  }

  Widget _customTextField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    bool hasSuffix = false,
    VoidCallback? onSuffixTap,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      width: context.w(278),
      height: context.h(65),
      decoration: BoxDecoration(
        color: const Color(0xFFE2FFD5),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: const Color(0xFF9EFF8D), width: 4),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        style: const TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: const Color(0xFF006B00)),
          suffixIcon: hasSuffix
              ? IconButton(
            icon: Icon(
              isPassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.orange,
            ),
            onPressed: onSuffixTap,
          )
              : null,
          hintText: hint,
          contentPadding: EdgeInsets.symmetric(vertical: context.h(18)),
        ),
      ),
    );
  }
}