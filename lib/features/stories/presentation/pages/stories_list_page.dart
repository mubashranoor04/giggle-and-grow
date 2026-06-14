import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constant/colors.dart';
import '../../../../core/utils/size_extension.dart';
import 'package:finalproject/features/drawing/presentation/widgets/canvas_painter.dart';
import 'package:finalproject/features/onboarding/presentation/pages/first_screen.dart';
import 'package:finalproject/features/learning/presentation/pages/learning_menu.dart';
import '../../../dashboard/presentation/provider/score_provider.dart';
import 'story_reader_page.dart';

class StoriesListPage extends StatefulWidget {
  const StoriesListPage({super.key});

  @override
  State<StoriesListPage> createState() => _StoriesListPageState();
}

class _StoriesListPageState extends State<StoriesListPage> {
  int _selectedIndex = 3;

  // Local fallback mapping metadata linked directly to your dynamic Document IDs
  final Map<String, Map<String, String>> _storyMetadata = {
    "story_0": {"title": "The Brave Little Fox", "time": "8 MINS", "tag": "ADVENTURE"},
    "story_1": {"title": "A Day at the Beach", "time": "5 MINS", "tag": "FUN"},
    "story_2": {"title": "The Star’s Best Friend", "time": "12 MINS", "tag": "BEDTIME"},
    "story_3": {"title": "The Silly Rainbow", "time": "6 MINS", "tag": "FUNNY"},
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBarGreen,
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('dashboard_media').doc('ui_assets').get(),
        builder: (context, uiSnapshot) {
          if (uiSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.nextButtonGreen),
              ),
            );
          }

          final Map<String, dynamic> assets =
              (uiSnapshot.data?.data() as Map<String, dynamic>?) ?? {};

          return FutureBuilder<QuerySnapshot>(
            // Reads directly from your specified story_media collection!
            future: FirebaseFirestore.instance.collection('story_media').get(),
            builder: (context, mediaSnapshot) {
              if (mediaSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              }

              if (mediaSnapshot.hasError) {
                return Center(child: Text("Error loading media: ${mediaSnapshot.error}", style: const TextStyle(color: Colors.white)));
              }

              final List<QueryDocumentSnapshot> mediaDocs = mediaSnapshot.data?.docs ?? [];

              return Stack(
                children: [
                  SafeArea(
                    child: Column(
                      children: [
                        _buildAppBar(context, assets),
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.symmetric(horizontal: context.w(24)),
                            child: Column(
                              children: [
                                SizedBox(height: context.h(30)),
                                _buildHeaderContainer(context),
                                SizedBox(height: context.h(30)),

                                ...mediaDocs.map((doc) {
                                  final String docId = doc.id; // e.g., "story_0"
                                  final mediaData = doc.data() as Map<String, dynamic>;

                                  // Safely parse out numeric index digit from document identifier layout string
                                  final int storyId = int.tryParse(docId.replaceAll('story_', '')) ?? 0;

                                  // Get local styling details based on document key
                                  final meta = _storyMetadata[docId] ?? {
                                    "title": "Magical Adventure",
                                    "time": "5 MINS",
                                    "tag": "FUN"
                                  };

                                  return _buildStoryCard(context, storyId, meta, mediaData, assets);
                                }),

                                SizedBox(height: context.h(120)),
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
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Map<String, dynamic> assets) {
    return Container(
      width: double.infinity,
      height: context.h(90),
      padding: EdgeInsets.symmetric(horizontal: context.w(24)),
      decoration: BoxDecoration(
        color: AppColors.appBarGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(context.w(32)),
          bottomRight: Radius.circular(context.w(32)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: context.w(40),
            height: context.w(40),
            decoration: const BoxDecoration(color: AppColors.accentYellow, shape: BoxShape.circle),
            child: Center(
              child: assets['logo_icon'] != null
                  ? SvgPicture.network(assets['logo_icon'], width: context.w(22), height: context.w(22))
                  : const SizedBox.shrink(),
            ),
          ),
          SizedBox(width: context.w(12)),
          Text(
            "Giggle & Grow",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: context.sp(24),
              color: AppColors.navBarTextActive,
              fontFamily: 'Jakarta',
            ),
          ),
          const Spacer(),
          Consumer<ScoreProvider>(
            builder: (context, scoreProvider, child) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: context.w(16), vertical: context.h(8)),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(context.w(24))),
                child: Row(
                  children: [
                    Text(
                      "${scoreProvider.totalScore}",
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: context.sp(16), color: Colors.black),
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

  Widget _buildHeaderContainer(BuildContext context) {
    return Column(
      children: [
        Text(
          "Magical Stories",
          style: TextStyle(
            fontSize: context.sp(32),
            fontWeight: FontWeight.w900,
            color: AppColors.navBarTextActive,
            fontFamily: 'Jakarta',
          ),
        ),
        SizedBox(height: context.h(4)),
        Text(
          "Pick an adventure and start",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: context.sp(16),
            color: AppColors.tagGreenText,
            fontFamily: 'Jakarta',
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          "listening!",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: context.sp(16),
            color: AppColors.tagGreenText,
            fontFamily: 'Jakarta',
            fontWeight: FontWeight.w600,
          ),
        )
      ],
    );
  }

  Widget _buildStoryCard(BuildContext context, int storyId, Map<String, String> meta, Map<String, dynamic> mediaData, Map<String, dynamic> assets) {
    final String coverUrl = mediaData['cover_image'] ?? '';

    return Container(
      width: context.w(342),
      margin: EdgeInsets.only(bottom: context.h(32)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.w(34)),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(context.w(16), context.h(16), context.w(16), context.h(24)),
            child: SizedBox(
              width: context.w(310),
              height: context.h(193.75),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(context.w(24)),
                    child: coverUrl.isNotEmpty
                        ? Image.network(coverUrl, width: context.w(310), height: context.h(193.75), fit: BoxFit.cover)
                        : Container(color: Colors.grey[300], width: context.w(310), height: context.h(193.75)),
                  ),
                  Positioned(
                    left: context.w(230),
                    top: context.h(113.75),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => StoryReaderPage(storyId: storyId)),
                        );
                      },
                      child: Container(
                        width: context.w(64),
                        height: context.w(64),
                        decoration: const BoxDecoration(color: AppColors.accentYellow, shape: BoxShape.circle),
                        child: Center(
                          child: assets['play_button'] != null
                              ? SvgPicture.network(assets['play_button'], width: context.w(16.5), height: context.h(21))
                              : const Icon(Icons.play_arrow, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.w(24)),
            child: Text(
              meta['title']!,
              style: TextStyle(
                fontSize: context.sp(24),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF04647D),
                fontFamily: 'Jakarta',
                height: 1.33,
              ),
            ),
          ),
          SizedBox(height: context.h(12)),
          Padding(
            padding: EdgeInsets.only(left: context.w(24), bottom: context.h(24)),
            child: Row(
              children: [
                _buildTag(context, meta['time']!, AppColors.tagBlueBg, const Color(0xFF04647D)),
                SizedBox(width: context.w(8)),
                _buildTag(context, meta['tag']!, const Color(0x7F9EFF9A), const Color(0xFF006B0A)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(BuildContext context, String text, Color bg, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.w(12), vertical: context.h(4)),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(context.w(12))),
      child: Text(
        text,
        style: TextStyle(
          fontSize: context.sp(12),
          fontWeight: FontWeight.bold,
          color: textColor,
          fontFamily: 'BeVietnam',
          letterSpacing: 0.6,
        ),
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