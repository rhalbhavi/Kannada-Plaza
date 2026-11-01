import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
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

  Widget _progressRow(String heading, String value, Color headingColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              heading,
              style: TextStyle(color: headingColor, fontSize: 16),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xffffdae9),
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    final foreground = isLightMode ? Colors.black : Colors.white;
    final headingColor = isLightMode ? Colors.black : const Color(0xfff3eaa8);
    final background = location.destinationBackground;
    final locationName = switch (location.name) {
      'Airport / Travel' => l10n.airportTravel,
      'Tourism' => l10n.tourism,
      'Transport' => l10n.transport,
      'Food' => l10n.food,
      'Work' => l10n.work,
      'Education' => l10n.education,
      'Health' => l10n.health,
      'Shopping' => l10n.shopping,
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
                label: Text(l10n.backToMap),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 60),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  backgroundColor:
                      isLightMode ? const Color(0xfff3eaa8) : Colors.black,
                  foregroundColor: foreground,
                  elevation: isLightMode ? 0 : 12,
                  shadowColor: Colors.white38,
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
                  constraints: const BoxConstraints(maxWidth: 1140),
                  child: AppPanel(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final progress = Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _progressRow(l10n.bestScore, '0', headingColor),
                            const Divider(color: Color(0x66f3eaa8)),
                            _progressRow(
                              l10n.lessonsCompleted,
                              '0/80',
                              headingColor,
                            ),
                            const Divider(color: Color(0x66f3eaa8)),
                            _progressRow(
                              l10n.specialGoodiesUnlocked,
                              '0/10',
                              headingColor,
                            ),
                          ],
                        );
                        final profile = Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              locationName,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: headingColor,
                                fontSize: 32,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.juniorDreamEngineer,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isLightMode
                                    ? const Color(0xff303030)
                                    : const Color(0xfff3eaa8),
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 18),
                              child: Divider(
                                color: Color(0xb3f3eaa8),
                                height: 1,
                              ),
                            ),
                            progress,
                          ],
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
