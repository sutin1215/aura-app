import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/chat_message.dart';
import '../../providers/auth_provider.dart';
import '../../services/ai_service.dart';
import '../../theme/app_theme.dart';

const _suggestions = [
  "How am I doing today?",
  "Tips for better sleep 😴",
  "I need to drink more water 💧",
  "I went for a run today 🏃",
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

  final List<ChatMessage> _messages = [
    ChatMessage(
      text:
          "Hello! I'm AURA, your personal health companion. 👋\n\nHow are you feeling today? I can help you track your health, give wellness tips, or just have a chat.",
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(seconds: 5)),
    ),
  ];

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
    // plainText: true — no markdown leaking into chat bubbles
    final error =
        await _aiService.initialize(auth.userProfile, plainText: true);

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
      _messages.add(
          ChatMessage(text: trimmed, isUser: true, timestamp: DateTime.now()));
      _isTyping = true;
    });
    _scrollToBottom();

    final response = await _aiService.sendMessage(trimmed);

    if (!mounted) return;
    setState(() {
      _isTyping = false;
      _messages.add(ChatMessage(
          text: response, isUser: false, timestamp: DateTime.now()));
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

  // ── Status helpers ─────────────────────────────────────────────────────────

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AURA Companion',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
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
      ),
      body: Column(
        children: [
          // ── Error banner ──────────────────────────────────────────────
          if (_aiError != null)
            Container(
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
                    onPressed: _retryInit,
                    child: const Text('Retry',
                        style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

          // ── Message list ──────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
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

          // ── Quick suggestion chips (shown until user sends first message) ─
          if (_messages.length <= 2 && _aiReady)
            _SuggestionRow(
              suggestions: _suggestions,
              onTap: _handleSubmitted,
            ),

          // ── Input bar ─────────────────────────────────────────────────
          Container(
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
                      controller: _textController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _aiReady ? _handleSubmitted : null,
                      enabled: _aiReady && !_isTyping,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: _aiInitializing
                            ? 'AURA is waking up...'
                            : _aiError != null
                                ? 'AI unavailable — tap Retry above'
                                : "Tell AURA how you're feeling...",
                        hintStyle: const TextStyle(color: AppColors.textHint),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: (_aiReady && !_isTyping)
                        ? () => _handleSubmitted(_textController.text)
                        : null,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: (_aiReady && !_isTyping)
                              ? [AppColors.gradientStart, AppColors.gradientEnd]
                              : [AppColors.textHint, AppColors.textHint],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy, size: 16, color: Colors.white),
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
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withAlpha(8),
                          blurRadius: 8,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : AppColors.textPrimary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  timeStr,
                  style:
                      const TextStyle(color: AppColors.textHint, fontSize: 10),
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
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.gradientStart, AppColors.gradientEnd],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy, size: 16, color: Colors.white),
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
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withAlpha(8),
                    blurRadius: 8,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _animations[i],
                  builder: (context, _) {
                    return Container(
                      margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                      width: 8,
                      height: 8,
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
            ),
          ),
        ],
      ),
    );
  }
}

// ── Suggestion Row ────────────────────────────────────────────────────────────
class _SuggestionRow extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onTap;
  const _SuggestionRow({required this.suggestions, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: suggestions
              .map((s) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => onTap(s),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.primary.withAlpha(60)),
                        ),
                        child: Text(
                          s,
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
