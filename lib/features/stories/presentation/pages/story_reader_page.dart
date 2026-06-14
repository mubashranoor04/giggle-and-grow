import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constant/colors.dart';
import '../../../../core/utils/size_extension.dart';
import '../../../dashboard/presentation/provider/score_provider.dart';

class StoryReaderPage extends StatefulWidget {
  final int storyId;
  const StoryReaderPage({super.key, required this.storyId});

  @override
  State<StoryReaderPage> createState() => _StoryReaderPageState();
}

class _StoryReaderPageState extends State<StoryReaderPage> {
  int _currentSlide = 0;

  // Local fallback text content exactly matching your story data sequences
  final Map<int, List<Map<String, String>>> _localStoryTexts = {
    0: [
      {"text": "A little fox wanted to explore the big forest."},
      {"text": "He walked far and saw tall trees and rivers."},
      {"text": "Suddenly, he heard a loud scary sound!"},
      {"text": "He stayed brave and followed the sound."},
      {"text": "It was just friendly birds—he smiled happily!"},
    ],
    1: [
      {"text": "A boy went to the beach on a sunny day."},
      {"text": "He built a big sandcastle by the shore."},
      {"text": "Waves came and splashed water everywhere!"},
      {"text": "He played with shells and chased tiny crabs."},
      {"text": "He went home tired but very happy."},
    ],
    2: [
      {"text": "A little star felt lonely in the sky."},
      {"text": "It looked down and saw a small child."},
      {"text": "Every night, they smiled at each other."},
      {"text": "They became best friends forever."},
      {"text": "The child slept peacefully under the star."},
    ],
    3: [
      {"text": "A rainbow loved to play funny tricks."},
      {"text": "It changed colors again and again!"},
      {"text": "It made the clouds laugh loudly."},
      {"text": "Rain turned into colorful drops!"},
      {"text": "Everyone laughed at the silly rainbow."},
    ],
  };

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> storySlidesData = _localStoryTexts[widget.storyId] ?? [
      {"text": "Once upon a time, a magical adventure began..."},
    ];

    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        // Fetch global UI icons (logo, cross, gold metrics) from Firestore
        future: FirebaseFirestore.instance.collection('dashboard_media').doc('ui_assets').get(),
        builder: (context, uiSnapshot) {
          if (uiSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final Map<String, dynamic> assets =
              (uiSnapshot.data?.data() as Map<String, dynamic>?) ?? {};

          return FutureBuilder<DocumentSnapshot>(
            // Fetch story background canvas images from Firestore
            future: FirebaseFirestore.instance.collection('story_media').doc('story_${widget.storyId}').get(),
            builder: (context, mediaSnapshot) {
              if (mediaSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.nextButtonGreen));
              }

              if (!mediaSnapshot.hasData || !mediaSnapshot.data!.exists) {
                return const Center(child: Text("Story media folder not found in Firestore.", style: TextStyle(color: Colors.black)));
              }

              final Map<String, dynamic> mediaData = (mediaSnapshot.data?.data() as Map<String, dynamic>?) ?? {};
              final List<dynamic> imageSlides = mediaData['pages'] ?? [];

              int totalSlides = imageSlides.length;
              if (totalSlides == 0) {
                return const Center(child: Text("This story has no image pages yet.", style: TextStyle(color: Colors.black)));
              }

              final String currentBgUrl = imageSlides[_currentSlide] ?? '';
              final String currentText = _currentSlide < storySlidesData.length
                  ? storySlidesData[_currentSlide]['text'] ?? "Flip the page to see what happens next!"
                  : "Flip the page to see what happens next!";

              return Stack(
                children: [
                  // Full-screen image layer loaded dynamically via Firestore URL string array
                  if (currentBgUrl.isNotEmpty)
                    Positioned.fill(
                      child: Image.network(
                        currentBgUrl,
                        fit: BoxFit.cover,
                      ),
                    ),

                  // Header Bar overlay container
                  Positioned(
                    top: 0, left: 0, right: 0,
                    child: Container(
                      height: context.h(125),
                      padding: EdgeInsets.only(top: context.h(40), left: context.w(16), right: context.w(16)),
                      decoration: BoxDecoration(
                        color: AppColors.appBarGreen,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(context.w(40)),
                          bottomRight: Radius.circular(context.w(40)),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: context.w(44), height: context.w(44),
                            decoration: const BoxDecoration(color: AppColors.accentYellow, shape: BoxShape.circle),
                            child: Center(
                              child: assets['logo_icon'] != null
                                  ? SvgPicture.network(assets['logo_icon'], width: context.w(24))
                                  : const SizedBox.shrink(),
                            ),
                          ),
                          SizedBox(width: context.w(12)),
                          Text(
                              "Giggle &\nGrow",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: context.sp(22),
                                color: AppColors.navBarTextActive,
                                fontFamily: 'Jakarta',
                                height: 1.1,
                              )
                          ),
                          const Spacer(),
                          Consumer<ScoreProvider>(
                            builder: (context, scoreProvider, child) {
                              return Container(
                                width: context.w(65), height: context.w(65),
                                decoration: const BoxDecoration(
                                  color: Color(0xB3FFFFFF),
                                  shape: BoxShape.circle,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${scoreProvider.totalScore}",
                                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: context.sp(16), color: Colors.black),
                                    ),
                                    SizedBox(height: context.h(2)),
                                    assets['gold_icon'] != null
                                        ? SvgPicture.network(assets['gold_icon'], width: context.w(20))
                                        : const SizedBox.shrink(),
                                  ],
                                ),
                              );
                            },
                          ),
                          SizedBox(width: context.w(12)),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: context.w(48), height: context.w(48),
                              decoration: const BoxDecoration(color: AppColors.exitCircleRed, shape: BoxShape.circle),
                              child: Center(
                                child: assets['cross_button'] != null
                                    ? SvgPicture.network(assets['cross_button'], width: context.w(16))
                                    : const Icon(Icons.close, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  _buildNavButton(context, left: context.w(20), isForward: false, totalSlides: totalSlides),
                  _buildNavButton(context, right: context.w(20), isForward: true, totalSlides: totalSlides),

                  // Subtitles / Story Dialogue Overlay Box
                  Positioned(
                    bottom: context.h(40), left: context.w(24), right: context.w(24),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: context.w(24), vertical: context.h(32)),
                          decoration: BoxDecoration(
                            color: const Color(0xA6FFFFFF),
                            borderRadius: BorderRadius.circular(context.w(40)),
                            border: Border.all(color: const Color(0x80FFFFFF), width: 1),
                          ),
                          child: Text(
                            currentText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Jakarta',
                              fontWeight: FontWeight.bold,
                              fontSize: context.sp(22),
                              color: AppColors.storyTextDark,
                              height: 1.4,
                            ),
                          ),
                        ),
                        SizedBox(height: context.h(30)),
                        _buildWaveIndicators(totalSlides),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, {double? left, double? right, required bool isForward, required int totalSlides}) {
    bool canMove = isForward ? _currentSlide < (totalSlides - 1) : _currentSlide > 0;
    return Positioned(
      left: left, right: right, top: context.h(410),
      child: GestureDetector(
        onTap: () {
          if (canMove) setState(() => isForward ? _currentSlide++ : _currentSlide--);
        },
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: canMove ? 1.0 : 0.4,
          child: Container(
            width: context.w(64), height: context.w(64),
            decoration: BoxDecoration(
              color: isForward ? AppColors.accentYellow : const Color(0xFF04647D),
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 4))
              ],
            ),
            child: Icon(
              isForward ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: context.w(28),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWaveIndicators(int totalSlides) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSlides, (index) {
        bool isCurrent = _currentSlide == index;
        bool isPast = index < _currentSlide;
        double yOffset = (index == 3) ? context.h(-8.0) : 0.0;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: context.w(6)),
          child: Transform.translate(
            offset: Offset(0, yOffset),
            child: Container(
              width: isCurrent ? context.w(20) : context.w(14),
              height: isCurrent ? context.w(20) : context.w(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCurrent
                    ? const Color(0xFF00FF00)
                    : (isPast ? const Color(0xFF04647D) : const Color(0xFFAED59E)),
                border: isCurrent ? Border.all(color: Colors.white, width: 2) : null,
              ),
            ),
          ),
        );
      }),
    );
  }
}