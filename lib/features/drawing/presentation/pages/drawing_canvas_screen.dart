import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- REMINDER: Verify this exact layout file path location matches your project tree ---
import 'package:finalproject/core/utils/size_extension.dart';

// --- FIXED Navigation Imports ---
import 'package:finalproject/features/onboarding/presentation/pages/first_screen.dart';
import 'package:finalproject/features/learning/presentation/pages/learning_menu.dart';
import 'package:finalproject/features/stories/presentation/pages/stories_list_page.dart';

class DrawingPoint {
  final Offset offset;
  final Paint paint;
  DrawingPoint({required this.offset, required this.paint});
}

class DrawingCanvasScreen extends StatefulWidget {
  const DrawingCanvasScreen({super.key});

  @override
  State<DrawingCanvasScreen> createState() => _DrawingCanvasScreenState();
}

class _DrawingCanvasScreenState extends State<DrawingCanvasScreen> {
  // Initialization State Controllers
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  String? _errorMessage;

  // Remote UI Configuration Values
  String _appTitle = "Giggle & Grow";
  String? _smileIconUrl;
  String? _dinosaurMascotUrl;
  String _placeholderText = "Start your masterpiece!";
  List<Color> _fetchedColors = [];
  int _userStars = 0;

  // Canvas Drawing States Engine Metrics
  List<DrawingPoint?> points = [];
  Color selectedColor = Colors.black;
  double strokeWidth = 5.0;
  bool isEraser = false;

  final int _selectedIndex = 2; // DRAW mapped index indicator hook point
  final GlobalKey canvasKey = GlobalKey();

  // Authentication Context Fallback Values
  final String _mockUserId = "test_user_id_123";

  @override
  void initState() {
    super.initState();
    _fetchCanvasRemoteAssets();
  }

  /// Master Initialization Handshake extracting lookups safely from Firestore backend
  Future<void> _fetchCanvasRemoteAssets() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // 1. Resolve Remote Dynamic Configuration Fields Setup
      DocumentSnapshot configSnapshot = await _firestore
          .collection('drawing_settings')
          .doc('canvas_config')
          .get();

      if (configSnapshot.exists) {
        Map<String, dynamic> config = configSnapshot.data() as Map<String, dynamic>;
        _appTitle = config['appTitle'] ?? "Giggle & Grow";
        _smileIconUrl = config['smileIconURL'];
        _dinosaurMascotUrl = config['dinosaurMascotURL'];
        _placeholderText = config['placeholderText'] ?? "Start your masterpiece!";

        // Convert hex strings into Flutter color instances
        if (config['hexColorPalette'] != null) {
          List<dynamic> dynamicHexList = config['hexColorPalette'];
          _fetchedColors = dynamicHexList.map((hexStr) {
            final normalizedHex = hexStr.toString().replaceAll('#', '');
            return Color(int.parse("FF$normalizedHex", radix: 16));
          }).toList();
        }
      }

      // Fallback fallback safeguards protection block
      if (_fetchedColors.isEmpty) {
        _fetchedColors = [Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.blue, Colors.purple, Colors.pink, Colors.black];
      }
      selectedColor = _fetchedColors.last;

      // 2. Resolve User Profiling parameters metrics counters balance info
      DocumentSnapshot userSnapshot = await _firestore.collection('users').doc(_mockUserId).get();
      if (userSnapshot.exists) {
        Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
        _userStars = userData['stars'] ?? 0;
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Network Integration Layer Failure: ${e.toString()}";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FCE4),
      body: _buildConditionalContentWrapper(),
    );
  }

  /// Structural router mapping out loading state overlays gracefully
  Widget _buildConditionalContentWrapper() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF63FF54)),
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
              Icon(Icons.cloud_off, color: Colors.orangeAccent, size: context.w(60)),
              SizedBox(height: context.h(16)),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: context.sp(14), color: Colors.black54, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: context.h(20)),
              ElevatedButton(
                onPressed: _fetchCanvasRemoteAssets,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3BFF3B)),
                child: Text("Retry Connection", style: TextStyle(color: const Color(0xFF6C5A00), fontWeight: FontWeight.bold, fontSize: context.sp(14))),
              )
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        Column(
          children: [
            _buildPartnerAppBar(_appTitle),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(context.w(20)),
                child: Stack(
                  children: [
                    _buildCanvasArea(),
                    _buildDinosaurMascot(),
                    Positioned(left: context.w(15), top: context.h(100), child: _buildSideTools()),
                  ],
                ),
              ),
            ),
            _buildColorPalette(),
            SizedBox(height: context.h(110)), // Preserved layout baseline buffer alignment constraint
          ],
        ),
        Positioned(bottom: 0, left: 0, right: 0, child: _buildPartnerBottomNav()),
      ],
    );
  }

  Widget _buildPartnerAppBar(String title) {
    return Container(
      width: double.infinity,
      height: context.h(115),
      padding: EdgeInsets.only(
        left: context.w(20),
        right: context.w(20),
        bottom: context.h(16),
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
          _smileIconUrl != null
              ? SvgPicture.network(
            _smileIconUrl!,
            width: context.w(35),
            height: context.w(35),
            colorFilter: const ColorFilter.mode(Color(0xFF6C5A00), BlendMode.srcIn),
            placeholderBuilder: (context) => SizedBox(width: context.w(35), height: context.w(35), child: CircularProgressIndicator(strokeWidth: context.w(2))),
          )
              : SvgPicture.asset(
            'assets/icons/smileIcon.svg',
            width: context.w(35),
            height: context.w(35),
            colorFilter: const ColorFilter.mode(Color(0xFF6C5A00), BlendMode.srcIn),
          ),
          SizedBox(width: context.w(12)),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: context.sp(22), color: const Color(0xFF6C5A00)),
            ),
          ),
          SizedBox(width: context.w(8)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: context.w(14), vertical: context.h(8)),
            decoration: BoxDecoration(
              color: const Color(0x3321FF31),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "$_userStars ⭐",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: context.sp(16), color: const Color(0xFF6C5A00)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvasArea() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: const Color(0xFF63FF54), width: 3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(37),
        child: Stack(
          children: [
            if (points.isEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_note, size: context.w(60), color: Colors.grey.withValues(alpha: 0.2)),
                    Text(
                      _placeholderText,
                      style: TextStyle(fontSize: context.sp(18), fontWeight: FontWeight.bold, color: Colors.black12),
                    ),
                  ],
                ),
              ),
            GestureDetector(
              onPanUpdate: (details) {
                final renderBox = canvasKey.currentContext?.findRenderObject() as RenderBox?;
                if (renderBox == null) return;

                final localPos = renderBox.globalToLocal(details.globalPosition);
                final size = renderBox.size;

                // Fixed path constraint protection logic prevents lines from dragging off-screen
                if (localPos.dx >= 0 && localPos.dx <= size.width && localPos.dy >= 0 && localPos.dy <= size.height) {
                  setState(() {
                    points.add(DrawingPoint(
                      offset: localPos,
                      paint: Paint()
                        ..color = isEraser ? Colors.transparent : selectedColor
                        ..strokeCap = StrokeCap.round
                        ..strokeWidth = isEraser ? context.w(40) : strokeWidth
                        ..blendMode = isEraser ? BlendMode.clear : BlendMode.srcOver,
                    ));
                  });
                }
              },
              onPanEnd: (_) => points.add(null),
              child: CustomPaint(
                key: canvasKey,
                painter: DrawingPainter(points: points),
                size: Size.infinite,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDinosaurMascot() {
    return Positioned(
      bottom: context.h(15),
      left: context.w(10),
      child: IgnorePointer(
        child: _dinosaurMascotUrl != null
            ? Image.network(
          _dinosaurMascotUrl!,
          width: context.w(110),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Image.asset('assets/images/diagnosore.png', width: context.w(110), fit: BoxFit.contain),
        )
            : Image.asset(
          'assets/images/diagnosore.png',
          width: context.w(110),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildSideTools() {
    return Column(
      children: [
        _toolButton(Icons.brush, "BRUSH", !isEraser, const Color(0xFFFFD709)),
        SizedBox(height: context.h(12)),
        _toolButton(Icons.auto_fix_normal, "ERASER", isEraser, const Color(0xFF98E5FF)),
        SizedBox(height: context.h(12)),
        _toolButton(Icons.delete, "CLEAR", false, const Color(0xFF3BFF3B), clear: true),
      ],
    );
  }

  Widget _toolButton(IconData icon, String label, bool active, Color color, {bool clear = false}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (clear) {
            points.clear();
          } else {
            isEraser = (label == "ERASER");
          }
        });
      },
      child: Container(
        width: context.w(65),
        height: context.w(65),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: active ? Border.all(color: Colors.black, width: 2) : null,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: context.w(22), color: const Color(0xFF6C5A00)),
            Text(label, style: TextStyle(fontSize: context.sp(9), fontWeight: FontWeight.w900, color: const Color(0xFF6C5A00))),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPalette() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: context.w(20), vertical: context.h(8)),
      padding: EdgeInsets.symmetric(horizontal: context.w(10), vertical: context.h(8)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _fetchedColors
            .map((c) => GestureDetector(
          onTap: () {
            setState(() {
              selectedColor = c;
              isEraser = false;
            });
          },
          child: Container(
            width: context.w(28),
            height: context.w(28),
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
              border: Border.all(
                  color: selectedColor == c ? Colors.yellow : Colors.white,
                  width: 2),
            ),
          ),
        ))
            .toList(),
      ),
    );
  }

  Widget _buildPartnerBottomNav() {
    return Container(
      height: context.h(100),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40), topRight: Radius.circular(40)),
      ),
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

        Widget? nextScreen;
        if (idx == 0) {
          nextScreen = const FirstScreen();
        } else if (idx == 1) {
          nextScreen = const LearningMenu();
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: context.w(20), vertical: context.h(8)),
            decoration: BoxDecoration(
              color: isSel ? const Color(0xFFFFD709) : Colors.transparent,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(icon, color: const Color(0xFF04647D), size: context.w(26)),
          ),
          SizedBox(height: context.h(2)),
          Text(label,
              style: TextStyle(
                  fontSize: context.sp(10),
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF04647D))),
        ],
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint?> points;
  DrawingPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(
            points[i]!.offset, points[i + 1]!.offset, points[i]!.paint);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}