import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n/generated/app_localizations.dart';
import 'l10n/language_option.dart';
import 'screens/app_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KannadaPlazaApp());
}

class KannadaPlazaApp extends StatefulWidget {
  const KannadaPlazaApp({super.key});

  @override
  State<KannadaPlazaApp> createState() => _KannadaPlazaAppState();
}

class _KannadaPlazaAppState extends State<KannadaPlazaApp> {
  static const _localeKey = 'preferredLocale';
  static const _themeKey = 'isLightMode';
  static const _userNameKey = 'user_name';

  Locale _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    unawaited(_restorePreferences());
  }

  Future<void> _restorePreferences() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      if (!mounted) return;
      final languageCode = preferences.getString(_localeKey);
      setState(() {
        _locale = LanguageOption.fromLocale(
          languageCode == null ? null : Locale(languageCode),
        ).locale;
        _themeMode = preferences.getBool(_themeKey) ?? false
            ? ThemeMode.light
            : ThemeMode.dark;
      });
    } on Object catch (error, stackTrace) {
      debugPrint('Unable to restore app preferences: $error\n$stackTrace');
    }
  }

  Future<void> _setLocale(Locale locale) async {
    setState(() => _locale = locale);
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_localeKey, locale.languageCode);
    } on Object catch (error, stackTrace) {
      debugPrint('Unable to save preferred language: $error\n$stackTrace');
    }
  }

  Future<void> _toggleTheme() async {
    final isLightMode = _themeMode != ThemeMode.light;
    setState(() {
      _themeMode = isLightMode ? ThemeMode.light : ThemeMode.dark;
    });
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setBool(_themeKey, isLightMode);
    } on Object catch (error, stackTrace) {
      debugPrint('Unable to save theme preference: $error\n$stackTrace');
    }
  }

  Future<void> _resetUserSettings() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final appKeys = preferences
          .getKeys()
          .where(
            (key) =>
                key == _localeKey ||
                key == _themeKey ||
                key == _userNameKey ||
                key.startsWith('kannadaPlaza.'),
          )
          .toList();
      for (final key in appKeys) {
        await preferences.remove(key);
      }
      if (!mounted) return;
      setState(() {
        _locale = const Locale('en');
        _themeMode = ThemeMode.dark;
      });
    } on Object catch (error, stackTrace) {
      debugPrint('Unable to reset saved app settings: $error\n$stackTrace');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kannada Plaza',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: LanguageOption.all.map((option) => option.locale),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      themeMode: _themeMode,
      themeAnimationDuration: const Duration(milliseconds: 500),
      themeAnimationCurve: Curves.easeInOut,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xfff3eaa8),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.electrolizeTextTheme(
          ThemeData(brightness: Brightness.light).textTheme,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: Colors.white,
          elevation: 20,
          shadowColor: Colors.black26,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xff101010), width: 1.5),
          ),
          titleTextStyle: GoogleFonts.electrolize(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          contentTextStyle: GoogleFonts.electrolize(
            color: const Color(0xff222222),
            fontSize: 15,
            height: 1.62,
          ),
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xfff3eaa8),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.electrolizeTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: Colors.black,
          elevation: 24,
          shadowColor: Colors.white38,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.white, width: 1.5),
          ),
          titleTextStyle: GoogleFonts.electrolize(
            color: const Color(0xfff3eaa8),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          contentTextStyle: GoogleFonts.electrolize(
            color: Colors.white,
            fontSize: 15,
            height: 1.62,
          ),
        ),
        useMaterial3: true,
      ),
      home: AppShell(
        isLightMode: _themeMode == ThemeMode.light,
        onLocaleChanged: _setLocale,
        onThemeToggle: _toggleTheme,
        onResetSettings: _resetUserSettings,
      ),
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: _ResponsiveTextScaler(
              mediaQuery.textScaler,
              mediaQuery.size.shortestSide,
            ),
          ),
          child: child!,
        );
      },
    );
  }
}

class _ResponsiveTextScaler extends TextScaler {
  const _ResponsiveTextScaler(this.parent, this.shortestSide);

  final TextScaler parent;
  final double shortestSide;

  @override
  double scale(double fontSize) {
    final sizeFactor = (shortestSide / 720).clamp(0.9, 1.08);
    return (parent.scale(fontSize) + 5) * sizeFactor;
  }

  @override
  // ignore: deprecated_member_use
  double get textScaleFactor => parent.textScaleFactor;

  @override
  bool operator ==(Object other) =>
      other is _ResponsiveTextScaler &&
      other.parent == parent &&
      other.shortestSide == shortestSide;

  @override
  int get hashCode => Object.hash(parent, shortestSide);
}
