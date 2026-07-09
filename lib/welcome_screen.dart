import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'glass.dart';
import 'main_nav.dart';
import 'circle_logo.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

// Punkty na tle, z których "odrywają się" linie i lecą do logo (patrz
// pozycje kształtów w glass.dart -> _CircuitLinesPainter).
class _StreakSpec {
  final Offset origin; // fraction 0..1 ekranu
  final double delay; // 0..1, opóźnienie startu w timeline
  final int spiralDir; // 1 albo -1
  const _StreakSpec(this.origin, this.delay, this.spiralDir);
}

const _streakSpecs = [
  _StreakSpec(Offset(0.12, 0.10), 0.00, 1),
  _StreakSpec(Offset(0.90, 0.85), 0.04, -1),
  _StreakSpec(Offset(0.20, 0.40), 0.08, 1),
  _StreakSpec(Offset(0.85, 0.48), 0.02, -1),
  _StreakSpec(Offset(0.82, 0.18), 0.10, 1),
  _StreakSpec(Offset(0.18, 0.87), 0.06, -1),
];

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  final GlobalKey _stackKey = GlobalKey();
  final GlobalKey _logoKey = GlobalKey();
  Offset? _logoCenter;

  late final AnimationController _launchController;

  late final Animation<double> _hintFade;
  late final Animation<double> _linesOpacity;
  late final Animation<double> _extraSpin;
  late final Animation<double> _explode;
  late final Animation<double> _flash;

  bool _launching = false;

  @override
  void initState() {
    super.initState();
    _launchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    );

    _hintFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _launchController,
        curve: const Interval(0.0, 0.18, curve: Curves.easeOut),
      ),
    );

    // Linie na tle znikają, jakby odlatywały do logo
    _linesOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _launchController,
        curve: const Interval(0.05, 0.55, curve: Curves.easeIn),
      ),
    );

    // Pierścienie wokół logo przyspieszają coraz szybciej
    _extraSpin = Tween<double>(begin: 0, end: 15 * math.pi).animate(
      CurvedAnimation(
        parent: _launchController,
        curve: const Interval(0.0, 0.82, curve: Curves.easeIn),
      ),
    );

    _explode = CurvedAnimation(
      parent: _launchController,
      curve: const Interval(0.80, 0.97, curve: Curves.easeOut),
    );

    _flash = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 60),
    ]).animate(
      CurvedAnimation(
        parent: _launchController,
        curve: const Interval(0.86, 1.0, curve: Curves.easeOut),
      ),
    );

    _launchController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 350),
            pageBuilder: (context, animation, secondaryAnimation) =>
                FadeTransition(opacity: animation, child: const MainNav()),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _launchController.dispose();
    super.dispose();
  }

  void _measureLogoCenter() {
    final logoBox = _logoKey.currentContext?.findRenderObject() as RenderBox?;
    final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (logoBox == null || stackBox == null || !logoBox.attached) return;
    final globalCenter = logoBox.localToGlobal(logoBox.size.center(Offset.zero));
    setState(() => _logoCenter = stackBox.globalToLocal(globalCenter));
  }

  void _startLaunch() {
    if (_launching) return;
    _measureLogoCenter();
    setState(() => _launching = true);
    _launchController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _launchController,
        builder: (context, _) {
          return AppBackground(
            linesOpacity: _launching ? _linesOpacity.value : 1.0,
            child: Stack(
              key: _stackKey,
              children: [
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        const Spacer(flex: 3),

                        GestureDetector(
                          onTap: _startLaunch,
                          child: KeyedSubtree(
                            key: _logoKey,
                            child: CircleLogo(
                              size: 220,
                              extraSpin: _launching ? _extraSpin : null,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Opacity(
                          opacity: _hintFade.value,
                          child: Text(
                            'Wszystko widzą. Wszystko wiedzą.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.9),
                              letterSpacing: 0.4,
                              height: 1.4,
                            ),
                          ),
                        ),

                        const Spacer(flex: 2),

                        Opacity(opacity: _hintFade.value, child: _tapHint()),

                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),

                if (_launching && _logoCenter != null)
                  ..._streakSpecs.map(
                    (spec) => _FlyingStreak(
                      spec: spec,
                      screenSize: screenSize,
                      logoCenter: _logoCenter!,
                      controller: _launchController,
                    ),
                  ),

                if (_launching) _ExplosionBurst(logoCenter: _logoCenter, t: _explode.value),

                if (_launching && _flash.value > 0)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        color: Colors.white.withValues(alpha: _flash.value * 0.92),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _tapHint() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          CupertinoIcons.hand_draw_fill,
          color: const Color(0xFFE8332B).withValues(alpha: 0.85),
          size: 16,
        ),
        const SizedBox(width: 10),
        Text(
          'DOTKNIJ, ABY WEJŚĆ',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

// Pojedyncza "smuga" lecąca po spirali z tła w stronę wirujących pierścieni.
class _FlyingStreak extends StatelessWidget {
  final _StreakSpec spec;
  final Size screenSize;
  final Offset logoCenter;
  final Animation<double> controller;

  const _FlyingStreak({
    required this.spec,
    required this.screenSize,
    required this.logoCenter,
    required this.controller,
  });

  static const double _landingRadius = 145;
  static const double _spiralTurns = 1.3;

  @override
  Widget build(BuildContext context) {
    final origin = Offset(
      spec.origin.dx * screenSize.width,
      spec.origin.dy * screenSize.height,
    );
    final originDelta = origin - logoCenter;
    final originAngle = math.atan2(originDelta.dy, originDelta.dx);
    final originDist = originDelta.distance;
    final color = CircuitColors.lerp(spec.origin.dx);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final start = (spec.delay * 0.5).clamp(0.0, 0.7);
        final end = (start + 0.5).clamp(0.0, 0.98);
        final raw = ((controller.value - start) / (end - start)).clamp(0.0, 1.0);
        final t = Curves.easeIn.transform(raw);

        if (raw <= 0) return const SizedBox.shrink();

        final angle = originAngle +
            spec.spiralDir * t * _spiralTurns * 2 * math.pi;
        final dist = originDist + (_landingRadius - originDist) * t;
        final pos = logoCenter + Offset(math.cos(angle), math.sin(angle)) * dist;
        final fade = t < 0.85 ? 1.0 : (1 - (t - 0.85) / 0.15);
        final dotSize = 6.0 - t * 3.0;

        return Positioned(
          left: pos.dx - dotSize / 2,
          top: pos.dy - dotSize / 2,
          child: IgnorePointer(
            child: Opacity(
              opacity: fade.clamp(0.0, 1.0),
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.7),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Rozbłysk / eksplozja w miejscu logo na koniec animacji.
class _ExplosionBurst extends StatelessWidget {
  final Offset? logoCenter;
  final double t;

  const _ExplosionBurst({required this.logoCenter, required this.t});

  @override
  Widget build(BuildContext context) {
    if (logoCenter == null || t <= 0) return const SizedBox.shrink();

    final radius = 20 + t * 260;
    final opacity = (1 - t).clamp(0.0, 1.0);

    return Positioned(
      left: logoCenter!.dx - radius,
      top: logoCenter!.dy - radius,
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity,
          child: Container(
            width: radius * 2,
            height: radius * 2,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white,
                  Color(0xFFE8332B),
                  Colors.transparent,
                ],
                stops: [0.0, 0.35, 1.0],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
