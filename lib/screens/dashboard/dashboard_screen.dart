import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../providers/auth_provider.dart';
import '../../providers/metrics_provider.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_router.dart';
import '../../services/firestore_service.dart';

String _getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good Morning';
  if (hour < 17) return 'Good Afternoon';
  return 'Good Evening';
}

String _getAuraInsight(int steps, int waterMl, int sleepMinutes) {
  if (steps < 3000) {
    return "Start your day with a short walk — even 10 minutes makes a difference! 🚶";
  }
  if (waterMl < 500) {
    return "Don't forget to hydrate! Aim for at least 2L of water today. 💧";
  }
  if (sleepMinutes < 360 && DateTime.now().hour > 20) {
    return "Getting 7–8 hours of sleep is key to recovery. Try to rest soon! 😴";
  }
  if (steps > 8000) {
    return "Excellent work — you're almost at your step goal! Keep it up! 🔥";
  }
  return "Looking good! Keep logging your health data to stay on track with AURA! ✨";
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isConnected = false;
  String _connectedDevice = '';

  void _showConnectDeviceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => _DeviceConnectionSheet(
        onConnected: (device) {
          setState(() {
            _isConnected = true;
            _connectedDevice = device;
          });
          // After returning to the main screen, we can populate some fake data
          // if we want, or just let it be a visual confirmation.
          _syncBiomarkerData();
        },
      ),
    );
  }

  Future<void> _syncBiomarkerData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.user;
    if (user == null) return;
    
    // Simulate syncing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Syncing data from $_connectedDevice...'),
        duration: const Duration(seconds: 2),
      )
    );
    
    await Future.delayed(const Duration(seconds: 2));
    
    try {
      // populate fake biometric data
      await FirestoreService().updateMetric(
         userId: user.uid,
         heartRate: 72 + (DateTime.now().second % 10), // mock heart rate 72-81
         oxygenSaturation: 98.0 + (DateTime.now().microsecond % 2), // mock SpO2 98-99
         bloodGlucose: 95.0,
      );
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text('✅ Data successfully synced from $_connectedDevice'),
             backgroundColor: AppColors.success,
           ),
         );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final metricsProvider = Provider.of<MetricsProvider>(context);
    final today = metricsProvider.todayMetrics;
    final username = auth.userProfile?.username ??
        auth.user?.email?.split('@')[0] ??
        'Explorer';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App Bar ──
            SliverAppBar(
              floating: true,
              backgroundColor: AppColors.background,
              elevation: 0,
              centerTitle: false,
              title: Row(
                children: [
                  Image.asset('assets/images/logo.png', height: 42),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_getGreeting(),
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13)),
                      Text(
                        username,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withAlpha(30)),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.notifications_outlined,
                        color: AppColors.textPrimary),
                    onPressed: () => context.push(AppRoutes.notifications),
                  ),
                ),
              ],
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── AURA Insight Card ──
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.companion),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          border:
                              Border.all(color: AppColors.primary.withAlpha(30)),
                        ),
                        child: Row(
                          children: [
                            ClipOval(
                              child: Image.asset(
                                'assets/images/aura_avatar.png',
                                width: 52,
                                height: 52,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withAlpha(20),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.auto_awesome,
                                      color: AppColors.primary, size: 28),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'AURA Insight',
                                    style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _getAuraInsight(
                                      today?.steps ?? 0,
                                      today?.waterIntakeMl ?? 0,
                                      today?.sleepMinutes ?? 0,
                                    ),
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                        height: 1.4),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Chat with AURA →',
                                    style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .fade(duration: 600.ms)
                        .slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 20),

                    // ── Device Connection Banner ──
                    GestureDetector(
                      onTap: _isConnected ? null : () => _showConnectDeviceSheet(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                           gradient: LinearGradient(
                             colors: _isConnected 
                                  ? [AppColors.success.withAlpha(200), AppColors.success]
                                  : [const Color(0xFF2B2B36), const Color(0xFF383846)],
                             begin: Alignment.topLeft,
                             end: Alignment.bottomRight,
                           ),
                           borderRadius: BorderRadius.circular(20),
                           boxShadow: [
                             BoxShadow(
                               color: (_isConnected ? AppColors.success : Colors.black).withAlpha(40),
                               blurRadius: 10,
                               offset: const Offset(0, 4)
                             )
                           ]
                        ),
                        child: Row(
                          children: [
                             Container(
                               padding: const EdgeInsets.all(10),
                               decoration: BoxDecoration(
                                 color: Colors.white.withAlpha(30),
                                 shape: BoxShape.circle,
                               ),
                               child: Icon(
                                 _isConnected ? Icons.watch : Icons.watch_outlined, 
                                 color: Colors.white, 
                                 size: 24
                               ),
                             ),
                             const SizedBox(width: 16),
                             Expanded(
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   Text(
                                     _isConnected ? 'Connected to $_connectedDevice' : 'Connect Smartwatch',
                                     style: const TextStyle(
                                       color: Colors.white, 
                                       fontWeight: FontWeight.bold,
                                       fontSize: 15
                                     ),
                                   ),
                                   const SizedBox(height: 4),
                                   Text(
                                     _isConnected ? 'Syncing health data automatically' : 'Sync your biomarkers (HR, SpO2) effortlessly',
                                     style: TextStyle(
                                       color: Colors.white.withAlpha(200),
                                       fontSize: 12
                                     ),
                                   ),
                                 ],
                               ),
                             ),
                             if (!_isConnected)
                               const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
                          ],
                        ),
                      ),
                    ).animate().fade(delay: 100.ms).slideY(begin: 0.1),

                    const SizedBox(height: 36),
                    const Text("Today's Activity",
                            style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold))
                        .animate()
                        .fade(delay: 200.ms),
                    const SizedBox(height: 16),

                    // ── Metrics Grid ──
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 0.85,
                      children: [
                        _MetricCard(
                          title: 'Steps',
                          value: (today?.steps ?? 0).toString(),
                          unit: '/ 10k',
                          icon: Icons.directions_walk,
                          color: AppColors.steps,
                          progress: (today?.steps ?? 0) / 10000,
                          onTap: () => context.push(AppRoutes.activity),
                        ),
                        _MetricCard(
                          title: 'Calories',
                          value: (today?.caloriesBurned ?? 0).toString(),
                          unit: 'kcal',
                          icon: Icons.local_fire_department,
                          color: AppColors.calories,
                          progress: (today?.caloriesBurned ?? 0) / 600,
                          onTap: () => context.push(AppRoutes.activity),
                        ),
                        _MetricCard(
                          title: 'Water',
                          value: (today?.waterIntakeMl ?? 0).toString(),
                          unit: 'ml',
                          icon: Icons.water_drop,
                          color: AppColors.water,
                          progress: (today?.waterIntakeMl ?? 0) / 2500,
                        ),
                        _MetricCard(
                          title: 'Sleep',
                          value:
                              '${(today?.sleepMinutes ?? 0) ~/ 60}h ${(today?.sleepMinutes ?? 0) % 60}m',
                          unit: '',
                          icon: Icons.nights_stay,
                          color: AppColors.sleep,
                          progress: (today?.sleepMinutes ?? 0) / 480,
                        ),
                      ]
                          .animate(interval: 100.ms)
                          .fade(duration: 500.ms)
                          .scale(begin: const Offset(0.9, 0.9)),
                    ),

                    const SizedBox(height: 36),
                    const Text("Quick Actions",
                            style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold))
                        .animate()
                        .fade(delay: 400.ms),
                    const SizedBox(height: 16),

                    // ── Quick Actions Grid ──
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 2.0,
                      children: [
                        _QuickActionCard(
                            label: 'Log Health',
                            icon: Icons.add_chart,
                            color: AppColors.primary,
                            onTap: () => context.push('/health-data')),
                        _QuickActionCard(
                            label: 'Analytics',
                            icon: Icons.bar_chart,
                            color: AppColors.steps,
                            onTap: () => context.go(AppRoutes.analytics)),
                        _QuickActionCard(
                            label: 'My Goals',
                            icon: Icons.flag_outlined,
                            color: AppColors.success,
                            onTap: () => context.push(AppRoutes.goals)),
                        _QuickActionCard(
                            label: 'Healthcare',
                            icon: Icons.medical_services_outlined,
                            color: Colors.teal,
                            onTap: () =>
                                context.push(AppRoutes.healthcareInteraction)),
                        _QuickActionCard(
                            label: 'Find Hospital',
                            icon: Icons.local_hospital_outlined,
                            color: Colors.redAccent,
                            onTap: () =>
                                context.push(AppRoutes.hospitalLocator)),
                        _QuickActionCard(
                            label: 'Appointments',
                            icon: Icons.calendar_month_outlined,
                            color: Colors.deepPurpleAccent,
                            onTap: () =>
                                context.push(AppRoutes.appointments)),
                      ]
                          .animate(interval: 50.ms)
                          .fade(duration: 400.ms)
                          .slideX(begin: 0.1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Standard UI Widgets ──────────────────────────────────────────────────────

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final double progress;
  final VoidCallback? onTap;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    required this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppTheme.subtleShadow,
          border: Border.all(color: color.withAlpha(30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                if (onTap != null)
                  Icon(Icons.arrow_forward_ios,
                      color: AppColors.textHint, size: 14),
              ],
            ),
            const Spacer(),
            Text(title,
                style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(value,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(unit,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: AppColors.background,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.subtleShadow,
          border: Border.all(color: color.withAlpha(30)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: color.withAlpha(20), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeviceConnectionSheet extends StatefulWidget {
  final Function(String) onConnected;

  const _DeviceConnectionSheet({required this.onConnected});

  @override
  State<_DeviceConnectionSheet> createState() => _DeviceConnectionSheetState();
}

class _DeviceConnectionSheetState extends State<_DeviceConnectionSheet> {
  bool _isScanning = true;
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isScanning = false);
    });
  }

  void _connect(String device) async {
    setState(() => _isConnecting = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      widget.onConnected(device);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Connect Device',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_isConnecting)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 16),
                    Text('Connecting...', style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            )
          else if (_isScanning)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 16),
                    Text('Scanning for nearby devices...', style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            )
          else ...[
            _deviceTile('Apple Watch Series 9', Icons.watch),
            const SizedBox(height: 12),
            _deviceTile('Garmin Forerunner 265', Icons.watch_outlined),
            const SizedBox(height: 12),
            _deviceTile('Samsung Galaxy Watch 6', Icons.watch_rounded),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _deviceTile(String name, IconData icon) {
    return GestureDetector(
      onTap: () => _connect(name),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.textHint.withAlpha(30)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(Icons.add_circle_outline, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
