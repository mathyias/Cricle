import 'dart:math' as math;
import 'package:flutter/material.dart';

// Same 3 wirujące pierścienie, bez logo na środku - używane samodzielnie
// (np. na ekranie startowym) i wewnątrz CircleLogo.
class SpinningRings extends StatefulWidget {
  final double size;
  // Dodatkowy obrót pierścieni - używany przez animację startową, żeby
  // pierścienie mogły przyspieszać.
  final Animation<double>? extraSpin;
  const SpinningRings({super.key, this.size = 220, this.extraSpin});

  @override
  State<SpinningRings> createState() => _SpinningRingsState();
}

class _SpinningRingsState extends State<SpinningRings>
    with TickerProviderStateMixin {
  late final AnimationController _ring1Controller;
  late final AnimationController _ring2Controller;
  late final AnimationController _ring3Controller;

  @override
  void initState() {
    super.initState();
    _ring1Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();

    _ring2Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 55),
    )..repeat();

    _ring3Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 70),
    )..repeat();
  }

  @override
  void dispose() {
    _ring1Controller.dispose();
    _ring2Controller.dispose();
    _ring3Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pierścień 1 (wewnętrzny) - obrót w prawo (+ ewentualne przyspieszenie)
          AnimatedBuilder(
            animation: widget.extraSpin != null
                ? Listenable.merge([_ring1Controller, widget.extraSpin])
                : _ring1Controller,
            builder: (context, _) => Transform.rotate(
              angle: _ring1Controller.value * 2 * math.pi +
                  (widget.extraSpin?.value ?? 0),
              child: CustomPaint(
                size: Size(size * 0.80, size * 0.80),
                painter: _RingPainter(),
              ),
            ),
          ),

          // Pierścień 2 (środkowy) - obrót w lewo (+ ewentualne przyspieszenie)
          AnimatedBuilder(
            animation: widget.extraSpin != null
                ? Listenable.merge([_ring2Controller, widget.extraSpin])
                : _ring2Controller,
            builder: (context, _) => Transform.rotate(
              angle: -_ring2Controller.value * 2 * math.pi -
                  (widget.extraSpin?.value ?? 0),
              child: CustomPaint(
                size: Size(size * 0.90, size * 0.90),
                painter: _RingPainter(),
              ),
            ),
          ),

          // Pierścień 3 (zewnętrzny) - obrót w prawo, wolniej (+ przyspieszenie)
          AnimatedBuilder(
            animation: widget.extraSpin != null
                ? Listenable.merge([_ring3Controller, widget.extraSpin])
                : _ring3Controller,
            builder: (context, _) => Transform.rotate(
              angle: _ring3Controller.value * 2 * math.pi +
                  (widget.extraSpin?.value ?? 0) * 0.85,
              child: CustomPaint(
                size: Size(size * 1.0, size * 1.0),
                painter: _RingPainter(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CircleLogo extends StatefulWidget {
  final double size;
  // Dodatkowy obrót pierścieni (nie rusza samym logo na środku) - używany
  // przez animację startową, żeby pierścienie mogły przyspieszać.
  final Animation<double>? extraSpin;
  const CircleLogo({super.key, this.size = 160, this.extraSpin});

  @override
  State<CircleLogo> createState() => _CircleLogoState();
}

class _CircleLogoState extends State<CircleLogo>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _pulse = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.06).chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.06, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 60),
    ]).animate(_pulseController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ringAreaSize = widget.size * 1.35;

    return SizedBox(
      width: ringAreaSize,
      height: ringAreaSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SpinningRings(size: ringAreaSize, extraSpin: widget.extraSpin),

          // Logo na środku
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, _) => Transform.scale(
              scale: _pulse.value,
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: CustomPaint(painter: _CirclePainter()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Czysty przerywany okrąg - 3 pola po 120°, każde z krótką kreską
class _RingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final paint = Paint()
      ..color = const Color(0xFFE8332B).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    const sectorFraction = 1 / 3;
    for (int i = 0; i < 3; i++) {
      final centerFraction = i * sectorFraction + sectorFraction / 2;
      final startAngle = (centerFraction - 0.05) * 2 * math.pi;
      canvas.drawArc(rect, startAngle, 0.10 * 2 * math.pi, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Warstwa robocza, żeby wycięcie mogło być NAPRAWDĘ przezroczyste
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    final paint = Paint()
      ..shader = RadialGradient(
        colors: const [Color(0xFFE8332B), Color(0xFF9E1B1B)],
        center: Alignment.topLeft,
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);

    // Pasek - od środka do prawej krawędzi - WYCINA, nie zamalowuje na biało
    final clearPaint = Paint()..blendMode = BlendMode.clear;
    final notchHeight = size.height * 0.11;

    final rect = Rect.fromLTWH(
      center.dx,
      center.dy - notchHeight / 2,
      size.width - center.dx,
      notchHeight,
    );
    canvas.drawRect(rect, clearPaint);

    // kropka na środku koła - też wycięta (przezroczysta)
    final dotRadius = size.width * 0.10;
    canvas.drawCircle(center, dotRadius, clearPaint);

    canvas.restore();

    // tekst "THE CIRCLE" po prawej stronie kropki - rysowany OSOBNO, na wierzchu
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'THE CIRCLE',
        style: TextStyle(
          color: const Color(0xFFE8332B),
          fontSize: size.width * 0.058,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final textX = center.dx + dotRadius * 0.9;
    final textY = center.dy - textPainter.height / 2;
    textPainter.paint(canvas, Offset(textX, textY));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
