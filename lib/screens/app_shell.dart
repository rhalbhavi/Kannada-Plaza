import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../l10n/generated/app_localizations.dart';
import '../l10n/language_option.dart';
import 'city_location.dart';
import 'home.dart';
import 'intro.dart';
import 'browser_session_stub.dart'
    if (dart.library.js_interop) 'browser_session_web.dart' as browser_session;
import 'setup.dart';
import 'map.dart';
import 'module-basics/home.dart';
import 'places/airport/home.dart' as airport_place;
import 'places/airport/modules/home.dart' as airport_modules;
import 'places/campus/home.dart' as campus_place;
import 'places/campus/modules/home.dart' as campus_modules;
import 'places/hospital/home.dart' as hospital_place;
import 'places/hospital/modules/home.dart' as hospital_modules;
import 'places/landmark/home.dart' as landmark_place;
import 'places/landmark/modules/home.dart' as landmark_modules;
import 'places/market/home.dart' as market_place;
import 'places/market/modules/home.dart' as market_modules;
import 'places/office/home.dart' as office_place;
import 'places/office/modules/home.dart' as office_modules;
import 'places/parking-zone/home.dart' as parking_zone_place;
import 'places/parking-zone/modules/home.dart' as parking_zone_modules;
import 'places/restaurant/home.dart' as restaurant_place;
import 'places/restaurant/modules/home.dart' as restaurant_modules;
import 'splash.dart';

enum _Foreground {
  splash,
  languageSelect,
  nameEntry,
  intro,
  home,
  moduleBasics,
  map,
  destination,
  module,
}

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.isLightMode,
    required this.onLocaleChanged,
    required this.onThemeToggle,
    required this.onResetSettings,
  });

  final bool isLightMode;
  final Future<void> Function(Locale) onLocaleChanged;
  final Future<void> Function() onThemeToggle;
  final Future<void> Function() onResetSettings;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const _locationTransitionDuration = Duration(milliseconds: 750);
  static const _standardTransitionDuration = Duration(milliseconds: 500);

  static const _savedScreenKey = 'kannadaPlaza.screen';
  static const _savedLocationKey = 'kannadaPlaza.location';
  static const _hardRefreshKey = 'kannadaPlaza.hardRefresh';

  static const _homeMusicAsset =
      'audio/music/Raag_Pilu_-_Sandeep_Das_Adhiraj_Chaudhuri_Bivakar_Chaudhuri.mp3';
  static const _cityMusicAsset = 'audio/music/Raga_Legacy_-_Hanu_Dixit.mp3';

  final VideoPlayerController _videoController =
      VideoPlayerController.asset('assets/video/bg_city.mp4');
  final AudioPlayer _homePlayer = AudioPlayer();
  final AudioPlayer _cityPlayer = AudioPlayer();

  _Foreground _foreground = _Foreground.splash;
  CityLocation? _selectedLocation;
  bool _videoReady = false;
  bool _cityMapVisited = false;
  bool _muted = false;
  bool _fadingOut = false;
  bool _splashCoverVisible = false;
  bool _blackTransitionVisible = false;
  bool _homeStarted = false;
  bool _homeStarting = false;
  bool _cityStarted = false;
  bool _cityStarting = false;
  double _homeLevel = 0;
  double _cityLevel = 0;
  int _musicTransitionGeneration = 0;
  bool? _musicTargetCity;
  _Foreground? _resumeAfterSplash;
  browser_session.BrowserRefreshListener? _refreshListener;
  bool _restoring = true;

  @override
  void initState() {
    super.initState();
    if (browser_session.isBrowser) {
      _refreshListener = browser_session.listenForRefreshShortcut(
        _hardRefreshKey,
      );
    }
    unawaited(_initializeVideo());
    unawaited(_homePlayer.setReleaseMode(ReleaseMode.loop));
    unawaited(_cityPlayer.setReleaseMode(ReleaseMode.loop));
    unawaited(_restoreScreen());
  }

  Future<void> _restoreScreen() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final savedName = preferences.getString(_savedScreenKey);
      final savedScreen = _foregroundFromName(savedName);
      final savedLocationName = preferences.getString(_savedLocationKey);
      CityLocation? savedLocation;
      for (final location in cityLocations) {
        if (location.destinationFile == savedLocationName) {
          savedLocation = location;
          break;
        }
      }
      final hardRefresh = _consumeHardRefreshFlag();
      if (savedScreen == _Foreground.map ||
          savedScreen == _Foreground.destination ||
          savedScreen == _Foreground.module) {
        await preloadCityMapAssets(context);
      }

      if (!mounted) return;
      setState(() {
        if (savedScreen == null) {
          _foreground = _Foreground.splash;
        } else if (hardRefresh) {
          _foreground = _Foreground.splash;
          _resumeAfterSplash = savedScreen;
        } else {
          _foreground = savedScreen;
        }
        _selectedLocation = savedScreen == _Foreground.destination ||
                savedScreen == _Foreground.module
            ? savedLocation
            : null;
        _cityMapVisited = savedScreen == _Foreground.map ||
            savedScreen == _Foreground.destination ||
            savedScreen == _Foreground.module;
        _restoring = false;
      });

      if (_foreground == _Foreground.languageSelect ||
          _foreground == _Foreground.nameEntry ||
          _foreground == _Foreground.intro ||
          _foreground == _Foreground.home ||
          _foreground == _Foreground.moduleBasics) {
        unawaited(_startHomeMusic());
      } else if (_foreground == _Foreground.map ||
          _foreground == _Foreground.destination ||
          _foreground == _Foreground.module) {
        unawaited(_startCityMusic());
      }
    } on Object catch (error, stackTrace) {
      debugPrint('Unable to restore last app screen: $error\n$stackTrace');
      if (mounted) setState(() => _restoring = false);
    }
  }

  _Foreground? _foregroundFromName(String? name) {
    for (final screen in _Foreground.values) {
      if (screen.name == name && screen != _Foreground.splash) return screen;
    }
    return null;
  }

  bool _consumeHardRefreshFlag() {
    return browser_session.consumeRefreshShortcut(_hardRefreshKey);
  }

  Future<void> _saveCurrentScreen() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_savedScreenKey, _foreground.name);
      final selected = _selectedLocation;
      if (selected == null) {
        await preferences.remove(_savedLocationKey);
      } else {
        await preferences.setString(
          _savedLocationKey,
          selected.destinationFile,
        );
      }
    } on Object catch (error, stackTrace) {
      debugPrint('Unable to save current app screen: $error\n$stackTrace');
    }
  }

  void _onSplashFinished() {
    if (!mounted) return;
    final next = _resumeAfterSplash ?? _Foreground.languageSelect;
    setState(() {
      _resumeAfterSplash = null;
      _splashCoverVisible = true;
      _foreground = next;
    });
    unawaited(_revealScreenAfterSplash());
    unawaited(_saveCurrentScreen());
    if (next == _Foreground.languageSelect ||
        next == _Foreground.nameEntry ||
        next == _Foreground.intro ||
        next == _Foreground.home ||
        next == _Foreground.moduleBasics) {
      unawaited(_startHomeMusic());
    } else if (next == _Foreground.map ||
        next == _Foreground.destination ||
        next == _Foreground.module) {
      unawaited(_startCityMusic());
    }
  }

  Future<void> _revealScreenAfterSplash() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    if (!mounted) return;
    setState(() => _splashCoverVisible = false);
  }

  Future<void> _initializeVideo() async {
    try {
      await _videoController.initialize();
      final videoSize = _videoController.value.size;
      if (_videoController.value.hasError ||
          videoSize.width <= 0 ||
          videoSize.height <= 0) {
        throw StateError(
          _videoController.value.errorDescription ??
              'City background video has no valid dimensions',
        );
      }
      await _videoController.setLooping(true);
      await _videoController.setVolume(0);
      await _videoController.play();
      if (mounted) setState(() => _videoReady = true);
    } on Object catch (error, stackTrace) {
      debugPrint('Unable to start city background video: $error\n$stackTrace');
    }
  }

  Future<bool> _ensureMusicPlaying({
    required AudioPlayer player,
    required String asset,
    required bool started,
    required bool starting,
    required bool isCity,
  }) async {
    var musicStarted = started;
    if (starting) {
      for (var attempt = 0; attempt < 30; attempt++) {
        final stillStarting = isCity ? _cityStarting : _homeStarting;
        if (!stillStarting) break;
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      musicStarted = isCity ? _cityStarted : _homeStarted;
    }
    if (musicStarted) {
      try {
        if (player.state == PlayerState.paused) await player.resume();
        return true;
      } on Object catch (error, stackTrace) {
        debugPrint('Unable to resume ${isCity ? 'city' : 'home'} music: '
            '$error\n$stackTrace');
        return false;
      }
    }

    if (isCity) {
      _cityStarting = true;
    } else {
      _homeStarting = true;
    }
    try {
      await player.setReleaseMode(ReleaseMode.loop);
      await player.setVolume(0);
      await player.play(AssetSource(asset));
      if (isCity) {
        _cityStarted = true;
        _cityLevel = 0;
      } else {
        _homeStarted = true;
        _homeLevel = 0;
      }
      return true;
    } on Object catch (error, stackTrace) {
      debugPrint('Unable to start ${isCity ? 'city' : 'home'} music; '
          'waiting for user interaction: $error\n$stackTrace');
      return false;
    } finally {
      if (isCity) {
        _cityStarting = false;
      } else {
        _homeStarting = false;
      }
    }
  }

  Future<void> _startHomeMusic() async {
    if (!await _ensureMusicPlaying(
      player: _homePlayer,
      asset: _homeMusicAsset,
      started: _homeStarted,
      starting: _homeStarting,
      isCity: false,
    )) {
      return;
    }
    if (_foreground != _Foreground.home &&
        _foreground != _Foreground.languageSelect &&
        _foreground != _Foreground.nameEntry &&
        _foreground != _Foreground.intro) {
      return;
    }
    await _crossfadeMusic(toCity: false);
  }

  Future<void> _startCityMusic() async {
    if (!await _ensureMusicPlaying(
      player: _cityPlayer,
      asset: _cityMusicAsset,
      started: _cityStarted,
      starting: _cityStarting,
      isCity: true,
    )) {
      return;
    }
    if (_foreground != _Foreground.map &&
        _foreground != _Foreground.destination &&
        _foreground != _Foreground.module) {
      return;
    }
    await _crossfadeMusic(toCity: true);
  }

  Future<void> _crossfadeMusic({required bool toCity}) async {
    if (_musicTargetCity == toCity) return;
    _musicTargetCity = toCity;
    final generation = ++_musicTransitionGeneration;
    final startHome = _homeLevel;
    final startCity = _cityLevel;
    const steps = 30;

    for (var step = 1; step <= steps; step++) {
      if (generation != _musicTransitionGeneration) return;
      final progress = step / steps;
      if (toCity) {
        _homeLevel = startHome * (1 - progress);
      } else {
        _cityLevel = startCity * (1 - progress);
      }
      await Future.wait([_applyHomeVolume(), _applyCityVolume()]);
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }

    if (generation != _musicTransitionGeneration) return;
    final oldPlayer = toCity ? _homePlayer : _cityPlayer;
    final oldStarted = toCity ? _homeStarted : _cityStarted;
    if (oldStarted) {
      try {
        await oldPlayer.pause();
      } on Object catch (error, stackTrace) {
        debugPrint('Unable to pause old music after crossfade: '
            '$error\n$stackTrace');
      }
    }

    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (generation != _musicTransitionGeneration) return;

    final incomingStart = toCity ? startCity : startHome;
    for (var step = 1; step <= steps; step++) {
      if (generation != _musicTransitionGeneration) return;
      final progress = step / steps;
      if (toCity) {
        _cityLevel = incomingStart + (1 - incomingStart) * progress;
      } else {
        _homeLevel = incomingStart + (1 - incomingStart) * progress;
      }
      await Future.wait([_applyHomeVolume(), _applyCityVolume()]);
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  }

  Future<void> _applyHomeVolume() async {
    try {
      await _homePlayer.setVolume(_muted ? 0 : _homeLevel);
    } on Object catch (error, stackTrace) {
      debugPrint('Unable to update home music volume: $error\n$stackTrace');
    }
  }

  void _handleUserInteraction() {
    if (_videoReady && _videoController.value.isInitialized) {
      unawaited(_resumeVideo());
    }
    switch (_foreground) {
      case _Foreground.languageSelect:
      case _Foreground.nameEntry:
      case _Foreground.intro:
      case _Foreground.home:
      case _Foreground.moduleBasics:
        unawaited(_startHomeMusic());
      case _Foreground.map:
      case _Foreground.destination:
      case _Foreground.module:
        unawaited(_startCityMusic());
      case _Foreground.splash:
        break;
    }
  }

  Future<void> _resumeVideo() async {
    if (_videoController.value.isPlaying) return;
    try {
      await _videoController.play();
    } on Object catch (error, stackTrace) {
      debugPrint('Unable to resume city background video: $error\n$stackTrace');
    }
  }

  Future<void> _toggleMute() async {
    setState(() => _muted = !_muted);
    await Future.wait([_applyHomeVolume(), _applyCityVolume()]);
  }

  Future<void> _applyCityVolume() async {
    try {
      await _cityPlayer.setVolume(_muted ? 0 : _cityLevel);
    } on Object catch (error, stackTrace) {
      debugPrint('Unable to update city music volume: $error\n$stackTrace');
    }
  }

  Future<void> _continueFromLanguageSelect() async {
    if (_foreground != _Foreground.languageSelect || _fadingOut) return;
    await widget.onLocaleChanged(Localizations.localeOf(context));
    await _transitionThroughBlack(() async {
      setState(() => _foreground = _Foreground.nameEntry);
      await _saveCurrentScreen();
    });
    unawaited(_startHomeMusic());
  }

  Future<void> _continueFromNameEntry(String userName) async {
    if (_foreground != _Foreground.nameEntry || _fadingOut) return;
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString('user_name', userName);
    } on Object catch (error, stackTrace) {
      debugPrint('Unable to save user name: $error\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to save your name.')),
        );
      }
      return;
    }

    await _transitionThroughBlack(() async {
      setState(() => _foreground = _Foreground.home);
      await _saveCurrentScreen();
    });
    unawaited(_startHomeMusic());
  }

  Future<void> _continueFromIntro() async {
    if (_foreground != _Foreground.intro || _fadingOut) return;
    await _transitionThroughBlack(() async {
      setState(() => _foreground = _Foreground.home);
      await _saveCurrentScreen();
    });
    unawaited(_startHomeMusic());
  }

  Future<void> _transitionThroughBlack(
    Future<void> Function() changeScreen, {
    Duration revealDelay = const Duration(milliseconds: 50),
  }) async {
    if (_blackTransitionVisible) return;
    setState(() => _blackTransitionVisible = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    try {
      await changeScreen();
      await Future<void>.delayed(revealDelay);
    } finally {
      if (mounted) setState(() => _blackTransitionVisible = false);
    }
  }

  Future<void> _openCityMap() async {
    if (_foreground != _Foreground.home || _fadingOut) return;
    try {
      await preloadCityMapAssets(context);
    } on Object catch (error, stackTrace) {
      debugPrint('Unable to load city map assets: $error\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open the city map.')),
        );
      }
      return;
    }
    if (!mounted || _foreground != _Foreground.home || _fadingOut) return;
    setState(() {
      _foreground = _Foreground.map;
      _cityMapVisited = true;
    });
    unawaited(_startCityMusic());
    unawaited(_saveCurrentScreen());
  }

  Future<void> _goHome() async {
    if (_foreground == _Foreground.splash ||
        _foreground == _Foreground.home ||
        _fadingOut) {
      return;
    }
    setState(() => _fadingOut = true);
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    setState(() {
      _selectedLocation = null;
      _foreground = _Foreground.home;
      _fadingOut = false;
    });
    unawaited(_startHomeMusic());
    unawaited(_saveCurrentScreen());
  }

  Future<void> _openDestination(CityLocation location) async {
    if (_foreground != _Foreground.map || _fadingOut) return;
    setState(() => _fadingOut = true);
    await Future<void>.delayed(_locationTransitionDuration);
    if (!mounted) return;
    setState(() {
      _selectedLocation = location;
      _foreground = _Foreground.destination;
      _fadingOut = false;
    });
    unawaited(_saveCurrentScreen());
  }

  Future<void> _returnToMap() async {
    if (_foreground != _Foreground.destination || _fadingOut) return;
    setState(() => _fadingOut = true);
    await Future<void>.delayed(_locationTransitionDuration);
    if (!mounted) return;
    setState(() {
      _selectedLocation = null;
      _foreground = _Foreground.map;
      _fadingOut = false;
    });
    unawaited(_saveCurrentScreen());
  }

  Future<void> _openPlaceModule() async {
    if (_foreground != _Foreground.destination ||
        _selectedLocation == null ||
        _fadingOut) {
      return;
    }
    setState(() => _fadingOut = true);
    await Future<void>.delayed(_locationTransitionDuration);
    if (!mounted) return;
    setState(() {
      _foreground = _Foreground.module;
      _fadingOut = false;
    });
    unawaited(_saveCurrentScreen());
  }

  Future<void> _returnToPlace() async {
    if (_foreground != _Foreground.module || _fadingOut) return;
    setState(() => _fadingOut = true);
    await Future<void>.delayed(_locationTransitionDuration);
    if (!mounted) return;
    setState(() {
      _foreground = _Foreground.destination;
      _fadingOut = false;
    });
    unawaited(_saveCurrentScreen());
  }

  Widget _background() {
    if (_videoReady &&
        _videoController.value.isInitialized &&
        !_videoController.value.hasError &&
        _videoController.value.size.width > 0 &&
        _videoController.value.size.height > 0) {
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: cityCanvasWidth,
            height: cityCanvasHeight,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoController.value.size.width,
                height: _videoController.value.size.height,
                child: VideoPlayer(_videoController),
              ),
            ),
          ),
        ),
      );
    }
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: cityCanvasWidth,
          height: cityCanvasHeight,
          child: Image.asset(
            'assets/images/bg/map_bg.png',
            fit: BoxFit.fill,
            errorBuilder: (context, error, stackTrace) {
              return const ColoredBox(color: Color(0xff050505));
            },
          ),
        ),
      ),
    );
  }

  Widget _foregroundWidget() {
    switch (_foreground) {
      case _Foreground.splash:
        return SplashScreen(
          key: const ValueKey('splash'),
          onFinished: _onSplashFinished,
        );
      case _Foreground.languageSelect:
        return LanguageSelectScreen(
          key: const ValueKey('language-select'),
          selectedLocale: Localizations.localeOf(context),
          onLocaleSelected: widget.onLocaleChanged,
          onNext: () => unawaited(_continueFromLanguageSelect()),
          onUserInteraction: _handleUserInteraction,
        );
      case _Foreground.nameEntry:
        return NameEntryScreen(
          key: const ValueKey('name-entry'),
          onNext: (name) => unawaited(_continueFromNameEntry(name)),
          onUserInteraction: _handleUserInteraction,
        );
      case _Foreground.intro:
        return IntroScreen(
          key: const ValueKey('intro'),
          onContinue: () => unawaited(_continueFromIntro()),
        );
      case _Foreground.home:
        return HomeScreen(
          key: const ValueKey('home'),
          onPlay: _openCityMap,
          onUserInteraction: _handleUserInteraction,
        );
      case _Foreground.moduleBasics:
        return const ModuleBasicsHomeScreen(
          key: ValueKey('module-basics'),
        );
      case _Foreground.map:
        return const SizedBox.shrink();
      case _Foreground.destination:
        final location = _selectedLocation;
        if (location == null) {
          return const ColoredBox(
            key: ValueKey('empty-destination'),
            color: Colors.black,
          );
        }
        final onPlay = () => unawaited(_openPlaceModule());
        return switch (location.name) {
          'Airport / Travel' => airport_place.AirportHomeScreen(
              key: const ValueKey('place-airport'),
              location: location,
              onBackToMap: _returnToMap,
              onPlay: onPlay,
            ),
          'Tourism' => landmark_place.LandmarkHomeScreen(
              key: const ValueKey('place-landmark'),
              location: location,
              onBackToMap: _returnToMap,
              onPlay: onPlay,
            ),
          'Health' => hospital_place.HospitalHomeScreen(
              key: const ValueKey('place-hospital'),
              location: location,
              onBackToMap: _returnToMap,
              onPlay: onPlay,
            ),
          'Education' => campus_place.CampusHomeScreen(
              key: const ValueKey('place-campus'),
              location: location,
              onBackToMap: _returnToMap,
              onPlay: onPlay,
            ),
          'Shopping' => market_place.MarketHomeScreen(
              key: const ValueKey('place-market'),
              location: location,
              onBackToMap: _returnToMap,
              onPlay: onPlay,
            ),
          'Work' => office_place.OfficeHomeScreen(
              key: const ValueKey('place-office'),
              location: location,
              onBackToMap: _returnToMap,
              onPlay: onPlay,
            ),
          'Transport' => parking_zone_place.ParkingZoneHomeScreen(
              key: const ValueKey('place-parking-zone'),
              location: location,
              onBackToMap: _returnToMap,
              onPlay: onPlay,
            ),
          'Food' => restaurant_place.RestaurantHomeScreen(
              key: const ValueKey('place-restaurant'),
              location: location,
              onBackToMap: _returnToMap,
              onPlay: onPlay,
            ),
          _ => const ColoredBox(color: Colors.black),
        };
      case _Foreground.module:
        final location = _selectedLocation;
        if (location == null) {
          return const ColoredBox(
            key: ValueKey('empty-module'),
            color: Colors.black,
          );
        }
        return switch (location.name) {
          'Airport / Travel' => airport_modules.AirportModuleHomeScreen(
              key: const ValueKey('modules-airport'),
              onBack: _returnToPlace,
            ),
          'Tourism' => landmark_modules.LandmarkModuleHomeScreen(
              key: const ValueKey('modules-landmark'),
              onBack: _returnToPlace,
            ),
          'Health' => hospital_modules.HospitalModuleHomeScreen(
              key: const ValueKey('modules-hospital'),
              onBack: _returnToPlace,
            ),
          'Education' => campus_modules.CampusModuleHomeScreen(
              key: const ValueKey('modules-campus'),
              onBack: _returnToPlace,
            ),
          'Shopping' => market_modules.MarketModuleHomeScreen(
              key: const ValueKey('modules-market'),
              onBack: _returnToPlace,
            ),
          'Work' => office_modules.OfficeModuleHomeScreen(
              key: const ValueKey('modules-office'),
              onBack: _returnToPlace,
            ),
          'Transport' => parking_zone_modules.ParkingZoneModuleHomeScreen(
              key: const ValueKey('modules-parking-zone'),
              onBack: _returnToPlace,
            ),
          'Food' => restaurant_modules.RestaurantModuleHomeScreen(
              key: const ValueKey('modules-restaurant'),
              onBack: _returnToPlace,
            ),
          _ => const ColoredBox(color: Colors.black),
        };
    }
  }

  ButtonStyle _popupSecondaryButtonStyle() {
    return TextButton.styleFrom(
      minimumSize: const Size(0, 51),
      padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 17),
      backgroundColor:
          widget.isLightMode ? const Color(0xfff3eaa8) : Colors.black,
      foregroundColor:
          widget.isLightMode ? Colors.black : const Color(0xfff3eaa8),
      side: BorderSide(
        color: widget.isLightMode ? Colors.black : Colors.transparent,
        width: widget.isLightMode ? 1.5 : 0,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textStyle: GoogleFonts.electrolize(fontSize: 22),
    );
  }

  ButtonStyle _popupConfirmButtonStyle() {
    return FilledButton.styleFrom(
      minimumSize: const Size(0, 51),
      padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 17),
      backgroundColor: const Color(0xffe96558),
      foregroundColor: Colors.white,
      side: BorderSide(
        color: widget.isLightMode ? Colors.black : Colors.transparent,
        width: widget.isLightMode ? 1.5 : 0,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textStyle: GoogleFonts.electrolize(fontSize: 22),
    );
  }

  Future<void> _showLanguagePicker() async {
    final selected = await showDialog<LanguageOption>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.chooseLanguage.toUpperCase()),
          titlePadding: const EdgeInsets.fromLTRB(44, 45, 44, 44),
          contentPadding: const EdgeInsets.fromLTRB(44, 46, 44, 44),
          actionsPadding: const EdgeInsets.fromLTRB(44, 5, 44, 35),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          constraints: const BoxConstraints(maxWidth: 710),
          content: SizedBox(
            width: 510,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final option in LanguageOption.all)
                    InkWell(
                      onTap: () => Navigator.pop(context, option),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              option.displayName,
                              textAlign: TextAlign.center,
                            ),
                            if (Localizations.localeOf(context).languageCode ==
                                option.locale.languageCode)
                              const Positioned(
                                right: 12,
                                child: Icon(Icons.check),
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (selected != null) {
      widget.onLocaleChanged(selected.locale);
    }
  }

  Future<void> _resetProgress() async {
    _handleUserInteraction();
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetProgressTitle.toUpperCase()),
        titlePadding: const EdgeInsets.fromLTRB(44, 45, 44, 44),
        contentPadding: const EdgeInsets.fromLTRB(44, 46, 44, 44),
        actionsPadding: const EdgeInsets.fromLTRB(44, 5, 44, 35),
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 24,
        ),
        constraints: const BoxConstraints(maxWidth: 710),
        content: SizedBox(
          width: 510,
          child: Text(l10n.confirmResetProgress),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: _popupSecondaryButtonStyle(),
            child: Text(l10n.no.toUpperCase()),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: _popupConfirmButtonStyle(),
            child: Text(l10n.yes.toUpperCase()),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _transitionThroughBlack(
        () async {
          await widget.onResetSettings();
          if (!mounted) return;
          setState(() {
            _foreground = _Foreground.splash;
            _selectedLocation = null;
            _cityMapVisited = false;
            _resumeAfterSplash = null;
            _splashCoverVisible = false;
          });
        },
        revealDelay: const Duration(milliseconds: 1050),
      );
    } on Object catch (error, stackTrace) {
      debugPrint('Unable to reset saved app settings: $error\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to reset progress.')),
        );
      }
    }
  }

  Future<void> _showCredits() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('CREDITS'),
        titlePadding: const EdgeInsets.fromLTRB(44, 45, 44, 44),
        contentPadding: const EdgeInsets.fromLTRB(44, 46, 44, 44),
        actionsPadding: const EdgeInsets.fromLTRB(44, 5, 44, 35),
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 24,
        ),
        constraints: const BoxConstraints(maxWidth: 710),
        content: SizedBox(
          width: 570,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Developed by Riya Halbhavi',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          softWrap: false,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'LinkedIn',
                    onPressed: () => unawaited(
                      _openCreditLink(
                        'https://in.linkedin.com/in/riya-halbhavi-1a3835441'
                        '?trk=people-guest_people_search-card',
                      ),
                    ),
                    icon: _creditIcon('assets/images/icons/linkedin.png'),
                  ),
                  IconButton(
                    tooltip: 'Instagram',
                    onPressed: () => unawaited(
                      _openCreditLink('https://instagram.com/riyahalbhavi'),
                    ),
                    icon: _creditIcon('assets/images/icons/ig.png'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'Made during '),
                    TextSpan(
                      text: 'Kannada Digital Innovation Hackathon 2026',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    TextSpan(
                      text: ' organized by HackerRank Campus Crew, '
                          'The National Institute of Engineering (NIE), '
                          'Mysuru, Karnataka via Unstop',
                    ),
                  ],
                ),
                style: const TextStyle(height: 1.63),
                softWrap: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: _popupSecondaryButtonStyle(),
            child: Text(AppLocalizations.of(context)!.close.toUpperCase()),
          ),
        ],
      ),
    );
  }

  Future<void> _openCreditLink(String link) async {
    try {
      final opened = await launchUrl(
        Uri.parse(link),
        mode: LaunchMode.externalApplication,
      );
      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open the link.')),
        );
      }
    } on Object catch (error, stackTrace) {
      debugPrint('Unable to open credit link: $error\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open the link.')),
        );
      }
    }
  }

  Widget _creditIcon(String asset) {
    return Image.asset(
      asset,
      width: 28,
      height: 28,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.link, color: Colors.white, size: 28);
      },
    );
  }

  Widget _roundControl({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    final isLightMode = widget.isLightMode;
    final buttonShape = const CircleBorder();
    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: !isLightMode
            ? BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(color: Colors.white38, blurRadius: 8),
                ],
              )
            : null,
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon, size: 28),
          constraints: const BoxConstraints.tightFor(width: 60, height: 60),
          style: IconButton.styleFrom(
            backgroundColor: isLightMode ? Colors.white : Colors.black,
            foregroundColor: isLightMode ? Colors.black : Colors.white,
            shape: buttonShape,
            side: BorderSide(
              color: Colors.black,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _screenControls() {
    final l10n = AppLocalizations.of(context)!;
    final foregroundColor = widget.isLightMode ? Colors.black : Colors.white;
    return Positioned(
      right: 18,
      bottom: 18,
      left: 18,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final resetButton = TextButton.icon(
              onPressed: () => unawaited(_resetProgress()),
              icon: const Icon(Icons.restart_alt, size: 24),
              label: Text(l10n.resetProgress),
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 60),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xffe96558),
                textStyle: GoogleFonts.electrolize(fontSize: 16),
                side: BorderSide(
                  color: widget.isLightMode ? Colors.black : Colors.transparent,
                  width: widget.isLightMode ? 1.5 : 0,
                ),
              ),
            );
            final styledResetButton = resetButton;
            final rightControls = Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 6,
              children: [
                _roundControl(
                  icon: Icons.language,
                  tooltip: l10n.chooseLanguage,
                  onPressed: () {
                    _handleUserInteraction();
                    unawaited(_showLanguagePicker());
                  },
                ),
                _roundControl(
                  icon: _muted ? Icons.volume_off : Icons.volume_up,
                  tooltip: _muted ? l10n.unmuteAudio : l10n.muteAudio,
                  onPressed: () {
                    _handleUserInteraction();
                    unawaited(_toggleMute());
                  },
                ),
                _roundControl(
                  icon: widget.isLightMode ? Icons.dark_mode : Icons.light_mode,
                  tooltip: widget.isLightMode
                      ? l10n.switchToDarkMode
                      : l10n.switchToLightMode,
                  onPressed: () => unawaited(widget.onThemeToggle()),
                ),
                Container(
                  decoration: !widget.isLightMode
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(color: Colors.white38, blurRadius: 8),
                          ],
                        )
                      : null,
                  child: TextButton(
                    onPressed: () => unawaited(_showCredits()),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(0, 60),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      foregroundColor: foregroundColor,
                      backgroundColor:
                          widget.isLightMode ? Colors.white : Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide(
                        color: widget.isLightMode
                            ? Colors.black
                            : Colors.transparent,
                        width: widget.isLightMode ? 1.5 : 0,
                      ),
                    ),
                    child: const Text('CREDITS'),
                  ),
                ),
              ],
            );

            if (constraints.maxWidth < 760) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: styledResetButton,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: rightControls,
                  ),
                ],
              );
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                styledResetButton,
                const SizedBox(width: 8),
                Flexible(child: rightControls),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _homeNavigationButton() {
    final l10n = AppLocalizations.of(context)!;
    return Positioned(
      top: 20,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Tooltip(
            message: l10n.backToHome,
            child: IconButton.filled(
              onPressed: () {
                _handleUserInteraction();
                unawaited(_goHome());
              },
              icon: const Icon(Icons.home, size: 30),
              constraints: const BoxConstraints.tightFor(
                width: 62,
                height: 62,
              ),
              style: IconButton.styleFrom(
                backgroundColor:
                    widget.isLightMode ? Colors.white : Colors.black,
                foregroundColor:
                    widget.isLightMode ? Colors.black : Colors.white,
                shape: const CircleBorder(),
                side: BorderSide(
                  color: Colors.black,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _refreshListener?.dispose();
    _videoController.dispose();
    unawaited(_homePlayer.dispose());
    unawaited(_cityPlayer.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_restoring) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: SizedBox.expand(),
      );
    }
    return Listener(
      onPointerDown: (_) => _handleUserInteraction(),
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            _background(),
            if (_cityMapVisited)
              AnimatedOpacity(
                opacity: _foreground == _Foreground.map && !_fadingOut ? 1 : 0,
                duration: _foreground == _Foreground.map ||
                        _foreground == _Foreground.destination ||
                        _foreground == _Foreground.module
                    ? _locationTransitionDuration
                    : _standardTransitionDuration,
                curve: Curves.easeInOut,
                child: Offstage(
                  offstage: _foreground != _Foreground.map,
                  child: CityMapScreen(
                    key: const ValueKey('map'),
                    onSelectLocation: _openDestination,
                    onUserInteraction: _handleUserInteraction,
                  ),
                ),
              ),
            AnimatedOpacity(
              opacity: _fadingOut ? 0 : 1,
              duration: _foreground == _Foreground.map ||
                      _foreground == _Foreground.destination ||
                      _foreground == _Foreground.module
                  ? _locationTransitionDuration
                  : _standardTransitionDuration,
              curve: Curves.easeInOut,
              child: _foreground == _Foreground.map
                  ? const SizedBox.shrink()
                  : _foregroundWidget(),
            ),
            IgnorePointer(
              child: AnimatedOpacity(
                opacity: _splashCoverVisible ? 1 : 0,
                duration: _splashCoverVisible
                    ? Duration.zero
                    : const Duration(milliseconds: 900),
                curve: Curves.easeInOut,
                child: const ColoredBox(color: Colors.white),
              ),
            ),
            IgnorePointer(
              child: AnimatedOpacity(
                opacity: _blackTransitionVisible ? 1 : 0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                child: const ColoredBox(color: Colors.black),
              ),
            ),
            if (_foreground != _Foreground.splash) ...[
              _screenControls(),
              if (_foreground != _Foreground.home &&
                  _foreground != _Foreground.languageSelect &&
                  _foreground != _Foreground.nameEntry &&
                  _foreground != _Foreground.intro)
                _homeNavigationButton(),
            ],
          ],
        ),
      ),
    );
  }
}
