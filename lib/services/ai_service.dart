import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/user_profile.dart';
import '../config/app_config.dart';

class AIService {
  GenerativeModel? _model;
  ChatSession? _chatSession;
  bool _isInitialized = false;

  bool get isReady => _isInitialized;

  /// Initialise the Gemini session.
  ///
  /// [plainText] – true for the Companion tab (no markdown in bubbles).
  /// Returns an error message string on failure, null on success.
  Future<String?> initialize(UserProfile? userProfile,
      {bool plainText = false}) async {
    if (_isInitialized) return null;

    final formattingInstruction = plainText
        ? 'Respond in plain, friendly conversational text only. '
            'No markdown, no bullet points, no asterisks, no headers. '
            'Keep responses to 2–3 short sentences maximum.'
        : 'Keep your answers concise and engaging. '
            'Use Markdown formatting where it helps clarity.';

    final systemInstructions = '''
You are AURA, an empathetic, highly knowledgeable, and encouraging virtual health companion and AI coach.
Your goal is to help your user understand their health data, offer practical wellness advice, and motivate them to reach their goals.
$formattingInstruction
Never provide definitive medical diagnoses, but do offer general physiology facts and lifestyle tips.

Here is what you know about the user:
- Name: ${userProfile?.username ?? 'User'}
- Gender: ${userProfile?.gender ?? 'Not specified'}
- Height: ${userProfile?.height ?? 0} cm
- Current Weight: ${userProfile?.weight ?? 0} kg
- Target Weight: ${userProfile?.targetWeight != null ? '${userProfile!.targetWeight} kg' : 'Not specified'}
- Known Medical Conditions: ${userProfile?.healthConditions.isNotEmpty == true ? userProfile!.healthConditions.join(', ') : 'None reported'}

Always factor this context into your responses gracefully. Be friendly, professional, and warmly personalized.
''';

    try {
      _model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: AppConfig.geminiApiKey,
        systemInstruction: Content.system(systemInstructions),
      );
      _chatSession = _model!.startChat();
      _isInitialized = true;
      debugPrint('[AIService] Initialized successfully.');
      return null; // success
    } catch (e) {
      debugPrint('[AIService] Init error: $e');
      return 'Failed to start AI: $e';
    }
  }

  Future<String> sendMessage(String text) async {
    if (!_isInitialized || _chatSession == null) {
      return "I'm not ready yet — please wait a moment and try again.";
    }
    try {
      final response = await _chatSession!.sendMessage(Content.text(text));
      return response.text?.trim() ??
          "I'm having trouble thinking right now. Could you rephrase?";
    } catch (e) {
      debugPrint('[AIService] sendMessage error: $e');
      return "⚠️ AI Error: ${e.runtimeType}: $e";
    }
  }

  /// Resets so initialize() can be called again after an error + retry.
  void reset() {
    _model = null;
    _chatSession = null;
    _isInitialized = false;
  }
}
