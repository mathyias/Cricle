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

// Punkty na tle, z których "przewody" biegną do pierścieni wokół logo (patrz
// pozycje kształtów w glass.dart -> _CircuitLinesPainter).
class _StreakSpec {
  final Offset origin; // fraction 0..1 ekranu
  final double delay; // 0..1, opóźnienie startu w timeline
  const _StreakSpec(this.origin, this.delay);
}

const _streakSpecs = [
  _StreakSpec(Offset(0.12, 0.10), 0.00),
  _StreakSpec(Offset(0.90, 0.85), 0.04),
  _StreakSpec(Offset(0.20, 0.40), 0.08),
  _StreakSpec(Offset(0.85, 0.48), 0.02),
  _StreakSpec(Offset(0.82, 0.18), 0.10),
  _StreakSpec(Offset(0.18, 0.87), 0.06),
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
  late final Animation<double> _chargeGlow;
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

    // Statyczne linie na tle gasną - "oddają" energię przewodom lecącym do logo
    _linesOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _launchController,
        curve: const Interval(0.05, 0.6, curve: Curves.easeIn),
      ),
    );

    // Pierścienie wokół logo przyspieszają coraz szybciej
    _extraSpin = Tween<double>(begin: 0, end: 15 * math.pi).animate(
      CurvedAnimation(
        parent: _launchController,
        curve: const Interval(0.0, 0.82, curve: Curves.easeIn),
      ),
    );

    // Poświata logo rośnie w miarę jak "napełnia się" energią z przewodów
    _chargeGlow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _launchController,
        curve: const Interval(0.1, 0.85, curve: Curves.easeIn),
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
                if (_launching && _logoCenter != null)
                  _ChargeGlow(logoCenter: _logoCenter, t: _chargeGlow.value),

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

                // "Przewody" fizycznie łączące punkty tła z pierścieniami wokół
                // logo - impuls energii płynie po nich od końca do środka.
                if (_launching && _logoCenter != null)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _EnergyFlowPainter(
                          specs: _streakSpecs,
                          screenSize: screenSize,
                          logoCenter: _logoCenter!,
                          controller: _launchController,
                        ),
                      ),
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

// Rysuje "przewody" łączące punkty na tle z pierścieniami wokół logo oraz
// impuls energii płynący wzdłuż nich w stronę środka.
class _EnergyFlowPainter extends CustomPainter {
  final List<_StreakSpec> specs;
  final Size screenSize;
  final Offset logoCenter;
  final Animation<double> controller;

  _EnergyFlowPainter({
    required this.specs,
    required this.screenSize,
    required this.logoCenter,
    required this.controller,
  }) : super(repaint: controller);

  static const double _landingRadius = 150;

  @override
  void paint(Canvas canvas, Size size) {
    for (final spec in specs) {
      final origin = Offset(
        spec.origin.dx * screenSize.width,
        spec.origin.dy * screenSize.height,
      );
      final delta = origin - logoCenter;
      final angle = math.atan2(delta.dy, delta.dx);
      final landing =
          logoCenter + Offset(math.cos(angle), math.sin(angle)) * _landingRadius;
      final color = CircuitColors.lerp(spec.origin.dx);

      final start = (spec.delay * 0.5).clamp(0.0, 0.7);
      final end = (start + 0.5).clamp(0.0, 0.97);
      final raw = ((controller.value - start) / (end - start)).clamp(0.0, 1.0);
      if (raw <= 0) continue;
      final t = Curves.easeIn.transform(raw);

      // Przewód - stałe połączenie tła z pierścieniem, jaśniejące w miarę
      // przepływu energii.
      final conduitPaint = Paint()
        ..color = color.withValues(alpha: 0.16 + 0.14 * t)
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(origin, landing, conduitPaint);

      // Impuls energii płynący od końca przewodu do pierścienia
      final headT = t;
      final tailT = (t - 0.16).clamp(0.0, 1.0);
      final head = Offset.lerp(origin, landing, headT)!;
      final tail = Offset.lerp(origin, landing, tailT)!;
      final pulsePaint = Paint()
        ..color = color.withValues(alpha: (1 - t * 0.25).clamp(0.0, 1.0))
        ..strokeWidth = 4.2
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
      canvas.drawLine(tail, head, pulsePaint);

      // Mała łuna w miejscu, gdzie impuls dociera do pierścienia
      if (headT > 0.85) {
        final glowOpacity = ((headT - 0.85) / 0.15).clamp(0.0, 1.0) * 0.6;
        final glowPaint = Paint()
          ..color = color.withValues(alpha: glowOpacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawCircle(landing, 7, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _EnergyFlowPainter oldDelegate) => true;
}

// Poświata logo, która rośnie w miarę jak "napełnia się" energią z przewodów.
class _ChargeGlow extends StatelessWidget {
  final Offset? logoCenter;
  final double t;

  const _ChargeGlow({required this.logoCenter, required this.t});

  @override
  Widget build(BuildContext context) {
    if (logoCenter == null || t <= 0) return const SizedBox.shrink();

    final radius = 90 + t * 110;
    final opacity = t * 0.55;

    return Positioned(
      left: logoCenter!.dx - radius,
      top: logoCenter!.dy - radius,
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Container(
            width: radius * 2,
            height: radius * 2,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Color(0xFFE8332B),
                  Colors.transparent,
                ],
                stops: [0.0, 1.0],
              ),
            ),
          ),
        ),
      ),
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
