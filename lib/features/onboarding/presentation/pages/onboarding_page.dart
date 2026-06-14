import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constant/colors.dart';
import '../../../../core/utils/size_extension.dart';
import '../../../dashboard/presentation/pages/home_dashboard.dart';
import '../onboarding_model.dart';
import '../widgets/onboarding_body.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int currentIndex = 0;

  // Handles navigation to the Home Dashboard
  void _navigateToDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeDashboard()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        // Fetches your remote UI asset URLs from Firestore
        future: FirebaseFirestore.instance.collection('dashboard_media').doc('ui_assets').get(),
        builder: (context, snapshot) {
          // Displays a loader while waiting for network data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.nextButtonGreen),
                ),
              ),
            );
          }

          // Extracts Firestore document data safely as a Map
          final firestoreAssets = (snapshot.data?.data() as Map<String, dynamic>?) ?? {};

          return Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.bgLightBlue, AppColors.bgSoftBlue],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // 1. SKIP Button Layout
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: context.w(20),
                        top: context.h(10),
                      ),
                      child: TextButton(
                        onPressed: _navigateToDashboard,
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.skipButtonBg,
                          padding: EdgeInsets.symmetric(horizontal: context.w(20)),
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          "SKIP",
                          style: TextStyle(
                            color: AppColors.skipText,
                            fontSize: context.sp(14),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 2. Main Onboarding Body Content Section
                  Expanded(
                    child: OnboardingBody(
                      content: onboardingSteps[currentIndex],
                      currentIndex: currentIndex,
                      firestoreAssets: firestoreAssets,
                    ),
                  ),

                  // 3. NEXT / GET STARTED Action Button Layout
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.w(40)),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (currentIndex < 2) {
                            currentIndex++;
                          } else {
                            _navigateToDashboard();
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.nextButtonGreen,
                        minimumSize: Size(double.infinity, context.h(60)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(context.w(30)),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            currentIndex == 2 ? "GET STARTED" : "NEXT",
                            style: TextStyle(
                              fontSize: context.sp(24),
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 4. Bottom Step Counter Progress Text
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: context.h(20)),
                    child: Text(
                      "STEP ${currentIndex + 1} OF 3",
                      style: TextStyle(
                        color: const Color(0XFF00576E),
                        fontWeight: FontWeight.normal,
                        fontSize: context.sp(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}