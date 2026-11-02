import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/generated/app_localizations.dart';

const _pastelYellow = Color(0xfff3eaa8);
const _darkBackground = Color(0xff050505);

class AppPanel extends StatelessWidget {
  const AppPanel({
    super.key,
    required this.child,
    this.transparentInLightMode = false,
  });

  final Widget child;
  final bool transparentInLightMode;

  @override
  Widget build(BuildContext context) {
    final darkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 61, vertical: 81),
      decoration: BoxDecoration(
        color: darkMode
            ? Colors.black
            : transparentInLightMode
                ? Colors.transparent
                : Colors.white,
        border: Border.all(
          color: darkMode ? Colors.white : const Color(0xff101010),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: darkMode
            ? const [BoxShadow(color: Colors.white54, blurRadius: 16)]
            : null,
      ),
      child: child,
    );
  }
}

class HomeLeftPanel extends StatefulWidget {
  const HomeLeftPanel({
    super.key,
    required this.onPlay,
    required this.onUserInteraction,
    this.imagePath = 'assets/images/bg/home_bg_left.png',
    this.imageRevealDelay = Duration.zero,
    this.showPlayButton = true,
  });

  final VoidCallback onPlay;
  final VoidCallback onUserInteraction;
  final String imagePath;
  final Duration imageRevealDelay;
  final bool showPlayButton;

  @override
  State<HomeLeftPanel> createState() => _HomeLeftPanelState();
}

class _HomeLeftPanelState extends State<HomeLeftPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;
  late final Animation<double> _verticalOffset;
  bool _playHovered = false;
  bool _imageVisible = false;
  Timer? _imageRevealTimer;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _verticalOffset = Tween<double>(begin: -4, end: 4).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _imageRevealTimer = Timer(widget.imageRevealDelay, () {
        if (mounted) setState(() => _imageVisible = true);
      });
    });
  }

  @override
  void dispose() {
    _imageRevealTimer?.cancel();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final characterImage = Image.asset(
      widget.imagePath,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(
          Icons.person_outline,
          color: _pastelYellow,
          size: 210,
        );
      },
    );

    return SizedBox(
      width: 335,
      height: 405,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          AnimatedOpacity(
            opacity: _imageVisible ? 1 : 0,
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
            child: AnimatedBuilder(
              animation: _verticalOffset,
              child: OverflowBox(
                maxWidth: 535,
                maxHeight: 605,
                child: SizedBox(
                  width: 535,
                  height: 605,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
                        child: ColorFiltered(
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                          child: Opacity(
                            opacity: 1,
                            child: characterImage,
                          ),
                        ),
                      ),
                      characterImage,
                    ],
                  ),
                ),
              ),
              builder: (context, child) => Transform.translate(
                offset: Offset(0, _verticalOffset.value),
                child: child,
              ),
            ),
          ),
          if (widget.showPlayButton)
            Align(
              alignment: Alignment.center,
              child: AnimatedScale(
                scale: _playHovered ? 1.03 : 1,
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOut,
                child: FilledButton(
                  onHover: (hovered) {
                    if (_playHovered != hovered) {
                      setState(() => _playHovered = hovered);
                    }
                  },
                  onPressed: () {
                    widget.onUserInteraction();
                    widget.onPlay();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: const RoundedRectangleBorder(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 84,
                      vertical: 15.5,
                    ),
                    side: BorderSide(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : Colors.transparent,
                      width: Theme.of(context).brightness == Brightness.light
                          ? 1.5
                          : 0,
                    ),
                    shadowColor: Colors.white,
                    elevation: Theme.of(context).brightness == Brightness.light
                        ? 0
                        : 14,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.play,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
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

class HomeProfileContent extends StatelessWidget {
  const HomeProfileContent({
    super.key,
    required this.title,
    required this.onShowGoodies,
    this.isDestination = false,
  });

  final String title;
  final VoidCallback onShowGoodies;
  final bool isDestination;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    final themeText = isLightMode ? const Color(0xff0f1217) : Colors.white;
    final subheadingColor =
        isDestination && isLightMode ? Colors.black : _pastelYellow;
    final countStyle = TextStyle(
      color: _pastelYellow,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );
    final bestScoreStyle = countStyle.copyWith(
      color: isDestination && isLightMode
          ? const Color(0xff444444)
          : const Color(0xffffdae9),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: themeText,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.juniorDreamEngineer,
            style: const TextStyle(
              color: _pastelYellow,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              height: 1.32,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Divider(color: Color(0xb3f3eaa8), height: 1),
          ),
          Text(
            l10n.bestScore,
            style: TextStyle(color: subheadingColor),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: _pastelYellow.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.minigameName,
                  style: TextStyle(
                    color: isLightMode ? Colors.black54 : Colors.white54,
                    fontSize: 12,
                  ),
                ),
                Text('0', style: bestScoreStyle),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.lessonsCompleted,
                  style: TextStyle(color: subheadingColor),
                ),
                Text('0/80', style: countStyle),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.specialGoodiesUnlocked,
                  style: TextStyle(color: subheadingColor, fontSize: 13),
                ),
                Text('0/10', style: countStyle),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (var index = 1; index <= 4; index++)
                Container(
                  width: 44,
                  height: 44,
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: _pastelYellow.withValues(alpha: 0.4)),
                  ),
                  child: _GoodieImage(
                    path: 'assets/images/goodie_$index.png',
                    size: 28,
                  ),
                ),
              TextButton(
                onPressed: onShowGoodies,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.arrow_forward, size: 18),
                    Text(l10n.more, style: const TextStyle(fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onPlay,
    required this.onUserInteraction,
  });

  final Future<void> Function() onPlay;
  final VoidCallback onUserInteraction;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _contentVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _contentVisible = true);
    });
  }

  Future<void> _showGoodiesDialog() async {
    widget.onUserInteraction();
    final l10n = AppLocalizations.of(context)!;
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.specialGoodiesUnlocked.toUpperCase()),
        contentPadding: const EdgeInsets.fromLTRB(44, 46, 44, 44),
        titlePadding: const EdgeInsets.fromLTRB(44, 45, 44, 44),
        actionsPadding: const EdgeInsets.fromLTRB(44, 5, 44, 35),
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 24,
        ),
        constraints: const BoxConstraints(maxWidth: 710),
        content: SizedBox(
          width: 670,
          child: GridView.builder(
            shrinkWrap: true,
            itemCount: 10,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Expanded(
                    child: _GoodieImage(
                      path: 'assets/images/goodie_${index + 1}.png',
                      size: 38,
                    ),
                  ),
                  Text(
                    l10n.goodieNumber(index + 1),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 51),
              padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 17),
              backgroundColor: isLightMode ? _pastelYellow : Colors.black,
              foregroundColor: isLightMode ? Colors.black : _pastelYellow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              side: BorderSide(
                color: isLightMode ? Colors.black : Colors.transparent,
                width: isLightMode ? 1.5 : 0,
              ),
              textStyle: GoogleFonts.electrolize(fontSize: 22),
            ),
            child: Text(l10n.close.toUpperCase()),
          ),
        ],
      ),
    );
  }

  Widget _homeContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 760;
        final character = FittedBox(
          fit: BoxFit.scaleDown,
          child: HomeLeftPanel(
            onPlay: () => unawaited(widget.onPlay()),
            onUserInteraction: widget.onUserInteraction,
          ),
        );
        final profile = ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: HomeProfileContent(
            title: AppLocalizations.of(context)!.welcomeTitle,
            onShowGoodies: _showGoodiesDialog,
          ),
        );
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1210),
            child: wide
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Center(child: character),
                      ),
                      const SizedBox(width: 40),
                      Expanded(flex: 6, child: profile),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      character,
                      const SizedBox(height: 20),
                      profile,
                    ],
                  ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    final background = isLightMode ? const Color(0xfff2f3f5) : _darkBackground;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        color: background,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1210),
                        child: AnimatedOpacity(
                          opacity: _contentVisible ? 1 : 0,
                          duration: const Duration(milliseconds: 2500),
                          curve: Curves.easeOutCubic,
                          child: AppPanel(
                            transparentInLightMode: true,
                            child: _homeContent(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GoodieImage extends StatelessWidget {
  const _GoodieImage({required this.path, required this.size});

  final String path;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.auto_awesome_outlined,
          size: size * 0.75,
          color: _pastelYellow.withValues(alpha: 0.6),
        );
      },
    );
  }
}
