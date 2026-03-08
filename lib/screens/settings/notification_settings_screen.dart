import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  // ── Toggle state (all fake / local only) ────────────────────────────────────
  bool _dailyReminder = true;
  bool _stepGoalAlert = true;
  bool _waterReminder = true;
  bool _sleepReminder = false;
  bool _providerMessages = true;
  bool _appointmentAlerts = true;
  bool _weeklyReport = false;
  bool _achievementAlerts = true;

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Health Reminders ───────────────────────────────────────────
          _sectionLabel('Health Reminders'),
          const SizedBox(height: 12),
          _card(children: [
            _toggle(
              icon: Icons.wb_sunny_outlined,
              iconColor: Colors.orange,
              title: 'Daily Check-in Reminder',
              subtitle: 'Reminded to log your health data each morning',
              value: _dailyReminder,
              onChanged: (v) {
                setState(() => _dailyReminder = v);
                _snack(
                    v ? 'Daily reminder enabled' : 'Daily reminder disabled');
              },
            ),
            _divider(),
            _toggle(
              icon: Icons.directions_walk,
              iconColor: AppColors.steps,
              title: 'Step Goal Alert',
              subtitle: 'Notified when you\'re close to your step goal',
              value: _stepGoalAlert,
              onChanged: (v) {
                setState(() => _stepGoalAlert = v);
                _snack(v ? 'Step alerts enabled' : 'Step alerts disabled');
              },
            ),
            _divider(),
            _toggle(
              icon: Icons.water_drop_outlined,
              iconColor: AppColors.water,
              title: 'Water Intake Reminder',
              subtitle: 'Periodic reminders to stay hydrated',
              value: _waterReminder,
              onChanged: (v) {
                setState(() => _waterReminder = v);
                _snack(
                    v ? 'Water reminders enabled' : 'Water reminders disabled');
              },
            ),
            _divider(),
            _toggle(
              icon: Icons.nights_stay_outlined,
              iconColor: AppColors.sleep,
              title: 'Sleep Reminder',
              subtitle: 'Wind-down reminder before your bedtime',
              value: _sleepReminder,
              onChanged: (v) {
                setState(() => _sleepReminder = v);
                _snack(
                    v ? 'Sleep reminder enabled' : 'Sleep reminder disabled');
              },
            ),
          ]),

          const SizedBox(height: 24),

          // ── Healthcare ─────────────────────────────────────────────────
          _sectionLabel('Healthcare'),
          const SizedBox(height: 12),
          _card(children: [
            _toggle(
              icon: Icons.chat_bubble_outline,
              iconColor: Colors.teal,
              title: 'Provider Messages',
              subtitle: 'Alerts when Dr. Kang sends you a message',
              value: _providerMessages,
              onChanged: (v) {
                setState(() => _providerMessages = v);
                _snack(
                    v ? 'Provider alerts enabled' : 'Provider alerts disabled');
              },
            ),
            _divider(),
            _toggle(
              icon: Icons.calendar_month_outlined,
              iconColor: AppColors.primary,
              title: 'Appointment Reminders',
              subtitle: '24 hours and 1 hour before your appointments',
              value: _appointmentAlerts,
              onChanged: (v) {
                setState(() => _appointmentAlerts = v);
                _snack(v
                    ? 'Appointment alerts enabled'
                    : 'Appointment alerts disabled');
              },
            ),
          ]),

          const SizedBox(height: 24),

          // ── Reports & Progress ─────────────────────────────────────────
          _sectionLabel('Reports & Progress'),
          const SizedBox(height: 12),
          _card(children: [
            _toggle(
              icon: Icons.bar_chart_outlined,
              iconColor: Colors.deepPurple,
              title: 'Weekly Health Report',
              subtitle: 'Summary of your health stats every Monday',
              value: _weeklyReport,
              onChanged: (v) {
                setState(() => _weeklyReport = v);
                _snack(v ? 'Weekly report enabled' : 'Weekly report disabled');
              },
            ),
            _divider(),
            _toggle(
              icon: Icons.emoji_events_outlined,
              iconColor: Colors.amber,
              title: 'Achievement Unlocked',
              subtitle: 'Celebrate when you earn a new badge',
              value: _achievementAlerts,
              onChanged: (v) {
                setState(() => _achievementAlerts = v);
                _snack(v
                    ? 'Achievement alerts enabled'
                    : 'Achievement alerts disabled');
              },
            ),
          ]),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: AppColors.textPrimary,
        ),
      );

  Widget _card({required List<Widget> children}) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha(5),
                blurRadius: 10,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(children: children),
      );

  Widget _toggle({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) =>
      ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withAlpha(20),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(subtitle,
            style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primary,
        ),
      );

  Widget _divider() => Divider(
      height: 1,
      indent: 56,
      endIndent: 20,
      color: AppColors.textHint.withAlpha(40));
}
