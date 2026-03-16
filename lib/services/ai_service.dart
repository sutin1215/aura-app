import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/user_profile.dart';

class AIService {
  static const String _apiKey = 'AIzaSyBrTnxFnQzApw5KCa4L9jVx_jsXq4JPp5M';
  
  late GenerativeModel _model;
  late ChatSession _chatSession;
  
  bool _isInitialized = false;

  Future<void> initialize(UserProfile? userProfile) async {
    if (_isInitialized) return;

    String systemInstructions = '''
You are AURA, an empathetic, highly knowledgeable, and encouraging virtual health companion and AI coach.
Your goal is to help your user understand their health data, offer practical wellness advice, and motivate them to reach their goals.
Keep your answers concise, engaging, and perfectly formatted in Markdown.
Never provide definitive medical diagnoses, but do offer general physiology facts and lifestyle tips.

Here is what you know about the user you are talking to:
- Name: ${userProfile?.username ?? 'User'}
- Gender: ${userProfile?.gender ?? 'Not specified'}
- Height: ${userProfile?.height ?? 0} cm
- Current Weight: ${userProfile?.weight ?? 0} kg
- Target Weight: ${userProfile?.targetWeight != null ? '${userProfile!.targetWeight} kg' : 'Not specified'}
- Known Medical Conditions: ${userProfile?.healthConditions.join(', ') ?? 'None reported'}

Always factor this context into your responses gracefully. For instance, if they ask for advice on losing weight, consider their current and target weight. If they have Asthma, avoid suggesting intense aerobic workouts without a warm-up. Ensure your tone is friendly, professional, and warmly personalized.
''';

    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system(systemInstructions),
    );

    _chatSession = _model.startChat();
    _isInitialized = true;
  }

  Future<String> sendMessage(String text) async {
    if (!_isInitialized) {
      return "I'm sorry, I'm still waking up. Please try again in a moment.";
    }

    try {
      final response = await _chatSession.sendMessage(Content.text(text));
      return response.text ?? "I'm having trouble thinking right now. Could you rephrase?";
    } catch (e) {
      print('Error communicating with Gemini: $e');
      return "I ran into a connection issue. Please check your internet or try again later!";
    }
  }
}
