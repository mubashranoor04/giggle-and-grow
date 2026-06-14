import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../core/constant/assets2.dart';
 // import 'package:giggleandgrow/constants/colors.dart';

class CommonBottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const CommonBottomNavBar({
    super.key,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.sizeOf(context).width / 390;
    final double sh = sw;

    return Align(
      alignment: Alignment.bottomCenter,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(48),
          topRight: Radius.circular(48),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            width: 390 * sw,
            height: 115 * sh,
            decoration: BoxDecoration(
              // The main navbar can still be translucent!
              color: Colors.white.withValues(alpha:0.6),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x99FFFFFF),
                  offset: Offset(0, -10),
                  blurRadius: 40,
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _navItem(context, 0, "GAMES", AppAssets.iconGames, sw, sh),
                _navItem(context, 1, "LEARN", AppAssets.iconLearn, sw, sh),
                _navItem(context, 2, "PAINT", AppAssets.iconDraw, sw, sh),
                _navItem(context, 3, "STORIES", AppAssets.iconStories, sw, sh),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, int idx, String label, String iconPath, double sw, double sh) {
    bool isSel = selectedIndex == idx;

    return GestureDetector(
      onTap: () {
        if (isSel) return;
        switch (idx) {
          case 0: Navigator.pushReplacementNamed(context, '/home'); break;
          case 1: Navigator.pushReplacementNamed(context, '/numbersLearning'); break;
          case 2: Navigator.pushReplacementNamed(context, '/draw'); break;
          case 3: Navigator.pushReplacementNamed(context, '/stories'); break;
        }
      },
      child: isSel
          ? _activeItem(label, iconPath, sw, sh)
          : _inactiveItem(label, iconPath, sw, sh),
    );
  }

  // --- NEW: THE PERFECTED LAYERED ACTIVE ITEM ---
  Widget _activeItem(String label, String iconPath, double sw, double sh) {
    const Color specShadowColor = Color(0x1A000000);

    return SizedBox(
      width: 95.33 * sw,
      height: 95.33 * sh, // Increased height to allow the "dip"
      child: Stack(
        alignment: Alignment.topCenter, // Keep yellow at the very top
        children: [
          // 1. THE WHITE BASE (Pushed down to only show at the bottom)
          Positioned(
            top: 10 * sh, // Shifting the white base DOWN
            child: Container(
              width: 95.33 * sw,
              height: 75 * sh,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(100 * sw), // Deep round bottom
                  bottomRight: Radius.circular(100 * sw), // Deep round bottom
                  topLeft: Radius.circular(30 * sw),      // Softer top
                  topRight: Radius.circular(30 * sw),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: specShadowColor,
                    offset: Offset(0, 4),
                    blurRadius: 6,
                    spreadRadius: -4,
                  ),
                  BoxShadow(
                    color: specShadowColor,
                    offset: Offset(0, 10),
                    blurRadius: 15,
                    spreadRadius: -3,
                  ),
                ],
              ),
            ),
          ),

          // 2. THE YELLOW CIRCLE (Flush at the top)
          Container(
            width: 86.66 * sw,
            height: 70.80 * sh,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD709),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40 * sw),
                bottomRight: Radius.circular(40 * sw),
                topLeft: Radius.circular(35 * sw), // Matches top curve
                topRight: Radius.circular(35 * sw),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  iconPath,
                  width: 24 * sw,
                  colorFilter: const ColorFilter.mode(Color(0xFF6C5A00), BlendMode.srcIn),
                ),
                const SizedBox(height: 1),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10 * sh,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF6C5A00),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- NEW: INACTIVE ITEM ---
  Widget _inactiveItem(String label, String iconPath, double sw, double sh) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          iconPath,
          width: 24 * sw,
          colorFilter: const ColorFilter.mode(Color(0xFF04647D), BlendMode.srcIn),
        ),
        SizedBox(height: 4 * sh),
        Text(
          label,
          style: TextStyle(
            fontSize: 11 * sh,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF04647D),
          ),
        ),
      ],
    );
  }
}