import 'package:flutter/material.dart';

class RestaurantModuleHomeScreen extends StatelessWidget {
  const RestaurantModuleHomeScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    final foreground = isLightMode ? Colors.black : Colors.white;
    return Scaffold(
      backgroundColor:
          isLightMode ? const Color(0xfff2f3f5) : const Color(0xff050505),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 18,
              left: 18,
              child: FilledButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back, size: 24),
                label: const Text('BACK TO RESTAURANT'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 60),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  backgroundColor:
                      isLightMode ? const Color(0xfff3eaa8) : Colors.black,
                  foregroundColor: foreground,
                  side: BorderSide(color: foreground, width: 1.5),
                ),
              ),
            ),
            Center(
              child: Text(
                'RESTAURANT MODULES',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: foreground,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
