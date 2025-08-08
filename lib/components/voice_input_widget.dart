import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/services/speech_service.dart';

class VoiceInputWidget extends StatefulWidget {
  final Function(String) onTextReceived;
  final bool isEnabled;

  const VoiceInputWidget({
    Key? key,
    required this.onTextReceived,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  State<VoiceInputWidget> createState() => _VoiceInputWidgetState();
}

class _VoiceInputWidgetState extends State<VoiceInputWidget>
    with SingleTickerProviderStateMixin {
  final SpeechService _speechService = SpeechService();
  bool _isListening = false;
  bool _isInitialized = false;
  String _currentText = '';
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _speechService.cancel();
    super.dispose();
  }

  Future<void> _initializeSpeech() async {
    final initialized = await _speechService.initialize();
    if (mounted) {
      setState(() {
        _isInitialized = initialized;
      });
    }
  }

  Future<void> _startListening() async {
    if (!_isInitialized || !widget.isEnabled) return;

    setState(() {
      _isListening = true;
      _currentText = '';
    });

    _animationController.repeat(reverse: true);

    try {
      final recognizedText = await _speechService.startListening();

      if (mounted) {
        setState(() {
          _isListening = false;
          _currentText = recognizedText ?? '';
        });

        _animationController.stop();
        _animationController.reset();

        if (recognizedText != null && recognizedText.trim().isNotEmpty) {
          widget.onTextReceived(recognizedText.trim());
        } else {
          _showMessage('No speech detected. Please try again.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isListening = false;
        });
        _animationController.stop();
        _animationController.reset();
        _showMessage('Speech recognition failed. Please try again.');
      }
    }
  }

  Future<void> _stopListening() async {
    await _speechService.stopListening();
    if (mounted) {
      setState(() {
        _isListening = false;
      });
      _animationController.stop();
      _animationController.reset();
    }
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isListening ? _stopListening : _startListening,
      onLongPress: _isListening ? _stopListening : _startListening,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isListening ? _pulseAnimation.value : 1.0,
            child: Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: _isListening
                    ? FlutterFlowTheme.of(context).error
                    : (_isInitialized
                        ? FlutterFlowTheme.of(context).primary
                        : FlutterFlowTheme.of(context).secondaryText),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                color: Colors.white,
                size: 20.0,
              ),
            ),
          );
        },
      ),
    );
  }
}
