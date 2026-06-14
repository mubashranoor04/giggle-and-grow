import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/size_extension.dart';
import '../../../learning/presentation/pages/learning_menu.dart';
import '../../../onboarding/presentation/pages/first_screen.dart';
import '../../../stories/presentation/pages/stories_list_page.dart';
import '../../../dashboard/presentation/provider/score_provider.dart';
// --- Size Extension Import ---

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
  List<DrawingPoint?> points = [];
  Color selectedColor = Colors.black;
  double strokeWidth = 5.0;
  bool isEraser = false;

  final int _selectedIndex = 2; // DRAW is index 2
  final GlobalKey canvasKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FCE4),
      body: Stack(
        children: [
          Column(
            children: [
              _buildPartnerAppBar("Giggle & Grow"),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(context.w(20.0)),
                  child: Stack(
                    children: [
                      _buildCanvasArea(),
                      _buildDinosaurMascot(),
                      Positioned(
                          left: context.w(15),
                          top: context.h(100),
                          child: _buildSideTools()
                      ),
                    ],
                  ),
                ),
              ),
              _buildColorPalette(),
              SizedBox(height: context.h(110)), // Responsive space for bottom nav
            ],
          ),
          Positioned(bottom: 0, left: 0, right: 0, child: _buildPartnerBottomNav()),
        ],
      ),
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
        top: MediaQuery.of(context).padding.top + 5,
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
          SvgPicture.asset(
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
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: context.sp(22),
                  color: const Color(0xFF6C5A00)
              ),
            ),
          ),
          SizedBox(width: context.w(8)),
          Consumer<ScoreProvider>(
            builder: (context, scoreProvider, child) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: context.w(14), vertical: context.h(8)),
                decoration: BoxDecoration(
                  color: const Color(0x3321FF31),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${scoreProvider.totalScore} ⭐",
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: context.sp(16),
                      color: const Color(0xFF6C5A00)
                  ),
                ),
              );
            },
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
                    Icon(
                        Icons.edit_note,
                        size: context.w(60),
                        color: Colors.grey.withValues(alpha: 0.2)
                    ),
                    Text(
                      "Start your masterpiece!",
                      style: TextStyle(
                          fontSize: context.sp(18),
                          fontWeight: FontWeight.bold,
                          color: Colors.black12
                      ),
                    ),
                  ],
                ),
              ),
            GestureDetector(
              onPanUpdate: (details) {
                final renderBox = canvasKey.currentContext?.findRenderObject() as RenderBox?;
                if (renderBox == null) return;
                setState(() {
                  points.add(DrawingPoint(
                    offset: renderBox.globalToLocal(details.globalPosition),
                    paint: Paint()
                      ..color = isEraser ? Colors.transparent : selectedColor
                      ..strokeCap = StrokeCap.round
                      ..strokeWidth = isEraser ? 40 : strokeWidth
                      ..blendMode = isEraser ? BlendMode.clear : BlendMode.srcOver,
                  ));
                });
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
      child: Image.asset(
        'assets/images/diagnosore.png',
        width: context.w(110),
        fit: BoxFit.contain,
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
            Text(
                label,
                style: TextStyle(
                    fontSize: context.sp(9),
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF6C5A00)
                )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPalette() {
    final colors = [
      Colors.red, Colors.orange, Colors.yellow, Colors.green,
      Colors.blue, Colors.purple, Colors.pink, Colors.black
    ];
    return Container(
      margin: EdgeInsets.symmetric(horizontal: context.w(20), vertical: context.h(8)),
      padding: EdgeInsets.symmetric(horizontal: context.w(10), vertical: context.h(8)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: colors
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
        } else if (idx == 1) {nextScreen = const LearningMenu();}
        else if (idx == 3) {nextScreen = const StoriesListPage();}

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
          Text(
              label,
              style: TextStyle(
                  fontSize: context.sp(10),
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF04647D)
              )
          ),
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