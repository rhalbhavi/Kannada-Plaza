import 'dart:async';

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _contentVisible = false;
  bool _whiteVisible = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    unawaited(_runSequence());
  }

  Future<void> _runSequence() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    if (!mounted) return;
    setState(() => _contentVisible = true);
    await Future<void>.delayed(const Duration(seconds: 3));
    await Future<void>.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    setState(() => _whiteVisible = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted || _finished) return;
    _finished = true;
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Colors.black),
        Center(
          child: AnimatedOpacity(
            opacity: _contentVisible ? 1 : 0,
            duration: const Duration(seconds: 3),
            curve: Curves.easeOut,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image(
                  image: AssetImage('assets/images/splash/splash.png'),
                  width: 54,
                  height: 54,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 18),
                Text(
                  'KANNADA PLAZA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    letterSpacing: 7,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
          color: _whiteVisible ? Colors.white : Colors.transparent,
        ),
      ],
    );
  }
}
