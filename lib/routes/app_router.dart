import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

// ── Screens ───────────────────────────────────────────────────────────────────
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/onboarding/profile_setup_screen.dart';
import '../screens/shell/main_shell.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/analytics/analytics_screen.dart';
import '../screens/tracker/tracker_screen.dart';
import '../screens/activity/activity_screen.dart';
import '../screens/diet/diet_screen.dart';
import '../screens/companion/companion_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/goals/goals_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/appointments/appointments_screen.dart';
import '../screens/share/share_health_screen.dart';
import '../screens/health/hospital_locator_screen.dart';
import '../screens/health/provider_chat_screen.dart';
// Provider portal
import '../screens/provider/provider_dashboard_screen.dart';
import '../screens/provider/patient_detail_screen.dart';
import '../screens/provider/add_report_screen.dart';
import '../screens/provider/patient_chat_screen.dart';

// ── Route paths ───────────────────────────────────────────────────────────────
class AppRoutes {
  // Auth
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';

  // Onboarding (patient only)
  static const profileSetup = '/profile-setup';

  // Patient tabs
  static const dashboard = '/dashboard';
  static const analytics = '/analytics';
  static const tracker = '/tracker';
  static const activity = '/activity';
  static const diet = '/diet';
  static const companion = '/companion';
  static const profile = '/profile';
  static const editProfile = '/profile/edit';
  static const goals = '/goals';
  static const notifications = '/notifications';
  static const settings = '/settings';
  static const appointments = '/appointments';
  static const shareHealth = '/share-health';
  static const hospitalLocator = '/hospital-locator';
  static const chatWithProvider = '/chat-provider';

  // Provider portal
  static const providerDashboard = '/provider/dashboard';
  static const providerPatientDetail = '/provider/patient';
  static const providerAddReport = '/provider/report';
  static const providerChatPatient = '/provider/chat';
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
      final path = state.fullPath ?? '';

      final isOnAuthPage = path == AppRoutes.login ||
          path == AppRoutes.register ||
          path == AppRoutes.forgotPassword;

      if (auth.status == AuthStatus.unknown) return null;
      if (isAuth && auth.isLoadingProfile) return null;

      // Unauthenticated → login
      if (!isAuth && !isOnAuthPage) return AppRoutes.login;

      if (isAuth && !auth.isLoadingProfile) {
        // ── Provider branch ──────────────────────────────────────────────────
        if (auth.isProvider) {
          final isOnProviderPage = path.startsWith('/provider');
          if (isOnAuthPage) return AppRoutes.providerDashboard;
          if (!isOnProviderPage && !isOnAuthPage) return AppRoutes.providerDashboard;
          return null;
        }

        // ── Patient branch ───────────────────────────────────────────────────
        final isSetupPage = path == AppRoutes.profileSetup;
        if (!auth.isProfileComplete && !isSetupPage) return AppRoutes.profileSetup;
        if (auth.isProfileComplete && (isOnAuthPage || isSetupPage)) {
          return AppRoutes.dashboard;
        }
      }
      return null;
    },
    routes: [
      // ── Auth ──────────────────────────────────────────────────────────────
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(path: AppRoutes.register, builder: (_, __) => const RegisterScreen()),
      GoRoute(path: AppRoutes.forgotPassword, builder: (_, __) => const ForgotPasswordScreen()),

      // ── Onboarding ────────────────────────────────────────────────────────
      GoRoute(path: AppRoutes.profileSetup, builder: (_, __) => const ProfileSetupScreen()),

      // ── Patient Shell with bottom nav ─────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: AppRoutes.dashboard, builder: (_, __) => const DashboardScreen()),
          GoRoute(path: AppRoutes.analytics, builder: (_, __) => const AnalyticsScreen()),
          GoRoute(path: AppRoutes.tracker, builder: (_, __) => const TrackerScreen()),
          GoRoute(path: AppRoutes.companion, builder: (_, __) => const CompanionScreen()),
          GoRoute(path: AppRoutes.profile, builder: (_, __) => const ProfileScreen()),
        ],
      ),

      // ── Patient Overlayed Screens ──────────────────────────────────────────
      GoRoute(path: AppRoutes.editProfile, builder: (_, __) => const EditProfileScreen()),
      GoRoute(path: AppRoutes.activity, builder: (_, __) => const ActivityScreen()),
      GoRoute(path: AppRoutes.diet, builder: (_, __) => const DietScreen()),
      GoRoute(path: AppRoutes.goals, builder: (_, __) => const GoalsScreen()),
      GoRoute(path: AppRoutes.notifications, builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: AppRoutes.settings, builder: (_, __) => const SettingsScreen()),
      GoRoute(path: AppRoutes.appointments, builder: (_, __) => const AppointmentsScreen()),
      GoRoute(path: AppRoutes.shareHealth, builder: (_, __) => const ShareHealthScreen()),
      GoRoute(path: AppRoutes.hospitalLocator, builder: (_, __) => const HospitalLocatorScreen()),
      GoRoute(path: AppRoutes.chatWithProvider, builder: (_, __) => const ProviderChatScreen()),

      // ── Provider Portal ────────────────────────────────────────────────────
      GoRoute(path: AppRoutes.providerDashboard, builder: (_, __) => const ProviderDashboardScreen()),
      GoRoute(
        path: '${AppRoutes.providerPatientDetail}/:uid',
        builder: (_, state) => PatientDetailScreen(patientUid: state.pathParameters['uid']!),
      ),
      GoRoute(
        path: '${AppRoutes.providerAddReport}/:uid',
        builder: (_, state) => AddReportScreen(patientUid: state.pathParameters['uid']!),
      ),
      GoRoute(
        path: '${AppRoutes.providerChatPatient}/:uid',
        builder: (_, state) {
          final patientName = state.uri.queryParameters['name'] ?? 'Patient';
          return PatientChatScreen(
            patientUid: state.pathParameters['uid']!,
            patientName: patientName,
          );
        },
      ),
    ],
  );
}
