import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../models/chat_message.dart';
import '../../providers/auth_provider.dart';
import '../../providers/metrics_provider.dart';
import '../../services/ai_service.dart';
import '../../theme/app_theme.dart';

// ── Quick suggestion prompts ──────────────────────────────────────────────────
const _suggestions = [
  {'icon': '😴', 'label': 'Tips for better sleep'},
  {'icon': '💪', 'label': 'Workout recommendations'},
  {'icon': '🥗', 'label': 'Healthy meal ideas'},
  {'icon': '💧', 'label': 'How much water should I drink?'},
  {'icon': '📊', 'label': 'How am I doing today?'},
  {'icon': '🧘', 'label': 'Help me reduce stress'},
];

class CompanionScreen extends StatefulWidget {
  const CompanionScreen({super.key});

  @override
  State<CompanionScreen> createState() => _CompanionScreenState();
}

class _CompanionScreenState extends State<CompanionScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AIService _aiService = AIService();

  bool _aiReady = false;
  bool _aiInitializing = false;
  String? _aiError;
  bool _isTyping = false;

  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _initAI();
  }

  Future<void> _initAI() async {
    if (!mounted) return;
    setState(() {
      _aiInitializing = true;
      _aiError = null;
    });
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final error = await _aiService.initialize(auth.userProfile, plainText: true);
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _aiInitializing = false;
        _aiError = error;
      });
    } else {
      setState(() {
        _aiInitializing = false;
        _aiReady = true;
      });
    }
  }

  Future<void> _retryInit() async {
    _aiService.reset();
    await _initAI();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmitted(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || !_aiReady || _isTyping) return;
    _textController.clear();

    setState(() {
      _messages.add(ChatMessage(text: trimmed, isUser: true, timestamp: DateTime.now()));
      _isTyping = true;
    });
    _scrollToBottom();

    final response = await _aiService.sendMessage(trimmed);

    if (!mounted) return;
    setState(() {
      _isTyping = false;
      _messages.add(ChatMessage(text: response, isUser: false, timestamp: DateTime.now()));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Color get _statusColor {
    if (_aiError != null) return AppColors.error;
    if (_aiInitializing) return AppColors.warning;
    if (_aiReady) return AppColors.success;
    return AppColors.textHint;
  }

  String get _statusText {
    if (_aiError != null) return 'Connection failed';
    if (_aiInitializing) return 'Connecting...';
    if (_aiReady) return 'Online';
    return 'Offline';
  }

  // Whether to show the welcome hero (no conversation started yet)
  bool get _showHero => _messages.isEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Error banner
          if (_aiError != null) _ErrorBanner(onRetry: _retryInit),

          // Main body: either hero welcome OR chat list
          Expanded(
            child: _showHero
                ? _HeroWelcome(
                    aiReady: _aiReady,
                    aiInitializing: _aiInitializing,
                    onSuggestionTap: _handleSubmitted,
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_isTyping && index == _messages.length) {
                        return const _TypingIndicator();
                      }
                      return _MessageBubble(message: _messages[index]);
                    },
                  ),
          ),

          // Input bar
          _InputBar(
            controller: _textController,
            aiReady: _aiReady,
            aiInitializing: _aiInitializing,
            aiError: _aiError,
            isTyping: _isTyping,
            onSubmitted: _handleSubmitted,
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // AURA avatar in the app bar
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(60),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/aura_avatar.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.gradientStart, AppColors.gradientEnd],
                    ),
                  ),
                  child: const Icon(Icons.smart_toy, color: Colors.white, size: 22),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AURA Companion',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: _statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _statusText,
                    style: TextStyle(
                      fontSize: 11,
                      color: _statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Error Banner ──────────────────────────────────────────────────────────────
class _ErrorBanner extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorBanner({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.error.withAlpha(20),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, color: AppColors.error, size: 18),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              "Couldn't reach AURA AI. Check your internet connection.",
              style: TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry',
                style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ── Hero Welcome Section ──────────────────────────────────────────────────────
class _HeroWelcome extends StatelessWidget {
  final bool aiReady;
  final bool aiInitializing;
  final ValueChanged<String> onSuggestionTap;

  const _HeroWelcome({
    required this.aiReady,
    required this.aiInitializing,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final metrics = Provider.of<MetricsProvider>(context, listen: false);
    final today = metrics.todayMetrics;
    final name = auth.userProfile?.username ??
        auth.user?.email?.split('@')[0] ??
        'there';

    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        children: [
          const SizedBox(height: 16),

          // ── Animated Avatar ────────────────────────────────────────────────
          _PulsingAvatar()
              .animate()
              .fade(duration: 700.ms)
              .scale(begin: const Offset(0.7, 0.7), end: const Offset(1, 1), curve: Curves.elasticOut),

          const SizedBox(height: 20),

          // ── Greeting Text ──────────────────────────────────────────────────
          Text(
            '$greeting, $name!',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ).animate().fade(delay: 200.ms).slideY(begin: 0.2, end: 0),

          const SizedBox(height: 8),

          Text(
            "I'm AURA, your personal health companion.\nHow can I help you today?",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ).animate().fade(delay: 300.ms),

          const SizedBox(height: 28),

          // ── Health Context Cards ───────────────────────────────────────────
          _HealthContextCards(today: today, onTap: onSuggestionTap)
              .animate()
              .fade(delay: 400.ms)
              .slideY(begin: 0.1, end: 0),

          const SizedBox(height: 28),

          // ── Suggestion Grid ────────────────────────────────────────────────
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              aiInitializing ? 'AURA is waking up...' : 'Or pick a topic:',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ).animate().fade(delay: 500.ms),
          ),
          const SizedBox(height: 12),

          if (aiReady)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.8,
              children: _suggestions.asMap().entries.map((entry) {
                final i = entry.key;
                final s = entry.value;
                return GestureDetector(
                  onTap: () => onSuggestionTap(s['label']!),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withAlpha(40)),
                      boxShadow: AppTheme.subtleShadow,
                    ),
                    child: Row(
                      children: [
                        Text(s['icon']!, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            s['label']!,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    .animate(delay: Duration(milliseconds: 500 + (i * 60)))
                    .fade()
                    .slideY(begin: 0.2, end: 0);
              }).toList(),
            )
          else if (aiInitializing)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Connecting to AURA AI...',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ).animate().fade(),
        ],
      ),
    );
  }
}

// ── Pulsing Avatar Widget ─────────────────────────────────────────────────────
class _PulsingAvatar extends StatefulWidget {
  @override
  State<_PulsingAvatar> createState() => _PulsingAvatarState();
}

class _PulsingAvatarState extends State<_PulsingAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final glow = _pulseController.value;
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha((60 + (glow * 80)).round()),
                blurRadius: 24 + (glow * 20),
                spreadRadius: glow * 8,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/aura_avatar.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.gradientStart, AppColors.gradientEnd],
                  ),
                ),
                child: const Icon(Icons.auto_awesome,
                    color: Colors.white, size: 52),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Health Context Cards ──────────────────────────────────────────────────────
class _HealthContextCards extends StatelessWidget {
  final dynamic today; // DailyMetrics | null
  final ValueChanged<String> onTap;
  const _HealthContextCards({required this.today, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> cards = [];

    final steps = today?.steps ?? 0;
    final waterMl = today?.waterIntakeMl ?? 0;
    final sleepMin = today?.sleepMinutes ?? 0;
    final calories = today?.caloriesBurned ?? 0;

    // Steps card
    cards.add({
      'icon': '👟',
      'color': AppColors.steps,
      'title': '$steps steps',
      'subtitle': steps < 5000 ? 'Below your daily goal' : 'Great progress today!',
      'prompt': 'I walked $steps steps today. What are some tips to increase my step count?',
    });

    // Water card
    final waterL = (waterMl / 1000).toStringAsFixed(1);
    cards.add({
      'icon': '💧',
      'color': AppColors.water,
      'title': '${waterL}L water',
      'subtitle': waterMl < 1500 ? 'Drink more to stay hydrated' : 'Good hydration today!',
      'prompt': 'I\'ve had ${waterL}L of water today. How much more should I drink?',
    });

    // Sleep card
    if (sleepMin > 0) {
      final sleepH = sleepMin ~/ 60;
      final sleepM = sleepMin % 60;
      cards.add({
        'icon': '😴',
        'color': AppColors.sleep,
        'title': '${sleepH}h ${sleepM}m sleep',
        'subtitle': sleepMin < 420 ? 'Below recommended 7h' : 'Well rested!',
        'prompt': 'I slept ${sleepH}h and ${sleepM}m last night. Is that enough, and how can I improve my sleep quality?',
      });
    } else if (calories > 0) {
      cards.add({
        'icon': '🔥',
        'color': AppColors.calories,
        'title': '$calories kcal burned',
        'subtitle': 'Active calories today',
        'prompt': 'I burned $calories calories today. What are some tips to maintain this?',
      });
    }

    if (cards.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your health today:',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        ...cards.map((card) {
          final color = card['color'] as Color;
          return GestureDetector(
            onTap: () => onTap(card['prompt'] as String),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: color.withAlpha(50)),
                boxShadow: AppTheme.subtleShadow,
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(card['icon'] as String,
                          style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card['title'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: color,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          card['subtitle'] as String,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chat_bubble_outline, color: color, size: 18),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ── Input Bar ─────────────────────────────────────────────────────────────────
class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool aiReady;
  final bool aiInitializing;
  final String? aiError;
  final bool isTyping;
  final ValueChanged<String> onSubmitted;

  const _InputBar({
    required this.controller,
    required this.aiReady,
    required this.aiInitializing,
    required this.aiError,
    required this.isTyping,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.send,
                onSubmitted: aiReady ? onSubmitted : null,
                enabled: aiReady && !isTyping,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: aiInitializing
                      ? 'AURA is waking up...'
                      : aiError != null
                          ? 'AI unavailable — tap Retry above'
                          : "Tell AURA how you're feeling...",
                  hintStyle: const TextStyle(color: AppColors.textHint),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: (aiReady && !isTyping)
                  ? () => onSubmitted(controller.text)
                  : null,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: (aiReady && !isTyping)
                        ? [AppColors.gradientStart, AppColors.gradientEnd]
                        : [AppColors.textHint, AppColors.textHint],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: (aiReady && !isTyping) ? AppTheme.subtleShadow : null,
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Message Bubble ────────────────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final timeStr =
        '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            // AURA avatar in chat bubble
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(40),
                    blurRadius: 8,
                  )
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/aura_avatar.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.gradientStart, AppColors.gradientEnd],
                      ),
                    ),
                    child: const Icon(Icons.smart_toy, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 20),
                    ),
                    boxShadow: AppTheme.subtleShadow,
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : AppColors.textPrimary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                )
                    .animate()
                    .fade(duration: 300.ms)
                    .slideY(begin: 0.1, end: 0),
                const SizedBox(height: 3),
                Text(
                  timeStr,
                  style: const TextStyle(color: AppColors.textHint, fontSize: 10),
                ),
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

// ── Typing Indicator ──────────────────────────────────────────────────────────
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );
    _animations = _controllers
        .map((c) => Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(parent: c, curve: Curves.easeInOut),
            ))
        .toList();
    for (var i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: ClipOval(
              child: Image.asset(
                'assets/images/aura_avatar.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.gradientStart, AppColors.gradientEnd],
                    ),
                  ),
                  child: const Icon(Icons.smart_toy, size: 16, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: AppTheme.subtleShadow,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('AURA is thinking',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontStyle: FontStyle.italic)),
                const SizedBox(width: 6),
                ...List.generate(3, (i) {
                  return AnimatedBuilder(
                    animation: _animations[i],
                    builder: (context, _) {
                      return Container(
                        margin: EdgeInsets.only(right: i < 2 ? 3 : 0),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Color.lerp(
                            AppColors.textHint,
                            AppColors.primary,
                            _animations[i].value,
                          ),
                          shape: BoxShape.circle,
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    ).animate().fade(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }
}
