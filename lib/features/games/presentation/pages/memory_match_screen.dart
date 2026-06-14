import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- REMINDER: Verify this exact extension file layout path points to its correct home location ---
import 'package:finalproject/core/utils/size_extension.dart';

// --- FIXED Navigation Imports ---
import 'package:finalproject/features/onboarding/presentation/pages/first_screen.dart';
import 'package:finalproject/features/learning/presentation/pages/learning_menu.dart';
import 'package:finalproject/features/stories/presentation/pages/stories_list_page.dart';
import 'package:finalproject/features/drawing/presentation/widgets/canvas_painter.dart';

class MemoryGameBoard extends StatefulWidget {
  const MemoryGameBoard({super.key});

  @override
  State<MemoryGameBoard> createState() => _MemoryGameBoardState();
}

class _MemoryGameBoardState extends State<MemoryGameBoard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = true;
  String? _errorMessage;

  // Network asset string fetched directly from your document
  String? _smileIconUrl;

  // Localized UI text configurations (No longer fetched from Firestore)
  final String _levelLabel = "LEVEL 1: ANIMAL FRIENDS";
  final String _mainTitle = "Match the Pairs!";

  int _userStars = 50; // Set to match your design layout default precisely
  int _secondsRemaining = 45;
  final int _totalDuration = 45;

  // Local game assets pool configuration
  List<String> _icons = [];
  List<bool> _cardFlipped = [];
  final List<int> _selectedIndices = [];
  bool _isProcessing = false;
  final int _selectedIndex = 0;

  Timer? _timer;
  bool _gameEnded = false;

  @override
  void initState() {
    super.initState();
    _loadGameConfiguration();
  }

  /// Pulls ONLY the icon image link from the 'memory_match' document
  Future<void> _loadGameConfiguration() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _gameEnded = false;
        _selectedIndices.clear();
        _isProcessing = false;
        _secondsRemaining = _totalDuration;
      });

      // 1. Fetches only your asset setup document from mm_game
      DocumentSnapshot assetSnapshot = await _firestore
          .collection('mm_game')
          .doc('memory_match')
          .get();

      if (assetSnapshot.exists) {
        Map<String, dynamic> data = assetSnapshot.data() as Map<String, dynamic>;
        _smileIconUrl = data['smileIconUrl'];
      }

      // 2. Build local gameplay pairs completely on the device client side
      List<String> localPool = ["🐶", "🐻", "🐱", "🐹", "🦁", "🐰", "🦊", "🐨"];
      _icons = [...localPool, ...localPool];
      _icons.shuffle();

      _cardFlipped = List.generate(_icons.length, (index) => false);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _startTimer();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to load icon parameters: ${e.toString()}";
        });
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
        _endGame(false);
      }
    });
  }

  void _endGame(bool won) {
    if (_gameEnded) return;
    setState(() => _gameEnded = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.w(20))),
        title: Text(
          won ? "You Win! 🎉" : "Time's Up! ⏰",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.sp(22)),
        ),
        content: Text(
          won ? "Great job matching all the pairs!" : "Better luck next time! Let's try again.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: context.sp(16)),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _loadGameConfiguration();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF21FF31),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: EdgeInsets.symmetric(horizontal: context.w(24), vertical: context.h(10)),
            ),
            child: Text("Play Again", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: context.sp(14))),
          ),
        ],
      ),
    );
  }

  void _handleTap(int index) {
    if (_isProcessing || _cardFlipped[index] || _gameEnded) return;

    setState(() {
      _cardFlipped[index] = true;
      _selectedIndices.add(index);
    });

    if (_selectedIndices.length == 2) {
      _isProcessing = true;

      if (_icons[_selectedIndices[0]] != _icons[_selectedIndices[1]]) {
        Timer(const Duration(milliseconds: 600), () {
          if (mounted) {
            setState(() {
              _cardFlipped[_selectedIndices[0]] = false;
              _cardFlipped[_selectedIndices[1]] = false;
              _selectedIndices.clear();
              _isProcessing = false;
            });
          }
        });
      } else {
        _selectedIndices.clear();
        _isProcessing = false;

        if (_cardFlipped.every((flipped) => flipped)) {
          _timer?.cancel();
          _endGame(true);
        }
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FCE4),
      body: _buildScreenBodyHierarchy(),
    );
  }

  Widget _buildScreenBodyHierarchy() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF21FF31)),
          strokeWidth: context.w(4),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(context.w(24)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: context.w(60)),
              SizedBox(height: context.h(16)),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: context.sp(16), color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: context.h(24)),
              ElevatedButton(
                onPressed: _loadGameConfiguration,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF21FF31)),
                child: Text("Try Again", style: TextStyle(color: Colors.black, fontSize: context.sp(14))),
              )
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        _buildPartnerAppBar(),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: context.h(16)),
                _buildLevelLabel(),
                SizedBox(height: context.h(12)),
                _buildMainTitle(),
                SizedBox(height: context.h(16)),
                _build4x4Grid(),
                SizedBox(height: context.h(20)),
                _buildTimerSection(),
                SizedBox(height: context.h(40)),
              ],
            ),
          ),
        ),
        _buildPartnerBottomNav(),
      ],
    );
  }

  Widget _buildPartnerAppBar() {
    return Container(
      width: double.infinity,
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: context.w(45), height: context.w(45),
              decoration: const BoxDecoration(color: Color(0xFF21FF31), shape: BoxShape.circle),
              child: Icon(Icons.arrow_back, color: Colors.black, size: context.w(28)),
            ),
          ),
          SizedBox(width: context.w(12)),

          // Fallback loading configuration system prevents crashing if image URL is processing
          _smileIconUrl != null
              ? Image.network(
            _smileIconUrl!,
            width: context.w(35),
            height: context.w(35),
            errorBuilder: (context, error, stackTrace) => Icon(Icons.face, size: context.w(35), color: const Color(0xFF6C5A00)),
          )
              : Icon(Icons.face, size: context.w(35), color: const Color(0xFF6C5A00)),

          SizedBox(width: context.w(10)),
          Expanded(
            child: Text(
              "Giggle &\nGrow",
              style: TextStyle(height: 1.1, fontWeight: FontWeight.w900, fontSize: context.sp(24), color: const Color(0xFF6C5A00)),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: context.w(18), vertical: context.h(8)),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD709),
              borderRadius: BorderRadius.circular(25),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
            ),
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

  Widget _buildTimerSection() {
    String minutes = (_secondsRemaining ~/ 60).toString();
    String seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    double absolutePercentage = _secondsRemaining / _totalDuration;

    return Container(
      width: context.w(320),
      height: context.h(55),
      padding: EdgeInsets.symmetric(horizontal: context.w(16)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF9EFF8D), width: 2),
      ),
      child: Row(
        children: [
          Icon(Icons.timer_outlined, color: const Color(0xFF04647D), size: context.w(24)),
          SizedBox(width: context.w(8)),
          Text(
            "$minutes:$seconds",
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: context.sp(16), color: const Color(0xFF04647D)),
          ),
          const Spacer(),
          Row(
            children: List.generate(5, (i) {
              bool completeFilled = i < (absolutePercentage * 5).floor();
              return Container(
                margin: EdgeInsets.only(left: context.w(4)),
                width: context.w(12), height: context.w(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: completeFilled ? const Color(0xFF21FF31) : const Color(0xFF04647D),
                ),
              );
            }),
          )
        ],
      ),
    );
  }

  Widget _buildLevelLabel() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.w(24), vertical: context.h(8)),
      decoration: BoxDecoration(color: const Color(0xFF9AE1FF), borderRadius: BorderRadius.circular(48)),
      child: Text(
        _levelLabel,
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: context.sp(12), color: const Color(0xFF005267)),
      ),
    );
  }

  Widget _buildMainTitle() => Text(_mainTitle, style: TextStyle(fontWeight: FontWeight.w800, fontSize: context.sp(32), color: const Color(0xFF6C5A00)));

  Widget _build4x4Grid() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.w(24)),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: context.w(12),
          crossAxisSpacing: context.w(12),
          mainAxisExtent: context.h(85),
        ),
        itemCount: _icons.length,
        itemBuilder: (context, index) {
          final isFlipped = _cardFlipped[index];
          return GestureDetector(
            onTap: () => _handleTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: isFlipped ? Colors.white : const Color(0xFFFFD709),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isFlipped ? const Color(0xFFCAFFBB) : const Color(0xFFFFB800),
                  width: 3,
                ),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 3)),
                ],
              ),
              child: Center(
                child: Text(
                  isFlipped ? _icons[index] : "?",
                  style: TextStyle(
                    fontSize: context.sp(32),
                    fontWeight: FontWeight.bold,
                    color: isFlipped ? const Color(0xFF04647D) : const Color(0xFF6C5A00),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPartnerBottomNav() {
    return Container(
      height: context.h(100),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(40))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(0, "GAMES", Icons.extension),
          _navItem(1, "LEARN", Icons.school),
          _navItem(2, "DRAW", Icons.palette),
          _navItem(3, "STORIES", Icons.menu_book),
        ],
      ),
    );
  }

  Widget _navItem(int idx, String label, IconData icon) {
    bool isSel = _selectedIndex == idx;
    return GestureDetector(
      onTap: () {
        if (isSel) return;

        _timer?.cancel();

        Widget nextScreen;
        switch (idx) {
          case 0: nextScreen = const FirstScreen(); break;
          case 1: nextScreen = const LearningMenu(); break;
          case 2: nextScreen = const DrawingCanvasScreen(); break;
          case 3: nextScreen = const StoriesListPage(); break;
          default: nextScreen = const FirstScreen();
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => nextScreen),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: context.w(20), vertical: context.h(8)),
            decoration: BoxDecoration(color: isSel ? const Color(0xFFFFD709) : Colors.transparent, borderRadius: BorderRadius.circular(25)),
            child: Icon(icon, color: isSel ? const Color(0xFF6C5A00) : const Color(0xFF04647D), size: context.w(26)),
          ),
          SizedBox(height: context.h(4)),
          Text(label, style: TextStyle(fontSize: context.sp(10), fontWeight: FontWeight.w800, color: isSel ? const Color(0xFF6C5A00) : const Color(0xFF04647D))),
        ],
      ),
    );
  }
}