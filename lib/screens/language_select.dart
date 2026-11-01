import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../l10n/language_option.dart';

class LanguageSelectScreen extends StatelessWidget {
  const LanguageSelectScreen({
    super.key,
    required this.selectedLocale,
    required this.onLocaleSelected,
    required this.onNext,
    required this.onUserInteraction,
  });

  final Locale selectedLocale;
  final ValueChanged<Locale> onLocaleSelected;
  final VoidCallback onNext;
  final VoidCallback onUserInteraction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    final foreground = isLightMode ? const Color(0xff101010) : Colors.white;

    return Scaffold(
      backgroundColor:
          isLightMode ? const Color(0xfff2f3f5) : const Color(0xff050505),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(26),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.selectYourPreferredLanguage.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: foreground,
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 28),
                        for (final option in LanguageOption.all) ...[
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: isLightMode
                                  ? null
                                  : const [
                                      BoxShadow(
                                        color: Colors.white38,
                                        blurRadius: 7,
                                      ),
                                    ],
                            ),
                            child: TextButton(
                              onPressed: () {
                                onUserInteraction();
                                onLocaleSelected(option.locale);
                              },
                              style: TextButton.styleFrom(
                                alignment: Alignment.center,
                                foregroundColor: option.locale.languageCode ==
                                        selectedLocale.languageCode
                                    ? Colors.black
                                    : foreground,
                                backgroundColor: option.locale.languageCode ==
                                        selectedLocale.languageCode
                                    ? const Color(0xfff3eaa8)
                                    : isLightMode
                                        ? Colors.white
                                        : Colors.black,
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  18,
                                  20,
                                  22,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                option.displayName,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(height: 19),
                        ],
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () {
                              onUserInteraction();
                              onNext();
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xfff3eaa8),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 19),
                              shape: const RoundedRectangleBorder(),
                            ),
                            child: Text(
                              l10n.next,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
