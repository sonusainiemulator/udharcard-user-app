import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:logger/logger.dart';

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  final Logger _logger = Logger();

  bool _isSpeechInitialized = false;

  Future<void> initialize() async {
    _isSpeechInitialized = await _speechToText.initialize(
      onError: (val) => _logger.e('Speech error: $val'),
      onStatus: (val) => _logger.i('Speech status: $val'),
    );
    
    await _flutterTts.setLanguage("hi-IN");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  void startListening(Function(String) onResult) async {
    if (!_isSpeechInitialized) {
      await initialize();
    }
    if (_isSpeechInitialized) {
      await _speechToText.listen(
        onResult: (result) {
          onResult(result.recognizedWords);
        },
        listenOptions: SpeechListenOptions(localeId: 'hi-IN'),
      );
    }
  }

  void stopListening() async {
    await _speechToText.stop();
  }

  Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
  }
}
