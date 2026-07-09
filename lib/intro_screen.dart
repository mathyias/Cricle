import 'package:flutter/material.dart';
import 'glass.dart';
import 'circle_logo.dart';
import 'welcome_screen.dart';

// Krótki ekran przed właściwym powitaniem - samo tło z wirującymi
// pierścieniami, bez logo na środku.
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (context, animation, secondaryAnimation) =>
              FadeTransition(opacity: animation, child: const WelcomeScreen()),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Center(
          child: SpinningRings(size: 260),
        ),
      ),
    );
  }
}
