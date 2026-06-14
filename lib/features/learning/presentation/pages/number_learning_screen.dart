import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../core/constant/assets2.dart';
import '../../../../../core/constant/colors.dart';
import '../../../../../core/constant/assets.dart';
import '../../../../core/utils/size_extension.dart';
import '../../../dashboard/presentation/provider/score_provider.dart';
import '../../../onboarding/presentation/pages/first_screen.dart';
import '../../../drawing/presentation/widgets/canvas_painter.dart'; // Updated package reference to match paint engine import mapping
import '../../../stories/presentation/pages/stories_list_page.dart';

class NumbersLearningScreen extends StatefulWidget {
  const NumbersLearningScreen({super.key});

  @override
  State<NumbersLearningScreen> createState() => _NumbersLearningScreenState();
}

class _NumbersLearningScreenState extends State<NumbersLearningScreen> {
  int currentNumber = 5;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Cloud data states
  Map<String, dynamic> audioUrls = {};
  Map<String, dynamic> imageUrls = {};
  Map<String, dynamic> iconUrls = {};
  bool isLoading = true;

  final Map<int, String> facts = {
    1: "The sun is 1 big bright star!",
    2: "You have 2 eyes to see the world!",
    3: "A triangle has 3 straight sides.",
    4: "A chair has 4 sturdy legs.",
    5: "You have 5 fingers on each hand!",
    6: "Insects have 6 legs to walk.",
    7: "There are 7 colors in a rainbow.",
    8: "An octopus has 8 wiggly arms!",
    9: "A tic-tac-toe grid has 9 squares.",
    10: "You have 10 little toes on your feet!",
  };

  @override
  void initState() {
    super.initState();
    fetchCloudAssets();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> fetchCloudAssets() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('learning_content')
          .doc('numbers')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;

        setState(() {
          audioUrls = Map<String, dynamic>.from(data['audio_urls'] ?? {});
          imageUrls = Map<String, dynamic>.from(data['image_urls'] ?? {});
          iconUrls = Map<String, dynamic>.from(data['icon_urls'] ?? {});
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching cloud assets: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> playCounting() async {
    for (int i = 1; i <= currentNumber; i++) {
      try {
        // String trimming ensures accidental database white-spaces never crash the loop
        final String url = (audioUrls[i.toString()] ?? '').toString().trim();

        // Stop any audio stream that is currently running before playing the next digit
        await _audioPlayer.stop();

        if (url.isNotEmpty) {
          await _audioPlayer.play(UrlSource(url));
        } else {
          await _audioPlayer.play(AssetSource('audio/$i.mp3'));
        }

        // Wait dynamically for the specific track stream to finish playing completely
        await _audioPlayer.onPlayerComplete.first;

        // Brief micro-delay for natural rhythmic spacing between numbers
        await Future.delayed(const Duration(milliseconds: 300));
      } catch (e) {
        debugPrint("Error playing audio for number $i: $e");
        // Safe continuous fallback sequence delay if connection stutters
        await Future.delayed(const Duration(milliseconds: 800));
      }
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

    final String didYouKnowImg = (imageUrls['did_you_know_hand'] ?? '').toString().trim();
    final String greatJobImg = (imageUrls['great_job_icon'] ?? '').toString().trim();

    return Scaffold(
      backgroundColor: AppColors.bgSoftMint,
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _topNavBar(context),
                SizedBox(height: context.h(15)),

                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(minHeight: context.h(500)),
                  margin: EdgeInsets.symmetric(horizontal: context.w(24)),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(context.w(48)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: context.w(20),
                        offset: Offset(0, context.h(10)),
                      )
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: context.h(-40),
                        right: context.w(-40),
                        child: Container(
                          width: context.w(192),
                          height: context.w(192), // Proportional aspect constraints
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFCAFFBB).withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: context.w(20)),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: context.h(40)),
                            Text(
                              "$currentNumber",
                              style: TextStyle(
                                fontSize: context.sp(160),
                                fontWeight: FontWeight.w900,
                                color: AppColors.textNavy,
                                height: 1.0,
                              ),
                            ),
                            SizedBox(height: context.h(20)),
                            _buildCustomPawLayout(context),
                            SizedBox(height: context.h(30)),
                            _countButton(context),
                            SizedBox(height: context.h(30)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: context.h(25)),
                _navigationButtons(context),
                SizedBox(height: context.h(25)),

                _infoCard(
                  context,
                  "Did you know?",
                  facts[currentNumber] ?? "",
                  AppColors.activeDotGreen,
                  didYouKnowImg,
                  fallbackAsset: AppAssets.imgDidYouKnowHand,
                  radius: 48,
                  padding: 24,
                ),

                SizedBox(height: context.h(15)),

                _infoCard(
                  context,
                  "Great Job!",
                  "You're becoming a math master!",
                  AppColors.primaryPink,
                  greatJobImg,
                  fallbackAsset: AppAssets.imgGreatJobIcon,
                  radius: 48,
                  padding: 24,
                ),
                SizedBox(height: context.h(120)),
              ],
            ),
          ),

          // --- FIXED SYNCED LAYOUT HEIGHT PROFILE NAVBAR ---
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

  Widget _infoCard(BuildContext context, String title, String sub, Color bg, String imgUrl,
      {required String fallbackAsset, double radius = 40, double padding = 20}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: context.w(24)),
      padding: EdgeInsets.all(context.w(padding)),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(context.w(radius)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: context.sp(18),
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDeepEmerald,
                  ),
                ),
                SizedBox(height: context.h(4)),
                Text(
                  sub,
                  style: TextStyle(
                    fontSize: context.sp(14),
                    color: AppColors.textDeepEmerald.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: context.w(10)),
          imgUrl.isNotEmpty
              ? Image.network(
            imgUrl,
            width: context.w(60),
            height: context.w(60), // Locked to match bounding width constraints cleanly
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Image.asset(fallbackAsset, width: context.w(60), height: context.w(60)),
          )
              : Image.asset(fallbackAsset, width: context.w(60), height: context.w(60), fit: BoxFit.contain),
        ],
      ),
    );
  }

  Widget _navigationButtons(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.w(24)),
      child: Row(
        children: [
          Expanded(
            child: _navBtn(context, "Back", Icons.arrow_back, AppColors.primaryBlue, AppColors.textNavy, () {
              if (currentNumber > 1) setState(() => currentNumber--);
            }),
          ),
          SizedBox(width: context.w(15)),
          Expanded(
            child: _navBtn(context, "Next", Icons.arrow_forward, AppColors.darkGold, AppColors.textDarkGreen, () {
              if (currentNumber < 10) setState(() => currentNumber++);
            }),
          ),
        ],
      ),
    );
  }

  Widget _navBtn(BuildContext context, String label, IconData icon, Color bg, Color txt, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: context.h(60),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(context.w(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, context.h(4)),
              blurRadius: context.w(4),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (label == "Back") Icon(icon, color: txt, size: context.sp(20)),
            if (label == "Back") SizedBox(width: context.w(8)),
            Text(label, style: TextStyle(color: txt, fontWeight: FontWeight.bold, fontSize: context.sp(18))),
            if (label == "Next") SizedBox(width: context.w(8)),
            if (label == "Next") Icon(icon, color: txt, size: context.sp(20)),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomPawLayout(BuildContext context) {
    List<Widget> rows = [];
    if (currentNumber == 5) {
      rows = [_pawRow(context, 3), SizedBox(height: context.h(10)), _pawRow(context, 2)];
    } else if (currentNumber == 10) {
      rows = [_pawRow(context, 4), SizedBox(height: context.h(8)), _pawRow(context, 3), SizedBox(height: context.h(8)), _pawRow(context, 3)];
    } else if (currentNumber <= 4) {
      rows = [_pawRow(context, currentNumber)];
    } else {
      rows = [_pawRow(context, (currentNumber / 2).ceil()), SizedBox(height: context.h(10)), _pawRow(context, (currentNumber / 2).floor())];
    }
    return Column(children: rows);
  }

  Widget _pawRow(BuildContext context, int count) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (index) => Flexible(child: _pawWidget(context)))
    );
  }

  Widget _pawWidget(BuildContext context) {
    final String pawUrl = (iconUrls['paww_svg'] ?? '').toString().trim();

    return Container(
      width: context.w(50),
      height: context.h(60),
      margin: EdgeInsets.symmetric(horizontal: context.w(4)),
      decoration: BoxDecoration(
          color: AppColors.primaryYellow,
          borderRadius: BorderRadius.circular(context.w(15)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C5A00),
              offset: Offset(0, context.h(3)),
            )
          ]
      ),
      child: Center(
        child: pawUrl.isNotEmpty
            ? SvgPicture.network(
          pawUrl,
          width: context.w(22),
          colorFilter: const ColorFilter.mode(Color(0xFF5C4033), BlendMode.srcIn),
          placeholderBuilder: (BuildContext context) => SvgPicture.asset(AppAssets.iconPaww, width: context.w(22), colorFilter: const ColorFilter.mode(Color(0xFF5C4033), BlendMode.srcIn)),
        )
            : SvgPicture.asset(AppAssets.iconPaww, width: context.w(22), colorFilter: const ColorFilter.mode(Color(0xFF5C4033), BlendMode.srcIn)),
      ),
    );
  }

  Widget _countButton(BuildContext context) {
    return GestureDetector(
      onTap: playCounting,
      child: Container(
        width: context.w(180),
        height: context.h(55),
        decoration: BoxDecoration(
          color: const Color(0xFFA62D77),
          borderRadius: BorderRadius.circular(context.w(30)),
        ),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.volume_up, color: Colors.white, size: context.sp(20)),
              SizedBox(width: context.w(8)),
              Text("Count!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: context.sp(18)))
            ]
        ),
      ),
    );
  }

  Widget _topNavBar(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE2FFD5),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(context.w(48))),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.w(24), vertical: context.h(16)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Giggle & Grow", style: TextStyle(fontWeight: FontWeight.w800, fontSize: context.sp(22), color: const Color(0xFF6C5A00))),
              Consumer<ScoreProvider>(
                builder: (context, scoreProvider, child) {
                  return Text("${scoreProvider.totalScore} ⭐", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.sp(16), color: const Color(0xFF6C5A00)));
                },
              ),
            ],
          ),
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
            blurRadius: context.w(10),
            offset: Offset(0, context.h(-2)),
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
    bool isSel = idx == 1;
    return GestureDetector(
      onTap: () {
        if (isSel) return;
        Widget nextScreen;
        switch (idx) {
          case 0: nextScreen = const FirstScreen(); break;
          case 2: nextScreen = const DrawingCanvasScreen(); break;
          case 3: nextScreen = const StoriesListPage(); break;
          default: return;
        }
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => nextScreen));
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
                fontFamily: 'Jakarta',
                color: isSel ? AppColors.navBarTextActive : AppColors.navBarIconInactive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}