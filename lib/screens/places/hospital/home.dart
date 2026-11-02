import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../city_location.dart';
import '../../home.dart';

class HospitalHomeScreen extends StatelessWidget {
  const HospitalHomeScreen({
    super.key,
    required this.location,
    required this.onBackToMap,
    required this.onPlay,
  });

  final CityLocation location;
  final VoidCallback onBackToMap;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    final foreground = isLightMode ? Colors.black : Colors.white;
    return Scaffold(
      backgroundColor: const Color(0xff050505),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (location.destinationBackground != null)
            Image.asset(
              location.destinationBackground!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const ColoredBox(color: Color(0xff050505)),
            ),
          Positioned(
            top: 18,
            left: 18,
            child: SafeArea(
              child: FilledButton.icon(
                onPressed: onBackToMap,
                icon: const Icon(Icons.arrow_back, size: 24),
                label: const Text('BACK TO MAP'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 60),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  backgroundColor:
                      isLightMode ? const Color(0xfff3eaa8) : Colors.black,
                  foregroundColor: foreground,
                  side: const BorderSide(color: Colors.black, width: 1.5),
                  textStyle: GoogleFonts.electrolize(fontSize: 16),
                ),
              ),
            ),
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
                        final profile = HomeProfileContent(
                          title: 'HOSPITAL',
                          onShowGoodies: () {},
                          isDestination: true,
                        );
                        final character = FittedBox(
                          fit: BoxFit.scaleDown,
                          child: HomeLeftPanel(
                            imagePath: location.characterAsset,
                            onPlay: onPlay,
                            onUserInteraction: () {},
                          ),
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
