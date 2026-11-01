import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'city_location.dart';
import 'home.dart';

class DestinationScreen extends StatelessWidget {
  const DestinationScreen({
    super.key,
    required this.location,
    required this.onBack,
  });

  final CityLocation location;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    final foreground = isLightMode ? Colors.black : Colors.white;
    final background = location.destinationBackground;
    final locationName = switch (location.name) {
      'Airport / Travel' => 'AIRPORT',
      'Tourism' => 'LANDMARK',
      'Transport' => 'PARKING ZONE',
      'Food' => 'RESTAURANT',
      'Work' => 'OFFICE',
      'Education' => 'CAMPUS',
      'Health' => 'HOSPITAL',
      'Shopping' => 'MARKET',
      _ => location.name,
    };

    return Scaffold(
      backgroundColor: const Color(0xff050505),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (background != null)
            Image.asset(
              background,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const ColoredBox(color: Color(0xff050505));
              },
            ),
          Positioned(
            top: 18,
            left: 18,
            child: SafeArea(
              child: FilledButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back, size: 24),
                label: const Text('BACK TO MAP'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 60),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  backgroundColor:
                      isLightMode ? const Color(0xfff3eaa8) : Colors.black,
                  foregroundColor: foreground,
                  elevation: 0,
                  side: BorderSide(
                    color: Colors.black,
                    width: 1.5,
                  ),
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
                          title: locationName,
                          onShowGoodies: () {},
                          isDestination: true,
                        );
                        final character = FittedBox(
                          fit: BoxFit.scaleDown,
                          child: HomeLeftPanel(
                            imagePath: location.characterAsset,
                            onPlay: onBack,
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
