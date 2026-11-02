import 'package:flutter/material.dart';

import 'home.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    final foreground = isLightMode ? Colors.black : Colors.white;
    final backgroundColor =
        isLightMode ? const Color(0xfff2f3f5) : const Color(0xff050505);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1210),
              child: AppPanel(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final character = FittedBox(
                      fit: BoxFit.scaleDown,
                      child: HomeLeftPanel(
                        imagePath: 'assets/images/characters/main.png',
                        imageRevealDelay: const Duration(milliseconds: 1500),
                        showPlayButton: false,
                        onPlay: () {},
                        onUserInteraction: () {},
                      ),
                    );
                    final content = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'INTRODUCTION',
                          style: TextStyle(
                            color: foreground,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Center(
                          child: FilledButton(
                            onPressed: onContinue,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xfff3eaa8),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 48,
                                vertical: 19,
                              ),
                              shape: const RoundedRectangleBorder(),
                            ),
                            child: const Text(
                              'CONTINUE',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );

                    if (constraints.maxWidth < 760) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          character,
                          const SizedBox(height: 20),
                          content,
                        ],
                      );
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Center(child: character),
                        ),
                        const SizedBox(width: 40),
                        Expanded(flex: 6, child: content),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
