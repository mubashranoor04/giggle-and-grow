import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalproject/core/utils/size_extension.dart';
import 'package:provider/provider.dart';

import 'package:finalproject/features/learning/presentation/pages/alphabet_learning.dart';
import 'package:finalproject/features/learning/presentation/pages/number_learning_screen.dart';
import 'package:finalproject/features/learning/presentation/pages/shapes_screen.dart';

import 'package:finalproject/features/onboarding/presentation/pages/first_screen.dart';
import 'package:finalproject/features/drawing/presentation/widgets/canvas_painter.dart'; // Ensure DrawingCanvasScreen is inside or exported here
import 'package:finalproject/features/stories/presentation/pages/stories_list_page.dart';

import 'package:finalproject/features/dashboard/presentation/provider/score_provider.dart';

class LearningMenu extends StatefulWidget {
  const LearningMenu({super.key});

  @override
  State<LearningMenu> createState() => _LearningMenuState();
}

class _LearningMenuState extends State<LearningMenu> {
  Map<String, dynamic> imageUrls = {};
  String logoUrl = "";
  bool isLoading = true;

  // FALLBACK ASSETS
  final String defaultFoxUrl =
      "https://res.cloudinary.com/dlrdnshnx/image/upload/v1777746727/fox_cf8pdh.jpg";
  final String defaultStarsUrl =
      "https://res.cloudinary.com/dlrdnshnx/image/upload/v1777746684/stars_sqpmn5.jpg";

  @override
  void initState() {
    super.initState();
    _fetchFirebaseAssets();
  }

  // FETCH FIRESTORE DATA
  Future<void> _fetchFirebaseAssets() async {
    try {
      // 1. Fetch from learning_content/menu
      final menuDoc = await FirebaseFirestore.instance
          .collection('learning_content')
          .doc('menu')
          .get();

      // 2. Fetch from app_settings/icons
      final iconDoc = await FirebaseFirestore.instance
          .collection('app_settings')
          .doc('icons')
          .get();

      Map<String, dynamic> fetchedImages = {};
      String fetchedLogo = "";

      if (menuDoc.exists && menuDoc.data() != null) {
        final data = menuDoc.data()!;
        if (data['image_urls'] != null) {
          fetchedImages = Map<String, dynamic>.from(data['image_urls']);
        }
      }

      if (iconDoc.exists && iconDoc.data() != null) {
        final iconData = iconDoc.data()!;
        fetchedLogo = (iconData['logoUrl'] ?? "").toString();
      }

      // Single setState to apply data updates smoothly
      setState(() {
        imageUrls = fetchedImages;
        logoUrl = fetchedLogo;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("FIRESTORE FETCH ERROR: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color brandColor = Color(0xFF04647D);

    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFE2FFD5),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Safely assign image URLs or fallback to hardcoded strings
    final String foxUrl = (imageUrls['foxMascotUrl'] ?? defaultFoxUrl).toString().trim();
    final String starsUrl = (imageUrls['starsImageUrl'] ?? defaultStarsUrl).toString().trim();

    return Scaffold(
      backgroundColor: const Color(0xFFE2FFD5),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: EdgeInsets.fromLTRB(
                context.w(24),
                context.h(20),
                context.w(24),
                context.h(180),
              ),
              children: [
                _buildPopOutHeader(context),
                SizedBox(height: context.h(32)),
                Text(
                  "Let's Learn!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.sp(32),
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1B4D2E),
                  ),
                ),
                SizedBox(height: context.h(8)),
                Text(
                  "Pick a magical path to start your adventure today.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.sp(16),
                    color: const Color(0xFF1B4D2E),
                  ),
                ),
                SizedBox(height: context.h(32)),

                // ALPHABETS CARD
                _buildCard(
                  context: context,
                  title: "Alphabets",
                  subtitle: "Magical letters and sounds await!",
                  color: const Color(0xFFFFD709),
                  customIcon: _buildDarkIcon(
                    context,
                    "A",
                    const Color(0xFF453900),
                    isCircle: true,
                  ),
                  alignment: CrossAxisAlignment.start,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AlphabetLearningScreen(),
                      ),
                    );
                  },
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.w(24),
                        vertical: context.h(12),
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B5E00),
                        borderRadius: BorderRadius.circular(context.w(30)),
                      ),
                      child: Text(
                        "Play Now →",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: context.sp(14),
                        ),
                      ),
                    ),
                  ),
                ),

                // NUMBERS CARD
                _buildCard(
                  context: context,
                  title: "Numbers",
                  subtitle: "Count the stars and jump around!",
                  color: const Color(0xFF9AE1FF),
                  customIcon: _buildDarkIcon(
                    context,
                    "123",
                    const Color(0xFF04647D),
                    isCircle: false,
                  ),
                  alignment: CrossAxisAlignment.start,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NumbersLearningScreen(),
                      ),
                    );
                  },
                  child: Container(
                    height: context.h(120),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(context.w(24)),
                      image: DecorationImage(
                        image: NetworkImage(starsUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                // SHAPES CARD
                _buildCard(
                  context: context,
                  title: "Shapes",
                  subtitle: "Triangles, circles, and squares, oh my!",
                  color: const Color(0xFFFF8BC0),
                  alignment: CrossAxisAlignment.center,
                  height: 430.04,
                  isPinkCard: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ShapesScreen(),
                      ),
                    );
                  },
                  customIcon: Container(
                    height: context.h(140),
                    width: context.w(140),
                    decoration: BoxDecoration(
                      color: const Color(0xFFA61F69),
                      borderRadius: BorderRadius.circular(context.w(32)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: Offset(0, context.h(4)),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.crop_square,
                      color: Colors.white,
                      size: context.sp(80),
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundColor: const Color(0xFFA61F69),
                    radius: context.w(36),
                    child: Icon(
                      Icons.palette,
                      color: Colors.white,
                      size: context.sp(30),
                    ),
                  ),
                ),
              ],
            ),
            // FLOATING FOX MASCOT
            _buildFloatingMascot(context, foxUrl),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, brandColor),
    );
  }

  Widget _buildPopOutHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.w(12),
        vertical: context.h(10),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE2FFD5),
        borderRadius: BorderRadius.circular(context.w(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            offset: Offset(context.w(4), context.h(4)),
            blurRadius: 10,
          ),
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-4, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          logoUrl.isNotEmpty
              ? Image.network(
            logoUrl,
            height: context.h(34),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.face,
                color: const Color(0xFF6B5E00),
                size: context.sp(30),
              );
            },
          )
              : Icon(
            Icons.face,
            color: const Color(0xFF6B5E00),
            size: context.sp(30),
          ),
          SizedBox(width: context.w(8)),
          const Expanded(
            child: Text(
              "Giggle & Grow",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF453900),
              ),
            ),
          ),
          SizedBox(width: context.w(4)),
          _buildStarPill(context),
        ],
      ),
    );
  }

  Widget _buildStarPill(BuildContext context) {
    return Consumer<ScoreProvider>(
      builder: (context, scoreProvider, child) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.w(12),
            vertical: context.h(6),
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD709),
            borderRadius: BorderRadius.circular(context.w(50)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6B5E00).withValues(alpha: 0.2),
                blurRadius: 4,
                offset: Offset(0, context.h(2)),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${scoreProvider.totalScore}",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: context.sp(16),
                  color: const Color(0xFF453900),
                ),
              ),
              SizedBox(width: context.w(4)),
              Icon(
                Icons.star,
                color: Colors.white,
                size: context.sp(16),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDarkIcon(
      BuildContext context,
      String text,
      Color bgColor, {
        required bool isCircle,
      }) {
    return Container(
      height: context.h(70),
      width: context.w(70),
      decoration: BoxDecoration(
        color: bgColor,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(context.w(20)),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: Offset(0, context.h(4)),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: context.sp(20),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Color color,
    Widget? customIcon,
    double? height,
    bool isPinkCard = false,
    required CrossAxisAlignment alignment,
    required Widget child,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: height != null ? context.h(height) : null,
        margin: EdgeInsets.only(bottom: context.h(25)),
        padding: EdgeInsets.fromLTRB(
          context.w(32),
          context.h(25.66),
          context.w(32),
          context.h(32),
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(context.w(48)),
        ),
        child: Column(
          crossAxisAlignment: alignment,
          children: [
            customIcon ?? const SizedBox.shrink(),
            SizedBox(height: context.h(24)),
            Text(
              title,
              textAlign: alignment == CrossAxisAlignment.center
                  ? TextAlign.center
                  : TextAlign.left,
              style: TextStyle(
                fontSize: context.sp(isPinkCard ? 42 : 30),
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: context.h(4)),
            Text(
              subtitle,
              textAlign: alignment == CrossAxisAlignment.center
                  ? TextAlign.center
                  : TextAlign.left,
              style: TextStyle(
                fontSize: context.sp(isPinkCard ? 18 : 14),
                color: Colors.black.withValues(alpha: 0.54),
              ),
            ),
            height != null ? const Spacer() : SizedBox(height: context.h(20)),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingMascot(BuildContext context, String foxUrl) {
    return Positioned(
      bottom: context.h(20),
      right: context.w(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.w(12),
              vertical: context.h(6),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(context.w(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Text(
              "Hi Friend!",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: context.sp(12),
              ),
            ),
          ),
          SizedBox(height: context.h(8)),
          Image.network(
            foxUrl,
            height: context.h(90),
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return SizedBox(
                height: context.h(90),
                width: context.w(90),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              debugPrint("FOX IMAGE ERROR: $error");
              return Icon(
                Icons.pets,
                size: context.sp(50),
                color: Colors.orange,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, Color brandColor) {
    return Container(
      height: context.h(85),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.w(32)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(context, Icons.videogame_asset_outlined, "GAMES", 0, brandColor),
          _navItem(context, Icons.school, "LEARN", 1, brandColor),
          _navItem(context, Icons.palette_outlined, "DRAW", 2, brandColor),
          _navItem(context, Icons.menu_book_outlined, "STORIES", 3, brandColor),
        ],
      ),
    );
  }

  Widget _navItem(
      BuildContext context,
      IconData icon,
      String label,
      int index,
      Color brandColor,
      ) {
    bool isActive = index == 1;

    return GestureDetector(
      onTap: () {
        if (isActive) return;

        Widget nextScreen;
        switch (index) {
          case 0:
            nextScreen = const FirstScreen();
            break;
          case 2:
            nextScreen = const DrawingCanvasScreen();
            break;
          case 3:
            nextScreen = const StoriesListPage();
            break;
          default:
            return;
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => nextScreen),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive)
            Container(
              padding: EdgeInsets.all(context.w(10)),
              decoration: const BoxDecoration(
                color: Color(0xFFFFD709),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: brandColor,
                size: context.sp(24),
              ),
            )
          else
            Icon(
              icon,
              color: brandColor.withValues(alpha: 0.6),
              size: context.sp(24),
            ),
          SizedBox(height: context.h(4)),
          Text(
            label,
            style: TextStyle(
              fontSize: context.sp(10),
              color: brandColor,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}