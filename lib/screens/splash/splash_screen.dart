import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../providers/auth_provider.dart';
import '../../routes/app_router.dart';
import '../../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startSplash();
  }

  Future<void> _startSplash() async {
    // Wait for the gorgeous animation to finish (2 seconds)
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);

    // If still getting auth info, wait a tiny bit more
    while (auth.status == AuthStatus.unknown || (auth.isAuthenticated && auth.isLoadingProfile)) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;
    }

    if (auth.isAuthenticated) {
      if (auth.isProvider) {
        context.go(AppRoutes.providerDashboard);
      } else {
        if (auth.isProfileComplete) {
          context.go(AppRoutes.dashboard);
        } else {
          context.go(AppRoutes.profileSetup);
        }
      }
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Image
            Image.asset(
              'assets/images/logo.png',
              width: 140,
              height: 140,
            )
            .animate()
            .scale(duration: 800.ms, curve: Curves.easeOutBack, begin: const Offset(0.5, 0.5))
            .fadeIn(duration: 800.ms)
            .shimmer(delay: 800.ms, duration: 1500.ms, color: AppColors.primary.withOpacity(0.4)),
            
            const SizedBox(height: 30),
            
            // App Name (AURA)
            const Text(
              'AURA',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 8,
              ),
            )
            .animate(delay: 400.ms)
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.5, end: 0, duration: 600.ms, curve: Curves.easeOutQuad),
            
            const SizedBox(height: 12),
            
            // Tagline
            const Text(
              'Your Virtual Health Companion',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                letterSpacing: 1.2,
              ),
            )
            .animate(delay: 800.ms)
            .fadeIn(duration: 600.ms),
          ],
        ),
      ),
    );
  }
}
