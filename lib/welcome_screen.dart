import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'glass.dart';
import 'main_nav.dart';
import 'circle_logo.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(flex: 3),

                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const MainNav()),
                    );
                  },
                  child: const CircleLogo(size: 180),
                ),

                const SizedBox(height: 44),

                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF00E5FF), Color(0xFF9C6BFF)],
                  ).createShader(bounds),
                  child: const Text(
                    'CIRCLE',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 6,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Dołącz do kręgu.\nOdkryj, co ukryte.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withValues(alpha: 0.55),
                    height: 1.6,
                    letterSpacing: 0.5,
                  ),
                ),

                const Spacer(flex: 2),

                _pulsingHint(),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pulsingHint() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          CupertinoIcons.hand_draw_fill,
          color: const Color(0xFF00E5FF).withValues(alpha: 0.7),
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