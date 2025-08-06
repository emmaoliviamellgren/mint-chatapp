import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart';
import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';
import 'package:flutter/material.dart';

class LoadingSpinner extends StatefulWidget {
  const LoadingSpinner({
    Key? key,
    this.width,
    this.height,
    required this.size,
    required this.color,
  }) : super(key: key);

  final double? width;
  final double? height;
  final double size;
  final Color color;

  @override
  _LoadingSpinnerState createState() => _LoadingSpinnerState();
}

class _LoadingSpinnerState extends State<LoadingSpinner>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  return SizedBox(
    width: widget.width ?? widget.size,
    height: widget.height ?? widget.size,
    child: Center(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CircularProgressIndicator(
          color: widget.color,
          strokeWidth: 4.0,
        ),
      ),
    ),
  );
}
}
