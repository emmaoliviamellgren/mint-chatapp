// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Combined Bot Message Widget - Shows typing indicator, then typewriter animation

class BotMessage extends StatefulWidget {
  const BotMessage({
    Key? key,
    this.width,
    this.height,
    required this.text,
    required this.textColor,
    required this.dotColor,
    this.fontSize = 14.0,
    this.isComplete = false,
    this.showTyping = true,
    this.typingDuration = 2000, // How long to show typing indicator
    this.wordDelay = 100, // Delay between words in typewriter
    this.dotSize = 6.0,
    this.messageIndex = 0, // Add message index parameter
  }) : super(key: key);

  final double? width;
  final double? height;
  final String text;
  final Color textColor;
  final Color dotColor;
  final double fontSize;
  final bool isComplete; // If true, skip animations and show full text
  final bool showTyping; // If false, go straight to typewriter
  final int typingDuration;
  final int wordDelay;
  final double dotSize;
  final int messageIndex; // Message position in list

  @override
  _BotMessageState createState() => _BotMessageState();
}

class _BotMessageState extends State<BotMessage> with TickerProviderStateMixin {
  late AnimationController _typingController;
  late List<Animation<double>> _typingAnimations;
  late int _initTime; // Track when widget was created

  MessageState _currentState = MessageState.typing;
  String _displayedText = '';
  List<String> _words = [];
  int _currentWordIndex = 0;

  @override
  void initState() {
    super.initState();

    _initTime = DateTime.now().millisecondsSinceEpoch;
    _words = widget.text.split(' ');

    // Setup typing indicator animation
    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    _typingAnimations = List.generate(3, (index) {
      final begin = index * 0.2;
      final end = begin + 0.4;

      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _typingController,
          curve: Interval(
            begin,
            end,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });

    _startAnimation();
  }

  void _startAnimation() async {
    // If explicitly marked complete, skip animations
    print("Debug: messageIndex = ${widget.messageIndex}");
    print("Debug: isComplete = ${widget.isComplete}");
    print("Debug: showTyping = ${widget.showTyping}");

    if (widget.isComplete) {
      print("Debug: Skipping - isComplete = true");
      setState(() {
        _currentState = MessageState.complete;
        _displayedText = widget.text;
      });
      return;
    }

    // Only animate the first message (index 0) when bot is actively typing
    if (widget.messageIndex > 0) {
      print("Debug: Skipping - messageIndex > 0");
      setState(() {
        _currentState = MessageState.complete;
        _displayedText = widget.text;
      });
      return;
    }

    print("Debug: Starting animation!");

    // Add a small delay to prevent animation during initial page build
    await Future.delayed(Duration(milliseconds: 100));
    if (!mounted) return;

    if (widget.showTyping) {
      // Start typing indicator
      setState(() {
        _currentState = MessageState.typing;
      });
      _typingController.repeat();

      // Wait for typing duration
      await Future.delayed(Duration(milliseconds: widget.typingDuration));

      if (!mounted) return;
      _typingController.stop();
    }

    // Start typewriter animation
    setState(() {
      _currentState = MessageState.typewriting;
    });

    await _startTypewriter();
  }

  Future<void> _startTypewriter() async {
    for (int i = 0; i < _words.length; i++) {
      if (!mounted) return;

      setState(() {
        _currentWordIndex = i;
        _displayedText = _words.sublist(0, i + 1).join(' ');
      });

      await Future.delayed(Duration(milliseconds: widget.wordDelay));
    }

    // Animation complete
    if (mounted) {
      setState(() {
        _currentState = MessageState.complete;
      });
    }
  }

  @override
  void dispose() {
    _typingController.dispose();
    super.dispose();
  }

  Widget _buildTypingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _typingAnimations[index],
          builder: (context, child) {
            final animationValue = _typingAnimations[index].value;
            final bounceValue =
                (1 - (animationValue - 0.5).abs() * 2).clamp(0.0, 1.0);
            final translateY = -bounceValue * 6.0;

            return Container(
              margin: EdgeInsets.symmetric(horizontal: widget.dotSize * 0.25),
              child: Transform.translate(
                offset: Offset(0, translateY),
                child: Container(
                  width: widget.dotSize,
                  height: widget.dotSize,
                  decoration: BoxDecoration(
                    color:
                        widget.dotColor.withOpacity(0.3 + (bounceValue * 0.7)),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      constraints: BoxConstraints(minHeight: 43),
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: _buildCurrentContent(),
      ),
    );
  }

  Widget _buildCurrentContent() {
    switch (_currentState) {
      case MessageState.typing:
        return _buildTypingIndicator();

      case MessageState.typewriting:
      case MessageState.complete:
        return Text(
          _displayedText,
          style: TextStyle(
            color: widget.textColor,
            fontSize: widget.fontSize,
            fontWeight: FontWeight.normal, // Fixed weight
            fontFamily: 'Manrope', // Use your app's font
          ),
          textAlign: TextAlign.left,
        );
    }
  }
}

enum MessageState {
  typing,
  typewriting,
  complete,
}
