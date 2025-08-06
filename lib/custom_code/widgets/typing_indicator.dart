import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart';
import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';
import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({
    Key? key,
    this.height,
    required this.dotColor,
    required this.dotSize,
  }) : super(key: key);

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

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    _animations = List.generate(3, (index) {
      final begin = index * 0.2;
      final end = begin + 0.4;

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
        final animationValue = _animations[index].value;
        final bounceValue =
            (1 - (animationValue - 0.5).abs() * 2).clamp(0.0, 1.0);
        final translateY = -bounceValue * 8.0;

        return Transform.translate(
          offset: Offset(0, translateY),
          child: Container(
            width: widget.dotSize,
            height: widget.dotSize,
            decoration: BoxDecoration(
              color: widget.dotColor
                  .withOpacity(0.3 + (bounceValue * 0.7)),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height ?? 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
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