import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

class BotMessage extends StatefulWidget {
  const BotMessage({
    Key? key,
    this.width,
    this.height,
    required this.text,
    required this.textColor,
    required this.dotColor,
    this.fontSize = 14.0,
    this.wordDelay = 100,
    this.onComplete,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String text;
  final Color textColor;
  final Color dotColor;
  final double fontSize;
  final int wordDelay;
  final VoidCallback? onComplete;

  @override
  _BotMessageState createState() => _BotMessageState();
}

class _BotMessageState extends State<BotMessage> {
  String _displayedText = '';
  List<String> _words = [];

  @override
  void initState() {
    super.initState();
    if (widget.text.isNotEmpty) {
      _words = widget.text.split(' ');
      _startTypewriter();
    }
  }

  Future<void> _startTypewriter() async {
    await Future.delayed(Duration(milliseconds: 50));
    
    for (int i = 0; i < _words.length; i++) {
      if (!mounted) return;
      
      setState(() {
        _displayedText = _words.sublist(0, i + 1).join(' ');
      });
      
      await Future.delayed(Duration(milliseconds: widget.wordDelay));
    }
    
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText,
      style: FlutterFlowTheme.of(context).bodyMedium.override(
        font: GoogleFonts.manrope(
          fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
        ),
      ).copyWith(color: widget.textColor, fontSize: widget.fontSize),
      textAlign: TextAlign.left,
    );
  }
}