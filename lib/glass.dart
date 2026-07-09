import 'dart:ui';
import 'package:flutter/material.dart';

// Tło z gradientem + technicznymi liniami/kształtami - używane na każdym ekranie
class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

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
        Positioned.fill(
          child: CustomPaint(
            painter: _CircuitLinesPainter(),
          ),
        ),
        child,
      ],
    );
  }
}

class _CircuitLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    // duże dekoracyjne okręgi koncentryczne (lewy górny róg)
    canvas.drawCircle(Offset(size.width * 0.12, size.height * 0.10), 70, paint);
    canvas.drawCircle(Offset(size.width * 0.12, size.height * 0.10), 115, paint);
    canvas.drawCircle(Offset(size.width * 0.12, size.height * 0.10), 165, paint);

    // duże dekoracyjne okręgi (prawy dolny róg)
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.85), 90, paint);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.85), 140, paint);

    // "obwód" po lewej - kanciasty kształt jak schemat techniczny
    final path1 = Path()
      ..moveTo(0, size.height * 0.28)
      ..lineTo(size.width * 0.22, size.height * 0.28)
      ..lineTo(size.width * 0.22, size.height * 0.40)
      ..lineTo(size.width * 0.14, size.height * 0.40)
      ..lineTo(size.width * 0.14, size.height * 0.50)
      ..lineTo(size.width * 0.30, size.height * 0.50);
    canvas.drawPath(path1, paint);

    // drugi kanciasty kształt po prawej
    final path2 = Path()
      ..moveTo(size.width, size.height * 0.55)
      ..lineTo(size.width * 0.76, size.height * 0.55)
      ..lineTo(size.width * 0.76, size.height * 0.42)
      ..lineTo(size.width * 0.85, size.height * 0.42);
    canvas.drawPath(path2, paint);

    // mały okrąg z "trzonkiem" - jak ikona zaworu/pinu
    final pinCenter = Offset(size.width * 0.82, size.height * 0.18);
    canvas.drawCircle(pinCenter, 22, paint);
    canvas.drawLine(
      pinCenter,
      Offset(pinCenter.dx, pinCenter.dy - 40),
      paint,
    );

    // przerywana linia ukośna w dolnej części
    _drawDashedLine(
      canvas,
      Offset(size.width * 0.05, size.height * 0.95),
      Offset(size.width * 0.35, size.height * 0.78),
      paint,
    );
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

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(16),
    this.margin,
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
            child: child,
          ),
        ),
      ),
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