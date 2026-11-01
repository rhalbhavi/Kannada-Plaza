import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';

const _pastelYellow = Color(0xfff3eaa8);
const _darkBackground = Color(0xff050505);

class AppPanel extends StatelessWidget {
  const AppPanel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final darkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 41, vertical: 46),
      decoration: BoxDecoration(
        color: darkMode ? Colors.black : Colors.white,
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

class HomeLeftPanel extends StatelessWidget {
  const HomeLeftPanel({
    super.key,
    required this.onPlay,
    required this.onUserInteraction,
    this.imagePath = 'assets/images/home_left.png',
  });

  final VoidCallback onPlay;
  final VoidCallback onUserInteraction;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 335,
      height: 405,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.person_outline,
                  color: _pastelYellow,
                  size: 210,
                );
              },
            ),
          ),
          Positioned(
            top: 250,
            child: FilledButton(
              onPressed: () {
                onUserInteraction();
                onPlay();
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: const RoundedRectangleBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 39,
                  vertical: 17,
                ),
                side: const BorderSide(color: Colors.transparent),
                shadowColor: Colors.white,
                elevation:
                    Theme.of(context).brightness == Brightness.light ? 0 : 14,
              ),
              child: Text(
                AppLocalizations.of(context)!.play,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
            ),
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
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.specialGoodiesUnlocked.toUpperCase()),
        contentPadding: const EdgeInsets.fromLTRB(29, 31, 29, 29),
        titlePadding: const EdgeInsets.all(29),
        actionsPadding: const EdgeInsets.fromLTRB(29, 0, 29, 29),
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 24,
        ),
        constraints: const BoxConstraints(maxWidth: 610),
        content: SizedBox(
          width: 570,
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
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  Widget _profile(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    final themeText = isLightMode ? const Color(0xff0f1217) : Colors.white;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.welcomeTitle,
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
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 18),
          child: Divider(color: Color(0xb3f3eaa8), height: 1),
        ),
        Text(
          l10n.bestScore,
          style: TextStyle(color: _pastelYellow.withValues(alpha: 0.9)),
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
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const Text(
                '0/80',
                style: TextStyle(
                  color: Color(0xffffdae9),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.lessonsCompleted,
              style: TextStyle(color: _pastelYellow.withValues(alpha: 0.9)),
            ),
            const Text(
              '0/80',
              style: TextStyle(
                color: Color(0xffffdae9),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.specialGoodiesUnlocked,
              style: TextStyle(color: _pastelYellow, fontSize: 13),
            ),
            Text(
              '0/10',
              style: TextStyle(color: _pastelYellow.withValues(alpha: 0.9)),
            ),
          ],
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
              onPressed: _showGoodiesDialog,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_forward, size: 18),
                  Text(l10n.more, style: const TextStyle(fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ],
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
          child: _profile(context),
        );
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1140),
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
                        constraints: const BoxConstraints(maxWidth: 1140),
                        child: AnimatedOpacity(
                          opacity: _contentVisible ? 1 : 0,
                          duration: const Duration(milliseconds: 2500),
                          curve: Curves.easeOutCubic,
                          child: AppPanel(
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
