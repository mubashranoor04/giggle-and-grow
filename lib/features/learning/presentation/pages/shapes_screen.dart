import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- REMINDER: Replace with your exact project layout file path location ---
import 'package:finalproject/core/utils/size_extension.dart';

// --- Confirmed UI View Paths ---
import 'package:finalproject/features/onboarding/presentation/pages/first_screen.dart';
import 'package:finalproject/features/drawing/presentation/widgets/canvas_painter.dart';
import 'package:finalproject/features/learning/presentation/pages/learning_menu.dart';
import 'package:finalproject/features/stories/presentation/pages/stories_list_page.dart';

class ShapesScreen extends StatefulWidget {
  const ShapesScreen({super.key});

  @override
  State<ShapesScreen> createState() => _ShapesScreenState();
}

class _ShapesScreenState extends State<ShapesScreen> {
  // Global Database & Audio Interfaces Engine Hooks
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Framework Operations State Trackers
  bool _isLoading = true;
  String? _errorMessage;

  // Active Screen Layout Content Configuration Registries
  int _userStars = 50;
  final Map<String, String> _remoteAudioUrls = {};

  final int _selectedIndex = 1; // LEARN is the active tab instance identifier

  @override
  void initState() {
    super.initState();
    _loadRemoteShapesConfiguration();
  }

  /// Master Initialization Handshake extracting data matrices cleanly out of Firestore
  Future<void> _loadRemoteShapesConfiguration() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Fetch structural asset data directly matching your uploaded snapshot schema path
      DocumentSnapshot shapesSnapshot = await _firestore
          .collection('shapes')
          .doc('shapes_screen')
          .get();

      if (!shapesSnapshot.exists) {
        throw Exception("Target document 'shapes_screen' could not be resolved on backend server data-tree.");
      }

      final Map<String, dynamic> data = shapesSnapshot.data() as Map<String, dynamic>;

      // Safely populate internal map configurations using exact key strings from dashboard screenshot
      _remoteAudioUrls["TRIANGLE"] = data["triangleAudioUrl"] ?? "";
      _remoteAudioUrls["SQUARE"] = data["squareAudioUrl"] ?? "";
      _remoteAudioUrls["CIRCLE"] = data["circleAudioUrl"] ?? "";
      _remoteAudioUrls["STAR"] = data["starAudioUrl"] ?? "";

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to load network shapes parameters: ${e.toString()}";
        });
      }
    }
  }

  /// Stream remote media file payloads leveraging dynamic high-performance runtime targets
  void _playShapeSound(String shapeName) async {
    final String? streamingUrl = _remoteAudioUrls[shapeName.toUpperCase()];

    if (streamingUrl == null || streamingUrl.isEmpty) {
      debugPrint("Audio Stream Reference Path Missing on Server Registry for token: $shapeName");
      return;
    }

    try {
      await _audioPlayer.stop();
      // Using production streaming UrlSource matrices to pull your Cloudinary audio files
      await _audioPlayer.play(UrlSource(streamingUrl));
    } catch (e) {
      debugPrint("Remote Network Audio Playback Pipeline Exception: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FCE4),
      body: Stack(
        children: [
          Positioned.fill(
            child: _buildDynamicContentLayoutWrapper(),
          ),
          Positioned(top: 0, left: 0, right: 0, child: _buildTopBar()),
          Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomNav()),
        ],
      ),
    );
  }

  /// Structural router mapping loading state switches cleanly across interface frames
  Widget _buildDynamicContentLayoutWrapper() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF21FF31)),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.w(32)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off_rounded, color: Colors.orangeAccent, size: context.w(64)),
              SizedBox(height: context.h(16)),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: context.sp(14), color: Colors.black54),
              ),
              SizedBox(height: context.h(24)),
              ElevatedButton(
                onPressed: _loadRemoteShapesConfiguration,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD709),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.w(24), vertical: context.h(10)),
                  child: Text(
                    "Retry Engine Initialization",
                    style: TextStyle(color: const Color(0xFF6C5A00), fontWeight: FontWeight.w900, fontSize: context.sp(14)),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(context.w(24), context.h(160), context.w(24), context.h(120)),
      child: Column(
        children: [
          _buildInstructionHeader(),
          SizedBox(height: context.h(24)),
          _buildShapeCard("TRIANGLE", const Color(0xFFFFD709), Icons.change_history_rounded),
          SizedBox(height: context.h(20)),
          _buildShapeCard("SQUARE", const Color(0xFF9AE1FF), Icons.square_rounded),
          SizedBox(height: context.h(20)),
          _buildShapeCard("CIRCLE", const Color(0xFFFF9ECD), Icons.circle),
          SizedBox(height: context.h(20)),
          _buildShapeCard("STAR", const Color(0xFF21FF31), Icons.star_rounded),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: context.h(140),
      padding: EdgeInsets.only(
        left: context.w(20), right: context.w(20), bottom: context.h(20),
        top: MediaQuery.of(context).padding.top + context.h(5),
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFE2FFD5),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: context.w(45), height: context.w(45),
              decoration: const BoxDecoration(color: Color(0xFF21FF31), shape: BoxShape.circle),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/smileIcon.svg',
                  width: context.w(25),
                  colorFilter: const ColorFilter.mode(Color(0xFF6C5A00), BlendMode.srcIn),
                ),
              ),
            ),
          ),
          SizedBox(width: context.w(12)),
          Expanded(
            child: Text(
              "Giggle &\nGrow",
              style: TextStyle(height: 1.1, fontWeight: FontWeight.w900, fontSize: context.sp(24), color: const Color(0xFF6C5A00)),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: context.w(18), vertical: context.h(8)),
            decoration: BoxDecoration(color: const Color(0xFFFFD709), borderRadius: BorderRadius.circular(25)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("$_userStars", style: TextStyle(fontWeight: FontWeight.w900, fontSize: context.sp(20), color: const Color(0xFF6C5A00))),
                Text("⭐", style: TextStyle(fontSize: context.sp(14))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShapeCard(String label, Color color, IconData icon) {
    return GestureDetector(
      onTap: () => _playShapeSound(label),
      child: Container(
        width: double.infinity,
        height: context.h(300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: context.w(160), color: color),
            SizedBox(height: context.h(20)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: context.w(40), vertical: context.h(12)),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(25)),
              child: Text(
                "$label!",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: context.sp(18), color: const Color(0xFF6C5A00)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: context.h(100),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(40))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(0, "GAMES"),
          _navItem(1, "LEARN"),
          _navItem(2, "DRAW"),
          _navItem(3, "STORIES"),
        ],
      ),
    );
  }

  Widget _navItem(int idx, String label) {
    bool isSel = _selectedIndex == idx;
    return GestureDetector(
      onTap: () {
        if (isSel) return;

        Widget? nextScreen;
        if (idx == 0) {
          nextScreen = const FirstScreen();
        } else if (idx == 1) {
          nextScreen = const LearningMenu();
        } else if (idx == 2) {
          nextScreen = const DrawingCanvasScreen();
        } else if (idx == 3) {
          nextScreen = const StoriesListPage();
        }

        if (nextScreen != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => nextScreen!),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: context.w(16), vertical: context.h(8)),
        decoration: isSel ? BoxDecoration(color: const Color(0xFFFFD709), borderRadius: BorderRadius.circular(20)) : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              idx == 0 ? Icons.extension : idx == 1 ? Icons.school : idx == 2 ? Icons.palette : Icons.menu_book,
              color: isSel ? const Color(0xFF6C5A00) : Colors.blueGrey,
              size: context.w(24),
            ),
            Text(label, style: TextStyle(fontSize: context.sp(10), fontWeight: FontWeight.bold, color: isSel ? const Color(0xFF6C5A00) : Colors.blueGrey)),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionHeader() {
    return Container(
      padding: EdgeInsets.all(context.w(20)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        "Tap a shape to hear its name!",
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: context.sp(20), color: const Color(0xFF04647D)),
      ),
    );
  }
}