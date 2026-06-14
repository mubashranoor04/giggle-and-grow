// ignore: file_names
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finalproject/core/utils/size_extension.dart';
import '../provider/auth_provider.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reset Password',
          style: TextStyle(
            fontSize: context.sp(18),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.w(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (auth.errorMessage != null)
              Padding(
                padding: EdgeInsets.only(bottom: context.h(10)),
                child: Text(
                  auth.errorMessage!,
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: context.sp(14),
                  ),
                ),
              ),

            if (auth.infoMessage != null)
              Padding(
                padding: EdgeInsets.only(bottom: context.h(10)),
                child: Text(
                  auth.infoMessage!,
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: context.sp(14),
                  ),
                ),
              ),

            SizedBox(height: context.h(20)),

            TextField(
              controller: _emailController,
              style: TextStyle(
                fontSize: context.sp(14),
              ),
              decoration: InputDecoration(
                labelText: 'Gmail Address',
                hintText: 'example@gmail.com',
                labelStyle: TextStyle(
                  fontSize: context.sp(14),
                ),
                hintStyle: TextStyle(
                  fontSize: context.sp(13),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    context.w(12),
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: context.w(16),
                  vertical: context.h(16),
                ),
              ),
            ),

            SizedBox(height: context.h(20)),

            auth.isLoading
                ? Center(
              child: SizedBox(
                height: context.h(30),
                width: context.w(30),
                child: const CircularProgressIndicator(),
              ),
            )
                : SizedBox(
              width: double.infinity,
              height: context.h(50),
              child: ElevatedButton(
                onPressed: () {
                  auth.sendPasswordReset(
                    _emailController.text.trim(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      context.w(12),
                    ),
                  ),
                ),
                child: Text(
                  'Send Reset Link',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: context.sp(15),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}