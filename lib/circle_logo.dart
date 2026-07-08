import 'dart:math' as math;
import 'package:flutter/material.dart';

class CircleLogo extends StatefulWidget {
  final double size;
  const CircleLogo({super.key, this.size = 120});

  @override
  State<CircleLogo> createState() => _CircleLogoState();
}

class _CircleLogoState extends State<CircleLogo>
    with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final AnimationController _heartbeatController;
  late final Animation<double> _heartbeat;

  final List<Color> _dotColors = const [
    Color(0xFF00E5FF),
    Color(0xFF6C5CE7),
    Color(0xFF00E5FF),
    Color(0xFFFF3D9A),
    Color(0xFF6C5CE7),
    Color(0xFF00E5FF),
  ];

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    _heartbeatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();

    _heartbeat = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.14).chain(CurveTween(curve: Curves.easeOut)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.14, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.07).chain(CurveTween(curve: Curves.easeOut)),
        weight: 12,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.07, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 12,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 46),
    ]).animate(_heartbeatController);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _heartbeatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_rotationController, _heartbeat]),
      builder: (context, _) {
        return Transform.scale(
          scale: _heartbeat.value,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // zewnętrzna neonowa poświata
                Container(
                  width: widget.size * 1.3,
                  height: widget.size * 1.3,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF00E5FF).withValues(alpha: 0.18),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // cienki obrys - pierścień
                Container(
                  width: widget.size * 0.98,
                  height: widget.size * 0.98,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                ),
                // krążące neonowe kropki
                ...List.generate(_dotColors.length, (i) {
                  final angle = (2 * math.pi / _dotColors.length) * i +
                      _rotationController.value * 2 * math.pi;
                  final radius = widget.size * 0.36;
                  final dx = radius * math.cos(angle);
                  final dy = radius * math.sin(angle);
                  final dotSize = widget.size * 0.10;
                  return Transform.translate(
                    offset: Offset(dx, dy),
                    child: Container(
                      width: dotSize,
                      height: dotSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _dotColors[i],
                        boxShadow: [
                          BoxShadow(
                            color: _dotColors[i].withValues(alpha: 0.9),
                            blurRadius: 14,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                // środek - ciemna szklana kula z poświatą
                Container(
                  width: widget.size * 0.42,
                  height: widget.size * 0.42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [
                        Color(0xFF1A1F2E),
                        Color(0xFF05060A),
                      ],
                    ),
                    border: Border.all(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}