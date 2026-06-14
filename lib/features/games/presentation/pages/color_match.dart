import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Core constant and screen imports
import 'package:finalproject/core/constant/assets.dart';
import 'package:finalproject/core/constant/colors.dart';
import 'package:finalproject/core/utils/size_extension.dart';
import 'package:finalproject/features/onboarding/presentation/pages/first_screen.dart';
import 'package:finalproject/features/learning/presentation/pages/learning_menu.dart';
import 'package:finalproject/features/drawing/presentation/widgets/canvas_painter.dart';
import 'package:finalproject/features/stories/presentation/pages/stories_list_page.dart';
import '../../../dashboard/presentation/provider/score_provider.dart';

class ColorMatchScreen extends StatefulWidget {
  const ColorMatchScreen({super.key});

  @override
  State<ColorMatchScreen> createState() => _ColorMatchScreenState();
}

class _ColorMatchScreenState extends State<ColorMatchScreen>
    with TickerProviderStateMixin {
  String _bearMessage = "You can do it!";
  bool _showConfetti = false;

  // FIRESTORE URLS
  String _logoUrl = '';
  String _bearUrl = '';

  final List<Map<String, dynamic>> _allBalloons = [
    {'name': 'Red', 'color': const Color(0xFFA52A0A), 'id': 1},
    {'name': 'Blue', 'color': const Color(0xFF1B6B80), 'id': 2},
    {'name': 'Yellow', 'color': const Color(0xFFE8C800), 'id': 3},
  ];

  late String _currentTargetColor;
  final List<int> _poppedIds = [];

  late Map<int, AnimationController> _popControllers;
  late Map<int, Animation<double>> _popScales;
  late Map<int, AnimationController> _shakeControllers;
  late Map<int, Animation<double>> _shakeAnims;

  late AnimationController _bearMsgController;
  late Animation<double> _bearMsgScale;

  @override
  void initState() {
    super.initState();

    _loadAssets();

    _currentTargetColor = "Red";

    _popControllers = {};
    _popScales = {};
    _shakeControllers = {};
    _shakeAnims = {};

    for (var b in _allBalloons) {
      int id = b['id'];

      final popCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      );

      _popControllers[id] = popCtrl;

      _popScales[id] = TweenSequence([
        TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 1.3),
          weight: 30,
        ),
        TweenSequenceItem(
          tween: Tween(begin: 1.3, end: 0.0),
          weight: 70,
        ),
      ]).animate(
        CurvedAnimation(
          parent: popCtrl,
          curve: Curves.easeIn,
        ),
      );

      final shakeCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 350),
      );

      _shakeControllers[id] = shakeCtrl;

      _shakeAnims[id] = TweenSequence([
        TweenSequenceItem(
          tween: Tween(begin: 0.0, end: -8.0),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: Tween(begin: -8.0, end: 8.0),
          weight: 2,
        ),
        TweenSequenceItem(
          tween: Tween(begin: 8.0, end: -8.0),
          weight: 2,
        ),
        TweenSequenceItem(
          tween: Tween(begin: -8.0, end: 8.0),
          weight: 2,
        ),
        TweenSequenceItem(
          tween: Tween(begin: 8.0, end: 0.0),
          weight: 1,
        ),
      ]).animate(
        CurvedAnimation(
          parent: shakeCtrl,
          curve: Curves.linear,
        ),
      );
    }

    _bearMsgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _bearMsgScale = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.15),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.15, end: 1.0),
        weight: 50,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _bearMsgController,
        curve: Curves.easeOut,
      ),
    );
  }

  Future<void> _loadAssets() async {
    try {
      final iconDoc = await FirebaseFirestore.instance
          .collection('app_settings')
          .doc('icons')
          .get();

      final gameDoc = await FirebaseFirestore.instance
          .collection('games')
          .doc('color_match')
          .get();

      if (!mounted) return;

      setState(() {
        _logoUrl = iconDoc.data()?['logoUrl'] ?? '';
        _bearUrl = gameDoc.data()?['bearMascotUrl'] ?? '';
      });
    } catch (e) {
      debugPrint("Error loading assets: $e");
    }
  }

  @override
  void dispose() {
    for (var c in _popControllers.values) {
      c.dispose();
    }

    for (var c in _shakeControllers.values) {
      c.dispose();
    }

    _bearMsgController.dispose();

    super.dispose();
  }

  void _triggerBearMessage(String msg) {
    setState(() => _bearMessage = msg);
    _bearMsgController.forward(from: 0);
  }

  void _handleTap(String tappedColor, int id) {
    if (_poppedIds.contains(id) || _showConfetti) return;

    if (tappedColor == _currentTargetColor) {
      _triggerBearMessage("YES! That's $_currentTargetColor! 🎈");

      context.read<ScoreProvider>().addScore(
        10,
        'balloon_match',
      );

      _popControllers[id]!.forward(from: 0).then((_) {
        if (!mounted) return;

        setState(() => _poppedIds.add(id));

        Future.delayed(
          const Duration(milliseconds: 200),
              () {
            if (!mounted) return;
            _checkLevelProgress();
          },
        );
      });
    } else {
      _triggerBearMessage("Oh no, try again 😅");
      _shakeControllers[id]!.forward(from: 0);
    }
  }

  void _checkLevelProgress() {
    var remaining = _allBalloons
        .where((b) => !_poppedIds.contains(b['id']))
        .toList();

    if (remaining.isEmpty) {
      setState(() => _showConfetti = true);

      _triggerBearMessage("AMAZING! 🎉");

      Future.delayed(
        const Duration(seconds: 4),
            () {
          if (!mounted) return;

          for (var c in _popControllers.values) {
            c.reset();
          }

          setState(() {
            _poppedIds.clear();
            _showConfetti = false;
            _currentTargetColor = "Red";
          });
        },
      );
    } else {
      final next = remaining[Random().nextInt(remaining.length)]['name']
      as String;

      setState(() => _currentTargetColor = next);

      _triggerBearMessage("Now find $next! 🔍");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE2FFD5),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: context.h(20)),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.w(24),
                            ),
                            child: Text(
                              _showConfetti
                                  ? '🎉 LEVEL COMPLETE! 🎉'
                                  : 'Tap the $_currentTargetColor Balloon!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: context.sp(28),
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF453900),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Stack(
                              children: [
                                _positionedBalloon(
                                  context,
                                  top: 30,
                                  left: 20,
                                  data: _allBalloons[1],
                                ),
                                _positionedBalloon(
                                  context,
                                  top: 0,
                                  right: 30,
                                  data: _allBalloons[0],
                                ),
                                _positionedBalloon(
                                  context,
                                  bottom: 110,
                                  left: 60,
                                  data: _allBalloons[2],
                                ),
                                Positioned(
                                  bottom: context.h(10),
                                  right: context.w(10),
                                  child: _buildMascot(context),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: context.h(100)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_showConfetti) const ConfettiOverlay(),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.w(16),
        vertical: context.h(12),
      ),
      margin: EdgeInsets.fromLTRB(
        context.w(20),
        context.h(10),
        context.w(20),
        context.h(10),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _logoUrl.isNotEmpty
                  ? Image.network(
                _logoUrl,
                height: context.h(38),
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.face,
                    color: const Color(0xFF6B5E00),
                    size: context.sp(34),
                  );
                },
              )
                  : Icon(
                Icons.face,
                color: const Color(0xFF6B5E00),
                size: context.sp(34),
              ),
              SizedBox(width: context.w(12)),
              Text(
                'Giggle & Grow',
                style: TextStyle(
                  fontSize: context.sp(20),
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF453900),
                ),
              ),
            ],
          ),
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
            horizontal: context.w(16),
            vertical: context.h(8),
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD709),
            borderRadius: BorderRadius.circular(context.w(50)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6B5E00)
                    .withValues(alpha: 0.2),
                blurRadius: 6,
                offset: Offset(0, context.h(3)),
              )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${scoreProvider.totalScore}',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: context.sp(18),
                  color: const Color(0xFF453900),
                ),
              ),
              SizedBox(width: context.w(4)),
              Icon(
                Icons.star,
                color: Colors.white,
                size: context.sp(20),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMascot(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ScaleTransition(
          scale: _bearMsgScale,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: context.w(150),
            ),
            padding: EdgeInsets.all(context.w(12)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(context.w(20)),
                topRight: Radius.circular(context.w(20)),
                bottomLeft: Radius.circular(context.w(20)),
                bottomRight: Radius.circular(context.w(4)),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                )
              ],
            ),
            child: Text(
              _bearMessage,
              style: TextStyle(
                fontSize: context.sp(13),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        SizedBox(width: context.w(6)),
        _bearUrl.isNotEmpty
            ? Image.network(
          _bearUrl,
          width: context.w(110),
          height: context.h(110),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Text(
              "🐻",
              style: TextStyle(fontSize: context.sp(60)),
            );
          },
        )
            : Text(
          "🐻",
          style: TextStyle(fontSize: context.sp(60)),
        ),
      ],
    );
  }

  Widget _buildIntegratedNavbar(BuildContext context) {
    return Container(
      height: context.h(95),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.w(32)),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(
            context,
            0,
            "GAMES",
            Assets.gamesBlueIcon,
            Assets.gamesBrownIcon,
            isActive: true,
          ),
          _navItem(
            context,
            1,
            "LEARN",
            Assets.learnBlueIcon,
            Assets.learnBrownIcon,
          ),
          _navItem(
            context,
            2,
            "DRAW",
            Assets.drawBlueIcon,
            Assets.drawBrownIcon,
          ),
          _navItem(
            context,
            3,
            "STORIES",
            Assets.storiesBlueIcon,
            Assets.storiesBrownIcon,
          ),
        ],
      ),
    );
  }

  Widget _navItem(
      BuildContext context,
      int idx,
      String label,
      String blueIcon,
      String brownIcon, {
        bool isActive = false,
      }) {
    return GestureDetector(
      onTap: () {
        switch (idx) {
          case 0:
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const FirstScreen(),
              ),
                  (route) => false,
            );
            break;

          case 1:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LearningMenu(),
              ),
            );
            break;

          case 2:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                const DrawingCanvasScreen(),
              ),
            );
            break;

          case 3:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                const StoriesListPage(),
              ),
            );
            break;
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.w(16),
          vertical: context.h(8),
        ),
        decoration: isActive
            ? BoxDecoration(
          color: AppColors.accentYellow,
          borderRadius:
          BorderRadius.circular(context.w(20)),
        )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              isActive ? brownIcon : blueIcon,
              width: context.w(22),
            ),
            SizedBox(height: context.h(4)),
            Text(
              label,
              style: TextStyle(
                fontSize: context.sp(10),
                fontWeight: FontWeight.bold,
                color: isActive
                    ? AppColors.navBarTextActive
                    : AppColors.navBarIconInactive,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _positionedBalloon(
      BuildContext context, {
        double? top,
        double? left,
        double? right,
        double? bottom,
        required Map<String, dynamic> data,
      }) {
    final int id = data['id'];

    return Positioned(
      top: top != null ? context.h(top) : null,
      left: left != null ? context.w(left) : null,
      right: right != null ? context.w(right) : null,
      bottom: bottom != null ? context.h(bottom) : null,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _popControllers[id]!,
          _shakeControllers[id]!,
        ]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_shakeAnims[id]!.value, 0),
            child: Transform.scale(
              scale: _poppedIds.contains(id)
                  ? 0.0
                  : _popScales[id]!.value,
              child: GestureDetector(
                onTap: () => _handleTap(data['name'], id),
                child: _BalloonWidget(
                  color: data['color'],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BalloonWidget extends StatelessWidget {
  final Color color;

  const _BalloonWidget({
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: context.w(105),
          height: context.h(130),
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-0.35, -0.4),
              radius: 0.85,
              colors: [
                _lighten(color, 0.3),
                color,
                _darken(color, 0.15),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(context.w(54)),
              topRight: Radius.circular(context.w(54)),
              bottomLeft: Radius.circular(context.w(24)),
              bottomRight: Radius.circular(context.w(24)),
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.45),
                blurRadius: 16,
                offset: Offset(
                  context.w(4),
                  context.h(8),
                ),
              )
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: context.h(16),
                left: context.w(18),
                child: Container(
                  width: context.w(28),
                  height: context.h(36),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.28),
                    borderRadius:
                    BorderRadius.circular(context.w(18)),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: context.w(10),
          height: context.h(10),
          decoration: BoxDecoration(
            color: _darken(color, 0.2),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 1.5,
          height: context.h(50),
          color: Colors.grey.shade400,
        ),
      ],
    );
  }

  Color _lighten(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);

    return hsl
        .withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    )
        .toColor();
  }

  Color _darken(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);

    return hsl
        .withLightness(
      (hsl.lightness - amount).clamp(0.0, 1.0),
    )
        .toColor();
  }
}

class ConfettiOverlay extends StatelessWidget {
  const ConfettiOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Text(
          "🎊",
          style: TextStyle(
            fontSize: context.sp(100),
          ),
        ),
      ),
    );
  }
}