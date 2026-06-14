import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../core/constant/assets2.dart';
import '../../../../../core/constant/colors.dart';
import '../../../../core/utils/size_extension.dart';
import '../../../authentication/presentation/pages/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Map<String, dynamic> imageUrls = {};
  Map<String, dynamic> iconUrls = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSplashAssets();
  }

  Future<void> fetchSplashAssets() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('app_core')
          .doc('splash_screen')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        setState(() {
          imageUrls = Map<String, dynamic>.from(data['image_urls'] ?? {});
          iconUrls = Map<String, dynamic>.from(data['icon_urls'] ?? {});
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching splash assets: $e");
      setState(() {
        isLoading = false;
      });
    }

    // Screen Flow: Logic ONLY runs after initialization sequences resolve safely
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 5));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AccurateLoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColors.bgSoftMint,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryPink),
        ),
      );
    }

    final String mascotMainUrl = (imageUrls['mascot_main'] ?? '').toString().trim();
    final String mascotHandUrl = (imageUrls['mascot_hand'] ?? '').toString().trim();

    return Scaffold(
      body: Stack(
        children: [
          // 1. BACKGROUND
          Container(color: AppColors.bgSoftMint),

          // 2. TOP-LEFT PINK BLUR (Fixed color assignment bug)
          Positioned(
            top: context.h(60),
            left: context.w(50),
            child: Container(
              width: context.w(66),
              height: context.w(66), // Locked to match bounding width constraints cleanly
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent, // Using transparent instead of alpha 0 for clean shadow bleeding
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPink.withValues(alpha: 0.2),
                    blurRadius: context.w(10),
                    spreadRadius: context.w(20),
                  ),
                ],
              ),
            ),
          ),

          // 3. MAIN UI
          Column(
            children: [
              SizedBox(height: context.h(176)),
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Main Mascot with Cloud Fallback
                    mascotMainUrl.isNotEmpty
                        ? Image.network(
                      mascotMainUrl,
                      width: context.w(192),
                      height: context.h(192),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        AppAssets.imgMascot,
                        width: context.w(192),
                        height: context.h(192),
                        fit: BoxFit.contain,
                      ),
                    )
                        : Image.asset(
                      AppAssets.imgMascot,
                      width: context.w(192),
                      height: context.h(192),
                      fit: BoxFit.contain,
                    ),

                    // MASCOT HAND with Cloud Fallback
                    Positioned(
                      right: context.w(12),
                      bottom: context.h(45),
                      child: Transform.rotate(
                        angle: -12 * (3.14159 / 180),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(context.w(48)),
                          child: mascotHandUrl.isNotEmpty
                              ? Image.network(
                            mascotHandUrl,
                            width: context.w(64),
                            height: context.h(64),
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Image.asset(
                              AppAssets.imgMascotHand,
                              width: context.w(64),
                              height: context.h(64),
                              fit: BoxFit.contain,
                            ),
                          )
                              : Image.asset(
                            AppAssets.imgMascotHand,
                            width: context.w(64),
                            height: context.h(64),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.h(30)),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: context.sp(48),
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                    letterSpacing: context.w(-1.2),
                  ),
                  children: [
                    TextSpan(text: "Giggle ", style: TextStyle(color: AppColors.textDarkGreen)),
                    TextSpan(text: "& ", style: TextStyle(color: AppColors.primaryPink)),
                    TextSpan(text: "Grow", style: TextStyle(color: AppColors.textDarkGreen)),
                  ],
                ),
              ),
              Text(
                "WHERE CURIOUS MINDS PLAY",
                style: TextStyle(
                  fontFamily: 'Be Vietnam Pro',
                  fontSize: context.sp(14),
                  fontWeight: FontWeight.w600,
                  letterSpacing: context.w(1.4),
                  color: AppColors.textNavy,
                ),
              ),

              SizedBox(height: context.h(80)),

              // 4. DOTS & LOADING CONTAINER
              SizedBox(
                width: context.w(185.88),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _dot(context, 16, AppColors.loadingBlue),
                        SizedBox(width: context.w(8)),
                        _dot(context, 16, AppColors.textNavy),
                        SizedBox(width: context.w(8)),
                        _dot(context, 16, AppColors.primaryPink),
                      ],
                    ),
                    SizedBox(height: context.h(16)),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(context.w(9999)),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: context.w(24), sigmaY: context.h(24)),
                        child: Container(
                          width: context.w(185.88),
                          height: context.h(56),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(context.w(9999)),
                          ),
                          child: Text(
                            "Loading...",
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w700,
                              fontSize: context.sp(24),
                              color: AppColors.textNavy,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 5. BOTTOM DECORATIVE BAR
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: context.w(390),
              height: context.h(128),
              decoration: BoxDecoration(
                color: AppColors.bgLightEmerald,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(context.w(80)),
                  topRight: Radius.circular(context.w(80)),
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: context.h(39),
                    left: context.w(-16.59),
                    child: Opacity(
                      opacity: 0.4,
                      child: SizedBox(
                        width: context.w(423.18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _navIcon(context, (iconUrls['pot_svg'] ?? '').toString().trim(), AppAssets.iconPot, 45, 50),
                            SizedBox(width: context.w(48)),
                            _navIcon(context, (iconUrls['car_svg'] ?? '').toString().trim(), AppAssets.iconCar, 52.44, 40, color: AppColors.accentGreen),
                            SizedBox(width: context.w(48)),
                            _navIcon(context, (iconUrls['bunny_svg'] ?? '').toString().trim(), AppAssets.iconBunny, 35, 50),
                            SizedBox(width: context.w(48)),
                            _navIcon(context, (iconUrls['paint_svg'] ?? '').toString().trim(), AppAssets.iconPaint, 50, 50),
                            SizedBox(width: context.w(48)),
                            _navIcon(
                              context,
                              (iconUrls['puzzle_svg'] ?? '').toString().trim(),
                              AppAssets.iconPuzzz,
                              48.75,
                              48.75,
                              color: AppColors.accentGreen,
                              isFifth: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(BuildContext context, double size, Color color) {
    return Container(
      width: context.w(size),
      height: context.w(size), // Force height to match context.w for a perfect round dot shape
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _navIcon(BuildContext context, String url, String assetPath, double w, double h, {Color? color, bool isFifth = false}) {
    return Opacity(
      opacity: isFifth ? 1.0 : (color == null ? 0.4 : 1.0),
      child: url.isNotEmpty
          ? SvgPicture.network(
        url,
        width: context.w(w),
        height: context.h(h),
        colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
        placeholderBuilder: (context) => SvgPicture.asset(
          assetPath,
          width: context.w(w),
          height: context.h(h),
          colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
        ),
      )
          : SvgPicture.asset(
        assetPath,
        width: context.w(w),
        height: context.h(h),
        colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
      ),
    );
  }
}