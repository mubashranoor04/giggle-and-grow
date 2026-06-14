import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../core/constant/assets2.dart';
import '../../../../../core/constant/colors.dart';
import '../../../../../core/constant/assets.dart';
import '../../../../core/utils/size_extension.dart';
import '../../../dashboard/presentation/pages/home_dashboard.dart';
import '../../../drawing/presentation/widgets/canvas_painter.dart';
import '../../../games/presentation/pages/color_match.dart';
import '../../../games/presentation/pages/memory_match_screen.dart';
import '../../../games/presentation/pages/sun_puzzle_game.dart';
import '../../../learning/presentation/pages/animals_sounds.dart';
import '../../../learning/presentation/pages/learning_menu.dart';
import '../../../stories/presentation/pages/stories_list_page.dart';
import '../../../dashboard/presentation/provider/score_provider.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  // FIREBASE CLOUD MAP FOR MENU IMAGES
  Map<String, dynamic> menuImageUrls = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFirebaseMenuAssets();
  }

  // Fetch menu assets from your unified Firestore document
  Future<void> _fetchFirebaseMenuAssets() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('learning_content')
          .doc('menu')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        setState(() {
          menuImageUrls = Map<String, dynamic>.from(data['image_urls'] ?? {});
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching cloud menu assets: $e");
      setState(() => isLoading = false);
    }
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

    final String bulbUrl = (menuImageUrls['bulb'] ?? '').toString().trim();

    return Scaffold(
      backgroundColor: AppColors.bgSoftMint,
      body: Stack(
        children: [
          // 1. SCROLLABLE CONTENT
          Column(
            children: [
              // --- TOP NAVBAR ---
              Container(
                width: double.infinity,
                height: context.h(110),
                padding: EdgeInsets.fromLTRB(context.w(24), 0, context.w(24), context.h(16)),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2FFD5),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(context.w(48)),
                    bottomRight: Radius.circular(context.w(48)),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromRGBO(0, 56, 2, 0.1),
                      offset: Offset(0, context.h(10)),
                      blurRadius: context.h(30),
                    )
                  ],
                ),
                child: SafeArea(
                  bottom: false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => const HomeDashboard()),
                                    (route) => false,
                              );
                            },
                            child: Container(
                              width: context.w(48),
                              height: context.w(48), // Set to match width constraints for a perfect circle aspect ratio
                              decoration: const BoxDecoration(
                                color: Color(0xFFCAFFBB),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(Icons.arrow_back_ios_new,
                                    size: context.sp(18), color: const Color(0xFF5C6B1F)),
                              ),
                            ),
                          ),
                          SizedBox(width: context.w(12)),
                          Text(
                            "Playground",
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w800,
                              fontSize: context.sp(24),
                              color: AppColors.textDeepEmerald,
                              letterSpacing: context.w(-0.6),
                            ),
                          ),
                        ],
                      ),
                      // Real-time Score Container with Dynamic Text Overflow Safety
                      Consumer<ScoreProvider>(
                        builder: (context, scoreProvider, child) {
                          return Container(
                            height: context.h(40),
                            constraints: BoxConstraints(minWidth: context.w(85.7)),
                            padding: EdgeInsets.symmetric(horizontal: context.w(12)),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD709),
                              borderRadius: BorderRadius.circular(context.w(9999)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "${scoreProvider.totalScore}",
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontWeight: FontWeight.w900,
                                    fontSize: context.sp(16),
                                    color: const Color(0xFF5B4B00),
                                  ),
                                ),
                                SizedBox(width: context.w(6)),
                                Icon(Icons.star,
                                    size: context.sp(16), color: const Color(0xFF5B4B00)),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(context.w(24), context.h(30), context.w(24), context.h(160)),
                  children: [
                    Text(
                      "Pick a Game!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: context.sp(48),
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDeepEmerald,
                        height: 1.0,
                        letterSpacing: context.w(-1.2),
                      ),
                    ),
                    SizedBox(height: context.h(8)),
                    Center(
                      child: Container(
                        width: context.w(128),
                        height: context.h(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(context.w(9999)),
                        ),
                      ),
                    ),
                    SizedBox(height: context.h(48)),

                    _gameCard(
                      context,
                      title: "Memory Match",
                      desc: "Find all the hidden\npairs of cards!",
                      iconPath: AppAssets.iconMemory,
                      cloudImgKey: "memory_match_main",
                      fallbackImgPath: AppAssets.imgMemoryMatch,
                      borderColor: AppColors.accentGreen,
                      iconBg: AppColors.loadingBlue,
                      iconWidth: 66.73,
                      titleColor: AppColors.textDarkGreen,
                      descColor: const Color(0xFF006B0A),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MemoryGameBoard())),
                    ),
                    _gameCard(
                      context,
                      title: "Color Match",
                      desc: "Match the paint splashes to the canvas!",
                      iconPath: AppAssets.iconCol,
                      cloudImgKey: "color_match_main",
                      fallbackImgPath: AppAssets.imgColorMatch,
                      borderColor: AppColors.primaryPink,
                      iconBg: AppColors.primaryPink,
                      iconWidth: 58.31,
                      titleColor: AppColors.textDeepEmerald,
                      descColor: const Color(0xFF006B0A),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ColorMatchScreen())),
                    ),
                    _gameCard(
                      context,
                      title: "Puzzle Time",
                      desc: "Snap the pieces together to see the picture!",
                      iconPath: AppAssets.iconPuzz,
                      cloudImgKey: "puzzle_time_1",
                      fallbackImgPath: AppAssets.imgPuzzleTime,
                      borderColor: AppColors.primaryYellow,
                      iconBg: AppColors.primaryYellow,
                      iconWidth: 54.03,
                      titleColor: AppColors.textDarkGreen,
                      descColor: const Color(0xFF006B0A),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SunPuzzleGame())),
                      customHeight: 396,
                    ),
                    _gameCard(
                      context,
                      title: "Animal Sounds",
                      desc: "Roar like a lion or chirp like a bird!",
                      iconPath: AppAssets.iconAni,
                      cloudImgKey: "animal_sounds_1",
                      fallbackImgPath: AppAssets.imgAnimalSounds,
                      borderColor: AppColors.activeDotGreen,
                      iconBg: AppColors.activeDotGreen,
                      iconWidth: 66.66,
                      titleColor: AppColors.textDarkGreen,
                      descColor: const Color(0xFF006B0A),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                              const AnimalSoundsScreen())),
                    ),

                    // Tip Box
                    Transform.rotate(
                      angle: -0.01745,
                      child: DottedBorder(
                        color: AppColors.primaryCyan.withValues(alpha: 0.3),
                        strokeWidth: context.w(4),
                        dashPattern: [context.w(8), context.w(4)],
                        borderType: BorderType.RRect,
                        radius: Radius.circular(context.w(48)),
                        child: Container(
                          width: context.w(342),
                          height: context.h(157.03),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            borderRadius: BorderRadius.circular(context.w(48)),
                          ),
                          padding: EdgeInsets.all(context.w(32)),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(context.w(8)),
                                child: bulbUrl.isNotEmpty
                                    ? Image.network(
                                  bulbUrl,
                                  width: context.w(45),
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset(AppAssets.imgBulb, width: context.w(45)),
                                )
                                    : Image.asset(AppAssets.imgBulb, width: context.w(45)),
                              ),
                              SizedBox(width: context.w(24)),
                              Expanded(
                                child: Text(
                                  "Tip: Finish any game to earn stars and unlock new cool stickers!",
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: context.sp(16),
                                    color: AppColors.textNavy,
                                    fontWeight: FontWeight.w700,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // --- GLOBAL BOTTOM NAVBAR ---
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildIntegratedNavbar(context),
          ),
        ],
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _gameCard(BuildContext context,
      {required String title,
        required String desc,
        required String iconPath,
        required String cloudImgKey,
        required String fallbackImgPath,
        required Color borderColor,
        required Color iconBg,
        required double iconWidth,
        required VoidCallback onTap,
        double customHeight = 392,
        required Color titleColor,
        required Color descColor}) {
    final String cloudImgUrl = (menuImageUrls[cloudImgKey] ?? '').toString().trim();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: context.w(342),
        height: context.h(customHeight),
        margin: EdgeInsets.only(bottom: context.h(30)),
        padding: EdgeInsets.all(context.w(32)),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(context.w(48)),
          border: Border.all(color: borderColor, width: context.w(4)),
          boxShadow: [
            BoxShadow(
                color: AppColors.shadowGreen,
                offset: Offset(0, context.h(8)),
                blurRadius: 0)
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: context.w(iconWidth),
                  height: context.w(iconWidth), // Force square constraints for stable aspect lock across layouts
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(context.w(32)),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.shadowBlack,
                          offset: Offset(0, context.h(6)),
                          blurRadius: 0)
                    ],
                  ),
                  child: Center(
                    child: SvgPicture.asset(iconPath,
                        width: context.w(iconWidth * 0.6)),
                  ),
                ),
                SizedBox(width: context.w(15)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: context.sp(24),
                              fontWeight: FontWeight.w800,
                              color: titleColor)),
                      SizedBox(height: context.h(8)),
                      Text(desc,
                          style: TextStyle(
                              fontFamily: 'Be Vietnam Pro',
                              fontSize: context.sp(16),
                              color: descColor)),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              width: context.w(270),
              height: context.h(192),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(context.w(25)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(context.w(25)),
                child: cloudImgUrl.isNotEmpty
                    ? Image.network(
                  cloudImgUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    fallbackImgPath,
                    fit: BoxFit.cover,
                  ),
                )
                    : Image.asset(
                  fallbackImgPath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntegratedNavbar(BuildContext context) {
    return Container(
      height: context.h(100),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(context.w(32))),
        boxShadow: [
          BoxShadow(
              color: Colors.black12,
              blurRadius: context.h(10),
              offset: Offset(0, context.h(-2))
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(context, 0, "GAMES", Assets.gamesBlueIcon, Assets.gamesBrownIcon),
          _navItem(context, 1, "LEARN", Assets.learnBlueIcon, Assets.learnBrownIcon),
          _navItem(context, 2, "DRAW", Assets.drawBlueIcon, Assets.drawBrownIcon),
          _navItem(context, 3, "STORIES", Assets.storiesBlueIcon, Assets.storiesBrownIcon),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, int idx, String label, String blueIcon, String brownIcon) {
    bool isSel = idx == 0;

    return GestureDetector(
      onTap: () {
        if (isSel) return;

        switch (idx) {
          case 0:
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const FirstScreen())
            );
            break;
          case 1:
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LearningMenu())
            );
            break;
          case 2:
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const DrawingCanvasScreen())
            );
            break;
          case 3:
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const StoriesListPage())
            );
            break;
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: context.w(16), vertical: context.h(8)),
        decoration: isSel
            ? BoxDecoration(
            color: AppColors.accentYellow,
            borderRadius: BorderRadius.circular(context.h(20)))
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(isSel ? brownIcon : blueIcon, width: context.w(24)),
            SizedBox(height: context.h(4)),
            Text(
              label,
              style: TextStyle(
                fontSize: context.sp(10),
                fontWeight: FontWeight.bold,
                fontFamily: 'Plus Jakarta Sans',
                color: isSel ? AppColors.navBarTextActive : AppColors.navBarIconInactive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}