import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:finalproject/core/constant/colors.dart';
import 'package:finalproject/core/constant/assets.dart';
import 'package:finalproject/core/utils/size_extension.dart';
import 'package:finalproject/features/drawing/presentation/widgets/canvas_painter.dart';
import 'package:finalproject/features/onboarding/presentation/pages/first_screen.dart';
import 'package:finalproject/features/stories/presentation/pages/stories_list_page.dart';
import 'package:finalproject/features/dashboard/presentation/provider/score_provider.dart';
import 'package:finalproject/features/learning/presentation/pages/learning_menu.dart';

class AnimalSoundsScreen extends StatefulWidget {
  const AnimalSoundsScreen({super.key});

  @override
  State<AnimalSoundsScreen> createState() => _AnimalSoundsScreenState();
}

class _AnimalSoundsScreenState extends State<AnimalSoundsScreen> {
  int currentRound = 1;
  int localScore = 0;
  bool showBear = true;
  String? selectedAnimal;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _bearTimer;

  // FIREBASE CLOUD MAPS
  Map<String, dynamic> audioUrls = {};
  Map<String, dynamic> imageUrls = {};
  Map<String, dynamic> iconUrls = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFirebaseAssets();
    _startBearTimer();
  }

  // Fetch all game assets from your unified Firestore collection
  Future<void> _fetchFirebaseAssets() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('learning_content')
          .doc('animal_sounds')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
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
      debugPrint("Error fetching cloud game assets: $e");
      setState(() => isLoading = false);
    }
  }

  void _startBearTimer() {
    _bearTimer?.cancel();
    setState(() => showBear = true);

    _bearTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => showBear = false);
      }
    });
  }

  @override
  void dispose() {
    _bearTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void playSound() async {
    String soundKey = 'cow';
    String fallbackSound = 'cow.mp3';

    if (currentRound == 2) { soundKey = 'dog'; fallbackSound = 'dog.mp3'; }
    if (currentRound == 3) { soundKey = 'lion'; fallbackSound = 'lion.mp3'; }
    if (currentRound == 4) { soundKey = 'tiger'; fallbackSound = 'tiger.mp3'; }
    if (currentRound == 5) { soundKey = 'whale'; fallbackSound = 'whale.mp3'; }

    final String cloudAudioUrl = (audioUrls[soundKey] ?? '').toString().trim();

    try {
      await _audioPlayer.stop(); // Kill any active sound before playing next
      if (cloudAudioUrl.isNotEmpty) {
        // Play dynamically from Cloudinary network URL fetched via Firebase
        await _audioPlayer.play(UrlSource(cloudAudioUrl));
      } else {
        // Fallback to local audio asset bundle if cloud string is missing
        await _audioPlayer.play(AssetSource('audio/$fallbackSound'));
      }
    } catch (e) {
      debugPrint("Error running audio track: $e");
      // Safety secondary local asset deployment fallback
      await _audioPlayer.play(AssetSource('audio/$fallbackSound'));
    }
  }

  void checkAnswer(String name) {
    bool correct = (currentRound == 1 && name == "Cow") ||
        (currentRound == 2 && name == "Dog") ||
        (currentRound == 3 && name == "Lion") ||
        (currentRound == 4 && name == "Tiger") ||
        (currentRound == 5 && name == "Whale");

    if (correct) {
      context.read<ScoreProvider>().addScore(10, 'animal_sounds');

      setState(() {
        selectedAnimal = name;
        localScore += 10;
      });

      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            if (currentRound < 5) {
              currentRound++;
              selectedAnimal = null;
              _startBearTimer();
            } else {
              _showCompletionDialog();
            }
          });
        }
      });
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Great Job! 🎉"),
        content: const Text("You matched all the animal sounds!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Awesome!"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Shows standard system progress loading ring while matching cloud references
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColors.bgSoftMint,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryPink),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgSoftMint,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _topNavbar(context),
                SizedBox(height: context.h(25)),
                _roundProgressIndicator(context),
                SizedBox(height: context.h(25)),
                _questionText(context),
                SizedBox(height: context.h(30)),
                _playSoundButton(context),
                SizedBox(height: context.h(40)),
                _animalGrid(context),
                SizedBox(height: context.h(140)),
              ],
            ),
          ),

          // SIDE BEAR & SPEECH BUBBLE
          if (showBear)
            Positioned(
              left: 0,
              bottom: context.h(220),
              child: SizedBox(
                width: context.w(320),
                height: context.h(150),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: context.w(-20),
                      bottom: 0,
                      child: Transform.rotate(
                        angle: 12 * (3.1415926535 / 180),
                        child: SizedBox(
                          width: context.w(128),
                          height: context.w(128), // Aspect lock
                          child: Image.asset(
                            "assets/images/sidebear.png",
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: context.w(95),
                      bottom: context.h(65),
                      child: Container(
                        width: context.w(125),
                        height: context.h(58),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          border: Border.all(
                            color: AppColors.accentGreen.withValues(alpha: 0.4),
                            width: context.w(1.5),
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(context.h(28)),
                            topRight: Radius.circular(context.h(28)),
                            bottomRight: Radius.circular(context.h(28)),
                            bottomLeft: Radius.circular(context.h(4)),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0x1A000000),
                              offset: Offset(0, context.h(10)),
                              blurRadius: context.h(20),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "You can do it!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Liberation Serif',
                            fontWeight: FontWeight.w700,
                            fontSize: context.sp(14),
                            color: AppColors.textNavy,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // BOTTOM NAVBAR
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CommonBottomNavBar(
              selectedIndex: 0,
              onTabSelected: (index) {
                if (index == 0) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const FirstScreen()),
                  );
                } else if (index == 1) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LearningMenu()),
                  );
                } else if (index == 2) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const DrawingCanvasScreen()),
                  );
                } else if (index == 3) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const StoriesListPage()),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _topNavbar(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      height: context.h(72),
      padding: EdgeInsets.symmetric(
        vertical: context.h(16),
        horizontal: context.w(24),
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFE2FFD5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/icons/ani.svg',
                  width: context.w(20),
                  height: context.h(19),
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF6C5A00),
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: context.w(8)),
                Flexible(
                  child: Text(
                    "Animal Sound Game",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                      fontSize: context.sp(20),
                      height: 28 / 20,
                      letterSpacing: context.w(-0.5),
                      color: const Color(0xFF003802),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Consumer<ScoreProvider>(
            builder: (context, scoreProvider, child) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: context.w(12), vertical: context.h(8)),
                decoration: BoxDecoration(
                  color: const Color(0xFFCAFFBB),
                  borderRadius: BorderRadius.circular(context.w(9999)),
                ),
                alignment: Alignment.center,
                child: Text(
                  "⭐ ${scoreProvider.totalScore}",
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: context.sp(16),
                    color: const Color(0xFF6C5A00),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _roundProgressIndicator(BuildContext context) {
    return Container(
      height: context.h(40),
      padding: EdgeInsets.symmetric(horizontal: context.w(24)),
      decoration: BoxDecoration(
        color: AppColors.bgLightEmerald,
        borderRadius: BorderRadius.circular(context.w(9999)),
        border: Border.all(
          color: AppColors.accentGreen.withValues(alpha: 0.20),
          width: context.w(2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: List.generate(5, (index) {
              final bool isActive = index == currentRound - 1;
              final bool isCompleted = index < currentRound - 1;

              Color dotColor = AppColors.activeDotGreen;
              if (isCompleted) dotColor = AppColors.textNavy;
              if (isActive) dotColor = AppColors.primaryYellow;

              return Container(
                margin: EdgeInsets.only(right: index == 4 ? 0 : context.w(8)),
                width: context.w(16),
                height: context.w(16),
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  boxShadow: isActive
                      ? [
                    BoxShadow(
                      color: const Color(0xFF6C5A00).withValues(alpha: 0.20),
                      offset: const Offset(0, 0),
                      spreadRadius: context.w(4),
                      blurRadius: 0,
                    )
                  ]
                      : null,
                ),
              );
            }),
          ),
          SizedBox(width: context.w(16)),
          Text(
            'ROUND $currentRound OF 5',
            style: TextStyle(
              fontFamily: 'LiberationSans',
              fontWeight: FontWeight.w700,
              fontSize: context.sp(14),
              letterSpacing: context.w(1.4),
              color: AppColors.textDarkGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _questionText(BuildContext context) {
    return SizedBox(
      width: context.w(301),
      height: context.h(60),
      child: Text(
        currentRound == 2 ? "Who says... \"WOOF!\"" : "Tap the animal that makes\nthis sound!",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: context.sp(24),
          fontWeight: FontWeight.w800,
          height: 30 / 24,
          color: AppColors.textDarkGreen,
        ),
      ),
    );
  }

  Widget _playSoundButton(BuildContext context) {
    return GestureDetector(
      onTap: playSound,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: context.w(128),
            height: context.w(128),
            decoration: BoxDecoration(
              color: AppColors.primaryYellow,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5B4B00),
                  offset: Offset(0, context.h(6)),
                  blurRadius: 0,
                )
              ],
            ),
            child: Center(
              child: SvgPicture.asset(
                "assets/icons/sound.svg",
                width: context.w(45),
                height: context.h(43.75),
                colorFilter: const ColorFilter.mode(Color(0xFF5B4B00), BlendMode.srcIn),
              ),
            ),
          ),
          Positioned(
            bottom: context.h(-10),
            child: Container(
              width: context.w(102.75),
              height: context.h(24),
              decoration: BoxDecoration(
                color: const Color(0xFF5B4B00),
                borderRadius: BorderRadius.circular(context.w(9999)),
              ),
              alignment: Alignment.center,
              child: Text(
                "PLAY SOUND",
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: context.sp(10),
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryYellow,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _animalGrid(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.w(20)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: _manualAnimalCard("1", context)),
              SizedBox(width: context.w(15)),
              Expanded(child: _manualAnimalCard("2", context))
            ],
          ),
          SizedBox(height: context.h(15)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: _manualAnimalCard("3", context)),
              SizedBox(width: context.w(15)),
              Expanded(child: _manualAnimalCard("4", context))
            ],
          ),
        ],
      ),
    );
  }

  Widget _manualAnimalCard(String pos, BuildContext context) {
    String img = "";
    String name = "";

    if (currentRound == 1) {
      if (pos == "1") { img = "cow1"; name = "Cow"; }
      else if (pos == "2") { img = "sheep1"; name = "Sheep"; }
      else if (pos == "3") { img = "pig1"; name = "Pig"; }
      else if (pos == "4") { img = "duck1"; name = "Duck"; }
    } else if (currentRound == 2) {
      if (pos == "1") { img = "mouse2"; name = "Mouse"; }
      else if (pos == "2") { img = "dog2"; name = "Dog"; }
      else if (pos == "3") { img = "cat2"; name = "Cat"; }
      else if (pos == "4") { img = "rabbit2"; name = "Rabbit"; }
    } else if (currentRound == 3) {
      if (pos == "1") { img = "lion3"; name = "Lion"; }
      else if (pos == "2") { img = "elephant3"; name = "Elephant"; }
      else if (pos == "3") { img = "monkey3"; name = "Monkey"; }
      else if (pos == "4") { img = "bird3"; name = "Bird"; }
    } else if (currentRound == 4) {
      if (pos == "1") { img = "tiger4"; name = "Tiger"; }
      else if (pos == "2") { img = "wolf4"; name = "Wolf"; }
      else if (pos == "3") { img = "snake4"; name = "Snake"; }
      else if (pos == "4") { img = "frog4"; name = "Frog"; }
    } else if (currentRound == 5) {
      if (pos == "1") { img = "whale5"; name = "Whale"; }
      else if (pos == "2") { img = "dolphin5"; name = "Dolphin"; }
      else if (pos == "3") { img = "octopus5"; name = "Octopus"; }
      else if (pos == "4") { img = "shark5"; name = "Shark"; }
    }

    bool isCorrect = selectedAnimal == name;
    final String cloudImgUrl = (imageUrls[img] ?? '').toString().trim();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () => checkAnswer(name),
          child: Container(
            height: context.h(207),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(context.w(48)),
              border: Border.all(
                  color: isCorrect ? AppColors.activeDotGreen : AppColors.white,
                  width: context.w(4)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textDarkGreen.withValues(alpha: 0.10),
                  blurRadius: 0,
                  spreadRadius: 0,
                  offset: Offset(0, context.h(8)),
                )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: context.w(131),
                  height: context.h(131),
                  decoration: BoxDecoration(
                    color: AppColors.bgLightEmerald,
                    borderRadius: BorderRadius.circular(context.w(32)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(context.w(32)),
                    child: cloudImgUrl.isNotEmpty
                        ? Image.network(
                      cloudImgUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        "assets/images/$img.png",
                        fit: BoxFit.cover,
                      ),
                    )
                        : Image.asset(
                      "assets/images/$img.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: context.h(12)),
                Text(name,
                    style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w700,
                        fontSize: context.sp(20),
                        color: AppColors.textDeepEmerald)),
              ],
            ),
          ),
        ),
        if (isCorrect)
          Positioned(
            top: context.h(-5),
            right: context.w(-5),
            child: Container(
              width: context.w(36),
              height: context.h(36),
              decoration: const BoxDecoration(
                  color: AppColors.activeDotGreen, shape: BoxShape.circle),
              child: const Icon(Icons.check, color: Colors.black, size: 20),
            ),
          ),
      ],
    );
  }
}

class CommonBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;

  const CommonBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.h(100),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(context.w(32))),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
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
    bool isSel = selectedIndex == idx;

    return GestureDetector(
      onTap: () => onTabSelected(idx),
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
                color: isSel
                    ? AppColors.navBarTextActive
                    : AppColors.navBarIconInactive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}