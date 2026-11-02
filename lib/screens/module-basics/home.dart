import 'package:flutter/material.dart';

import '../home.dart';

class ModuleBasicsHomeScreen extends StatelessWidget {
  const ModuleBasicsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    final foreground = isLightMode ? Colors.black : Colors.white;
    final backgroundColor =
        isLightMode ? const Color(0xfff2f3f5) : const Color(0xff050505);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/bg/basics_bg.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return ColoredBox(color: backgroundColor);
            },
          ),
          Center(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 100,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1210),
                  child: AppPanel(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final character = FittedBox(
                          fit: BoxFit.scaleDown,
                          child: HomeLeftPanel(
                            imagePath: 'assets/images/characters/basics_bg.png',
                            onPlay: () {},
                            onUserInteraction: () {},
                          ),
                        );
                        final profile = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'THE BASICS',
                              style: TextStyle(
                                color: foreground,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Get started with greeting people, saying "yes" and "no", and asking basic questions in Kannada.',
                              style: TextStyle(
                                color: Color(0xfff3eaa8),
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.6,
                                height: 1.32,
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
                              profile,
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
                            Expanded(flex: 6, child: profile),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
