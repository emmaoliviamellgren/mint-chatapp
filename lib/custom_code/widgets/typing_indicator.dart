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

// Custom Typing Indicator Widget with 3 bouncing dots

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({
    Key? key,
    this.width,
    this.height,
    required this.dotColor,
    required this.dotSize,
  }) : super(key: key);

  final double? width;
  final double? height;
  final Color dotColor;
  final double dotSize;

  @override
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    // Single controller for all dots
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    // Create staggered animations for each dot
    _animations = List.generate(3, (index) {
      final begin = index * 0.2; // Stagger by 20% of total duration
      final end = begin + 0.4; // Each dot animates for 40% of total duration

      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            begin,
            end,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });

    // Start repeating animation
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _animations[index],
      builder: (context, child) {
        // Create a smooth bounce effect
        final animationValue = _animations[index].value;
        final bounceValue =
            (1 - (animationValue - 0.5).abs() * 2).clamp(0.0, 1.0);
        final translateY = -bounceValue * 8.0; // Bounce up to 8 pixels

        return Transform.translate(
          offset: Offset(0, translateY),
          child: Container(
            width: widget.dotSize,
            height: widget.dotSize,
            decoration: BoxDecoration(
              color: widget.dotColor
                  .withOpacity(0.3 + (bounceValue * 0.7)), // Opacity animation
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? 60,
      height: widget.height ?? 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(
            3,
            (index) => [
                  _buildDot(index),
                  if (index < 2) SizedBox(width: widget.dotSize * 0.5),
                ]).expand((x) => x).toList(),
      ),
    );
  }
}
