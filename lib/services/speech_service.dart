import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class SpeechService {
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;
  SpeechService._internal();

  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;
  List<LocaleName> _availableLocales = [];

  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    // Check and request microphone permission
    final permission = await Permission.microphone.status;
    if (permission != PermissionStatus.granted) {
      final result = await Permission.microphone.request();
      if (result != PermissionStatus.granted) {
        return false;
      }
    }

    _isInitialized = await _speech.initialize(
      onStatus: (status) {
        debugPrint('Speech recognition status: $status');
        _isListening = status == 'listening';
      },
      onError: (error) {
        debugPrint('Speech recognition error: ${error.errorMsg}');
        _isListening = false;
      },
    );

    // Load available locales after initialization
    if (_isInitialized) {
      _availableLocales = await _speech.locales();
    }

    return _isInitialized;
  }

  Future<String?> startListening({
    Duration? timeout = const Duration(seconds: 30),
    String localeId = 'en_US',
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return null;
    }

    if (_isListening) {
      await stopListening();
    }

    String recognizedText = '';

    await _speech.listen(
      onResult: (result) {
        recognizedText = result.recognizedWords;
        debugPrint('Recognized: $recognizedText');
      },
      localeId: localeId,
      listenFor: timeout,
      pauseFor: const Duration(seconds: 3),
      // Use SpeechListenOptions for the deprecated parameters
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      ),
    );

    // Wait for speech recognition to complete
    while (_speech.isListening) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    return recognizedText.isNotEmpty ? recognizedText : null;
  }

  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }
  }

  Future<void> cancel() async {
    if (_isListening) {
      await _speech.cancel();
      _isListening = false;
    }
  }

  List<LocaleName> get availableLocales => _availableLocales;

  Future<List<LocaleName>> getAvailableLocales() async {
    if (!_isInitialized) {
      await initialize();
    }
    _availableLocales = await _speech.locales();
    return _availableLocales;
  }
}
