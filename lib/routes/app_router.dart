import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

// ── Screens (stubs for now, filled in one by one) ─────────────────────────────
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/onboarding/profile_setup_screen.dart';
import '../screens/shell/main_shell.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/activity/activity_screen.dart';
import '../screens/diet/diet_screen.dart';
import '../screens/companion/companion_screen.dart';
import '../screens/profile/profile_screen.dart';

// ── Route paths ───────────────────────────────────────────────────────────────
class AppRoutes {
  // Auth
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';

  // Onboarding
  static const profileSetup = '/profile-setup';

  // Main tabs
  static const dashboard = '/dashboard';
  static const activity = '/activity';
  static const diet = '/diet';
  static const companion = '/companion';
  static const profile = '/profile';
}

// ── Router factory ────────────────────────────────────────────────────────────
GoRouter createRouter(BuildContext context) {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);

  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: authProvider,
    redirect: (context, state) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final isAuth = auth.isAuthenticated;
      final isOnAuthPage = state.fullPath == AppRoutes.login ||
          state.fullPath == AppRoutes.register ||
          state.fullPath == AppRoutes.forgotPassword;

      if (auth.status == AuthStatus.unknown) return null;
      if (!isAuth && !isOnAuthPage) return AppRoutes.login;
      if (isAuth && isOnAuthPage) {
        if (!auth.isProfileComplete) return AppRoutes.profileSetup;
        return AppRoutes.dashboard;
      }
      return null;
    },
    routes: [
      // ── Auth ───────────────────────────────────────────────────────────────
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(
          path: AppRoutes.register, builder: (_, __) => const RegisterScreen()),
      GoRoute(
          path: AppRoutes.forgotPassword,
          builder: (_, __) => const ForgotPasswordScreen()),

      // ── Onboarding ─────────────────────────────────────────────────────────
      GoRoute(
          path: AppRoutes.profileSetup,
          builder: (_, __) => const ProfileSetupScreen()),

      // ── Main shell with bottom nav ─────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
              path: AppRoutes.dashboard,
              builder: (_, __) => const DashboardScreen()),
          GoRoute(
              path: AppRoutes.activity,
              builder: (_, __) => const ActivityScreen()),
          GoRoute(path: AppRoutes.diet, builder: (_, __) => const DietScreen()),
          GoRoute(
              path: AppRoutes.companion,
              builder: (_, __) => const CompanionScreen()),
          GoRoute(
              path: AppRoutes.profile,
              builder: (_, __) => const ProfileScreen()),
        ],
      ),
    ],
  );
}
