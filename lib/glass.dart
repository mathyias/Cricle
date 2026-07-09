import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

// Kolory linii "obwodu" na tle - teal po niebieskiej stronie gradientu,
// czerwony po pomarańczowej. Używane też przez animację startową (welcome_screen).
class CircuitColors {
  static const teal = Color(0xFF2BA8C0);
  static const red = Color(0xFFE8332B);

  static Color lerp(double xFraction) =>
      Color.lerp(teal, red, xFraction.clamp(0.0, 1.0))!;
}

// Tło z gradientem + technicznymi liniami/kształtami - używane na każdym ekranie
class AppBackground extends StatelessWidget {
  final Widget child;
  // Przyciemnia linie "obwodu" (0 = niewidoczne) - używane przez animację
  // startową, kiedy linie "odlatują" do logo.
  final double linesOpacity;

  const AppBackground({
    super.key,
    required this.child,
    this.linesOpacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFB8E3E8),
                Color(0xFFEDE6DC),
                Color(0xFFE8CBAE),
              ],
            ),
          ),
        ),
        if (linesOpacity > 0)
          Positioned.fill(
            child: Opacity(
              opacity: linesOpacity.clamp(0.0, 1.0),
              child: CustomPaint(
                painter: _CircuitLinesPainter(),
              ),
            ),
          ),
        child,
      ],
    );
  }
}

class _CircuitLinesPainter extends CustomPainter {
  // Kolor linii zależny od pozycji poziomej - teal po lewej (niebieska
  // strona tła), czerwony po prawej (pomarańczowa strona tła).
  Paint _paintFor(double xFraction, {double alpha = 0.22, double width = 1.3}) {
    return Paint()
      ..color = CircuitColors.lerp(xFraction).withValues(alpha: alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // duże dekoracyjne okręgi koncentryczne (lewy górny róg) - teal
    final tealCircles = _paintFor(0.12);
    canvas.drawCircle(Offset(size.width * 0.12, size.height * 0.10), 70, tealCircles);
    canvas.drawCircle(Offset(size.width * 0.12, size.height * 0.10), 115, tealCircles);
    canvas.drawCircle(Offset(size.width * 0.12, size.height * 0.10), 165, tealCircles);

    // duże dekoracyjne okręgi (prawy dolny róg) - czerwone paski
    final redCircles = _paintFor(0.9);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.85), 90, redCircles);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.85), 140, redCircles);

    // "obwód" po lewej - kanciasty kształt jak schemat techniczny (teal)
    final path1 = Path()
      ..moveTo(0, size.height * 0.28)
      ..lineTo(size.width * 0.22, size.height * 0.28)
      ..lineTo(size.width * 0.22, size.height * 0.40)
      ..lineTo(size.width * 0.14, size.height * 0.40)
      ..lineTo(size.width * 0.14, size.height * 0.50)
      ..lineTo(size.width * 0.30, size.height * 0.50);
    canvas.drawPath(path1, _paintFor(0.20));

    // drugi kanciasty kształt po prawej - czerwony
    final path2 = Path()
      ..moveTo(size.width, size.height * 0.55)
      ..lineTo(size.width * 0.76, size.height * 0.55)
      ..lineTo(size.width * 0.76, size.height * 0.42)
      ..lineTo(size.width * 0.85, size.height * 0.42);
    canvas.drawPath(path2, _paintFor(0.85));

    // mały okrąg z "trzonkiem" - jak ikona zaworu/pinu - czerwony
    final pinPaint = _paintFor(0.82);
    final pinCenter = Offset(size.width * 0.82, size.height * 0.18);
    canvas.drawCircle(pinCenter, 22, pinPaint);
    canvas.drawLine(
      pinCenter,
      Offset(pinCenter.dx, pinCenter.dy - 40),
      pinPaint,
    );

    // przerywana linia ukośna w dolnej części - teal
    _drawDashedLine(
      canvas,
      Offset(size.width * 0.05, size.height * 0.95),
      Offset(size.width * 0.35, size.height * 0.78),
      _paintFor(0.15),
    );

    // dodatkowe czerwone "paski" promieniujące od środka - jak na zdjęciu
    final centerPaint = _paintFor(0.95, alpha: 0.28, width: 1.6);
    final center = Offset(size.width * 0.5, size.height * 0.42);
    for (int i = 0; i < 5; i++) {
      final angle = (-0.35 + i * 0.10) * 2 * math.pi;
      final r1 = size.width * 0.30;
      final r2 = size.width * 0.62;
      canvas.drawLine(
        center + Offset(math.cos(angle), math.sin(angle)) * r1,
        center + Offset(math.cos(angle), math.sin(angle)) * r2,
        centerPaint,
      );
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 6.0;
    const dashSpace = 5.0;
    final distance = (end - start).distance;
    final direction = (end - start) / distance;
    double covered = 0;
    while (covered < distance) {
      final segStart = start + direction * covered;
      final segEnd = start + direction * _mathMin(covered + dashWidth, distance);
      canvas.drawLine(segStart, segEnd, paint);
      covered += dashWidth + dashSpace;
    }
  }

  double _mathMin(double a, double b) => a < b ? a : b;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Uniwersalny szklany kontener (karty, panele)
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;
  final EdgeInsets? margin;
  // Krótka czerwona "kreska" w rogu karty - nawiązuje do wycięcia w logo.
  final bool accentBar;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.accentBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                child,
                if (accentBar)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: 34,
                      height: 3,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(3),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            CircuitColors.red.withValues(alpha: 0.85),
                            CircuitColors.red.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Nagłówek sekcji w stylu marki - mały czerwony pierścień + rozstrzelony,
// kapitalikowy tytuł (jak "THE CIRCLE" na logo).
class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: CircuitColors.red.withValues(alpha: 0.9),
              width: 1.6,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }
}

// Awatar z cienkim czerwonym pierścieniem - motyw "obserwowanego" konta.
class RingAvatar extends StatelessWidget {
  final double radius;
  final Widget child;
  final bool active;

  const RingAvatar({
    super.key,
    required this.child,
    this.radius = 20,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: CircuitColors.red.withValues(alpha: 0.55),
              width: 1.4,
            ),
          ),
          child: CircleAvatar(
            radius: radius,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            child: child,
          ),
        ),
        if (active)
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CircuitColors.red,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}

// Szklany przycisk pigułkowy
class GlassButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  const GlassButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Material(
          color: Colors.white.withValues(alpha: 0.25),
          child: InkWell(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4),
                  width: 1.2,
                ),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}