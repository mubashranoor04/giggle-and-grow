import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../../core/constant/assets.dart';
import '../../../../core/utils/size_extension.dart';
import '../provider/auth_provider.dart';
import 'login.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _hasPasswordInput = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() {
      if (_passwordController.text.isNotEmpty != _hasPasswordInput) {
        setState(() => _hasPasswordInput = _passwordController.text.isNotEmpty);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();

    return Scaffold(
      backgroundColor: const Color(0xFFE2FFD7),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: context.w(24)),
          child: Column(
            children: [
              SizedBox(height: context.h(40)),

              // 1. BEAR MASCOT
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(context.w(20)),
                    boxShadow: [
                      BoxShadow(
                        // FIXED: Replaced deprecated withOpacity
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(context.w(20)),
                    child: Image.asset(
                        Assets.bearImage,
                        height: context.h(180),
                        width: context.w(180),
                        fit: BoxFit.cover
                    ),
                  ),
                ),
              ),

              SizedBox(height: context.h(30)),

              // 2. TEXT HEADERS
              Text(
                "Create Your\nAccount",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: context.sp(32),
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF003D00),
                    height: 1.1,
                    fontFamily: 'Jakarta'
                ),
              ),
              SizedBox(height: context.h(8)),
              Text(
                "Let’s start your playful journey!",
                style: TextStyle(
                    fontSize: context.sp(16),
                    color: const Color(0xFF006B00),
                    fontWeight: FontWeight.w600
                ),
              ),

              if (auth.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    auth.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),

              SizedBox(height: context.h(40)),

              // 3. INPUT FIELDS
              _buildLabel("Name"),
              _buildTextField(hint: "Your little name", icon: Assets.nameIcon, controller: _nameController),

              SizedBox(height: context.h(20)),

              _buildLabel("Email"),
              _buildTextField(hint: "hello@example.com", icon: Assets.emailIcon, controller: _emailController),

              SizedBox(height: context.h(20)),

              _buildLabel("Password"),
              _buildPasswordField(),

              SizedBox(height: context.h(40)),

              // 4. SIGN UP BUTTON
              auth.isLoading
                  ? const CircularProgressIndicator(color: Color(0xFF04647D))
                  : GestureDetector(
                onTap: () async {
                  if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty && _nameController.text.isNotEmpty) {
                    final success = await auth.signUp(
                      _emailController.text.trim(),
                      _passwordController.text.trim(),
                      _nameController.text.trim(),
                    );

                    // FIXED: Async Gap check
                    if (!context.mounted) return;

                    if (success) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const AccurateLoginScreen()),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields')),
                    );
                  }
                },
                child: Container(
                  height: context.h(64),
                  decoration: BoxDecoration(
                    color: const Color(0xFF04647D),
                    borderRadius: BorderRadius.circular(context.w(32)),
                    boxShadow: [
                      BoxShadow(
                        // FIXED: Replaced deprecated withOpacity
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4)
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Sign Up",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: context.sp(24),
                            fontWeight: FontWeight.w800
                        ),
                      ),
                      SizedBox(width: context.w(12)),
                      SvgPicture.asset(Assets.forwardButtonIcon, width: context.w(20)),
                    ],
                  ),
                ),
              ),

              SizedBox(height: context.h(30)),

              // 5. LOGIN LINK
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      "Already have an account? ",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF04647D),
                          fontSize: context.sp(14)
                      )
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const AccurateLoginScreen()),
                      );
                    },
                    child: Text(
                        "Login",
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF04647D),
                            decoration: TextDecoration.underline,
                            fontSize: context.sp(14)
                        )
                    ),
                  ),
                ],
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
        padding: EdgeInsets.only(left: context.w(8), bottom: context.h(8)),
        child: Text(
            text,
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: context.sp(16),
                color: const Color(0xFF003D00)
            )
        ),
      ),
    );
  }

  Widget _buildTextField({required String hint, required String icon, required TextEditingController controller}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w500),
        prefixIcon: Padding(
          padding: EdgeInsets.all(context.w(14)),
          child: SvgPicture.asset(icon, width: context.w(20)),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: context.h(20)),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.w(30)),
            borderSide: BorderSide.none
        ),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.w(30)),
            borderSide: const BorderSide(color: Color(0xFFA5FF9F), width: 2)
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        hintText: "••••••••",
        hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w500),
        prefixIcon: Padding(
          padding: EdgeInsets.all(context.w(14)),
          child: SvgPicture.asset(Assets.passwordLockIcon, width: context.w(20)),
        ),
        suffixIcon: _hasPasswordInput
            ? IconButton(
          icon: SvgPicture.asset(
              Assets.eyeIcon,
              width: context.w(24),
              colorFilter: ColorFilter.mode(
                  _isPasswordVisible ? const Color(0xFF04647D) : Colors.grey,
                  BlendMode.srcIn
              )
          ),
          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
        )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: context.h(20)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.w(30)),
            borderSide: const BorderSide(color: Color(0xFFA5FF9F), width: 2)
        ),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.w(30)),
            borderSide: BorderSide.none
        ),
      ),
    );
  }
}