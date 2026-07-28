import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:logger/logger.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  final Logger _logger = Logger();
  GenerativeModel? _model;

  void initialize() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      _logger.e('No GEMINI_API_KEY found in .env');
      return;
    }
    // Using gemini-1.5-flash for low cost and low latency
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
  }

  Future<String> generateResponse(String input) async {
    if (_model == null) {
      _logger.e('GenerativeModel is not initialized');
      return 'AI service is currently unavailable.';
    }

    try {
      final content = [Content.text("You are a helpful assistant for the Udharcard mobile payment application. Respond concisely in Hindi. User says: $input")];
      final response = await _model!.generateContent(content);
      return response.text ?? 'Sorry, I could not understand that.';
    } catch (e) {
      _logger.e('Failed to generate response: $e');
      return 'An error occurred while generating response.';
    }
  }
}
