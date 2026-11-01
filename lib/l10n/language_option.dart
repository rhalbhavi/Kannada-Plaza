import 'package:flutter/material.dart';

class LanguageOption {
  const LanguageOption({
    required this.locale,
    required this.label,
    required this.nativeName,
  });

  final Locale locale;
  final String label;
  final String nativeName;

  String get displayName => '$label ($nativeName)';

  static const all = <LanguageOption>[
    LanguageOption(
      locale: Locale('en'),
      label: 'English',
      nativeName: 'English',
    ),
    LanguageOption(
      locale: Locale('hi', 'IN'),
      label: 'Hindi',
      nativeName: 'हिन्दी',
    ),
    LanguageOption(
      locale: Locale('ml', 'IN'),
      label: 'Malayalam',
      nativeName: 'മലയാളം',
    ),
    LanguageOption(
      locale: Locale('ta', 'IN'),
      label: 'Tamil',
      nativeName: 'தமிழ்',
    ),
    LanguageOption(
      locale: Locale('te', 'IN'),
      label: 'Telugu',
      nativeName: 'తెలుగు',
    ),
    LanguageOption(
      locale: Locale('bn', 'IN'),
      label: 'Bengali',
      nativeName: 'বাংলা',
    ),
  ];

  static LanguageOption fromLocale(Locale? locale) {
    return all.firstWhere(
      (option) => option.locale.languageCode == locale?.languageCode,
      orElse: () => all.first,
    );
  }
}
