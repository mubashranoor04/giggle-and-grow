import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../core/constant/colors.dart';
import '../../../../../core/utils/size_extension.dart';
import '../../../onboarding/presentation/pages/onboarding_page.dart';
import '../../../stories/presentation/pages/stories_list_page.dart';
import 'package:finalproject/features/onboarding/presentation/pages/first_screen.dart';
import 'package:finalproject/features/drawing/presentation/widgets/canvas_painter.dart';
import 'package:finalproject/features/learning/presentation/pages/learning_menu.dart';
import '../provider/score_provider.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        // Fetches your remote UI asset URLs from Firestore
        future: FirebaseFirestore.instance.collection('dashboard_media').doc('ui_assets').get(),
        builder: (context, snapshot) {
          // Displays standard loader while request resolves asynchronously
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.nextButtonGreen),
              ),
            );
          }

          // Convert snapshot fields safely into a data Map configuration layer
          final Map<String, dynamic> assets =
              (snapshot.data?.data() as Map<String, dynamic>?) ?? {};

          final String bgUrl = assets['home_background'] ?? '';
          final String mascotUrl = assets['mascot_welcome'] ?? '';

          return Stack(
            children: [
              // 1. Core Background Base Canvas Frame (Network Driven)
              if (bgUrl.isNotEmpty)
                Positioned.fill(
                  child: Image.network(
                    bgUrl,
                    fit: BoxFit.cover,
                  ),
                ),

              SafeArea(
                top: false,
                child: Column(
                  children: [
                    _buildCustomAppBar(context, assets),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.only(bottom: context.h(160)),
                        child: Column(
                          children: [
                            SizedBox(height: context.h(20)),
                            if (mascotUrl.isNotEmpty)
                              Image.network(
                                mascotUrl,
                                height: context.h(140),
                              ),
                            _buildMascotGreeting(context),
                            SizedBox(height: context.h(30)),
                            _buildButtonGrid(context, assets),
                            SizedBox(height: context.h(40)),
                            _buildAdventureLevelCard(context),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomNavBar(assets),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context, Map<String, dynamic> assets) {
    return Container(
      width: double.infinity,
      height: context.h(100),
      padding: EdgeInsets.only(
        left: context.w(24),
        right: context.w(24),
        bottom: context.h(16),
        top: MediaQuery.of(context).padding.top + context.h(10),
      ),
      decoration: BoxDecoration(
        color: AppColors.appBarGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(context.w(32)),
          bottomRight: Radius.circular(context.w(32)),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const OnboardingPage()),
            ),
            child: Container(
              width: context.w(40),
              height: context.w(40),
              decoration: const BoxDecoration(color: AppColors.accentYellow, shape: BoxShape.circle),
              child: Center(
                child: assets['back_arrow'] != null
                    ? SvgPicture.network(assets['back_arrow'], width: context.w(20))
                    : const SizedBox.shrink(),
              ),
            ),
          ),
          SizedBox(width: context.w(12)),
          Text(
            "Playground",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: context.sp(24),
              color: AppColors.appBarTitleDark,
              fontFamily: 'Jakarta',
            ),
          ),
          const Spacer(),
          Consumer<ScoreProvider>(
            builder: (context, scoreProvider, child) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: context.w(16), vertical: context.h(8)),
                decoration: BoxDecoration(
                  color: AppColors.accentYellow,
                  borderRadius: BorderRadius.circular(context.w(24)),
                ),
                child: Row(
                  children: [
                    Text(
                      "${scoreProvider.totalScore}",
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: context.sp(16)),
                    ),
                    SizedBox(width: context.w(4)),
                    assets['gold_icon'] != null
                        ? SvgPicture.network(assets['gold_icon'], width: context.w(20))
                        : const SizedBox.shrink(),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMascotGreeting(BuildContext context) {
    return Column(
      children: [
        Text(
          "Hi there,\nLittle Explorer!",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: context.sp(36),
            fontWeight: FontWeight.w900,
            color: AppColors.appBarTitleDark,
            height: 1.1,
            fontFamily: 'Jakarta',
          ),
        ),
        SizedBox(height: context.h(4)),
        Text(
          "What do you want to play today?",
          style: TextStyle(
            fontSize: context.sp(18),
            color: AppColors.mascotSubText,
          ),
        ),
      ],
    );
  }

  Widget _buildButtonGrid(BuildContext context, Map<String, dynamic> assets) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.w(24)),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: context.h(24),
        crossAxisSpacing: context.w(24),
        children: [
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FirstScreen())),
            child: _build3DButton(
              context,
              "GAMES",
              AppColors.gamesMain,
              AppColors.gamesShadow,
              assets['btn_games'] ?? '',
              2,
              const Color(0x33FFFFFF),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LearningMenu())),
            child: _build3DButton(
              context,
              "LEARN",
              AppColors.learnMain,
              AppColors.learnShadow,
              assets['btn_learn'] ?? '',
              -2,
              const Color(0x33FFFFFF),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DrawingCanvasScreen())),
            child: _build3DButton(
              context,
              "DRAW",
              AppColors.drawMain,
              AppColors.drawShadow,
              assets['btn_draw'] ?? '',
              2,
              const Color(0x1A000000),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StoriesListPage())),
            child: _build3DButton(
              context,
              "STORIES",
              AppColors.storiesMain,
              AppColors.storiesShadow,
              assets['btn_stories'] ?? '',
              -2,
              const Color(0x66FFFFFF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DButton(BuildContext context, String title, Color topColor, Color shadowColor, String url, double rot, Color overlayColor) {
    return Transform.rotate(
      angle: rot * math.pi / 180,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: shadowColor,
              borderRadius: BorderRadius.circular(context.w(32)),
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: context.h(8)),
            decoration: BoxDecoration(
              color: topColor,
              borderRadius: BorderRadius.circular(context.w(32)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    width: context.w(80),
                    height: context.w(80),
                    decoration: BoxDecoration(color: overlayColor, shape: BoxShape.circle),
                    child: Center(
                      child: url.isNotEmpty
                          ? SvgPicture.network(url, width: context.w(40))
                          : const SizedBox.shrink(),
                    ),
                  ),
                ),
                SizedBox(height: context.h(16)),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: context.sp(24),
                    letterSpacing: 0.6,
                    fontFamily: 'Jakarta',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdventureLevelCard(BuildContext context) {
    return Container(
      width: context.w(342),
      padding: EdgeInsets.all(context.w(24)),
      decoration: BoxDecoration(
        color: AppColors.adventureCardBg,
        borderRadius: BorderRadius.circular(context.w(32)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "ADVENTURE LEVEL 3",
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.adventureProgressDark, fontSize: context.sp(14)),
              ),
              Text(
                "1 / 10",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.sp(14)),
              ),
            ],
          ),
          SizedBox(height: context.h(12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(10, (i) => Container(
              width: context.w(25),
              height: context.w(25),
              margin: EdgeInsets.symmetric(horizontal: context.w(2)),
              decoration: BoxDecoration(
                color: i == 0 ? AppColors.adventureProgressDark : AppColors.adventureProgressGreen,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0x1F000000), width: 0.5),
              ),
            )),
          )
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(Map<String, dynamic> assets) {
    return Container(
      height: context.h(100),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(context.w(32))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Using your exact Firestore collection key layouts (_blue and _brown)
          _navItem(0, "GAMES", assets['nav_games_blue'] ?? '', assets['nav_games_brown'] ?? ''),
          _navItem(1, "LEARN", assets['nav_learn_blue'] ?? '', assets['nav_learn_brown'] ?? ''),
          _navItem(2, "DRAW", assets['nav_draw_blue'] ?? '', assets['nav_draw_brown'] ?? ''),
          _navItem(3, "STORIES", assets['nav_stories_blue'] ?? '', assets['nav_stories_brown'] ?? ''),
        ],
      ),
    );
  }

  Widget _navItem(int idx, String label, String blueIconUrl, String brownIconUrl) {
    bool isSel = _selectedIndex == idx;
    String targetUrl = isSel ? brownIconUrl : blueIconUrl;

    return GestureDetector(
      onTap: () {
        if (idx == 0) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const FirstScreen()));
        } else if (idx == 1) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const LearningMenu()));
        } else if (idx == 2) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const DrawingCanvasScreen()));
        } else if (idx == 3) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const StoriesListPage()));
        } else {
          setState(() => _selectedIndex = idx);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: context.w(16), vertical: context.h(8)),
        decoration: isSel
            ? BoxDecoration(
          color: AppColors.accentYellow,
          borderRadius: BorderRadius.circular(context.w(20)),
        )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            targetUrl.isNotEmpty
                ? SvgPicture.network(targetUrl, width: context.w(24))
                : SizedBox(width: context.w(24), height: context.w(24)),
            SizedBox(height: context.h(4)),
            Text(
              label,
              style: TextStyle(
                fontSize: context.sp(10),
                fontWeight: FontWeight.bold,
                color: isSel ? AppColors.navBarTextActive : AppColors.navBarIconInactive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}