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
                  child: const CircleLogo(size: 220),
                ),

                const SizedBox(height: 12),

                Text(
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

                const Spacer(flex: 2),

                _tapHint(),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
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