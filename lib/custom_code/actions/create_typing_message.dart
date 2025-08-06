// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

Future<void> createTypingMessage() async {
  try {
    // Get current messages
    final List<dynamic> currentMessages =
        List.from(FFAppState().chatMessages ?? []);

    // Remove any existing typing messages first (prevent duplicates)
    currentMessages.removeWhere((msg) => 
      msg['isTyping'] == true || 
      msg['sender'] == 'typing'
    );

    // Create typing message with a unique ID that won't conflict
    final typingMessage = {
      'id': 'typing_indicator_${DateTime.now().millisecondsSinceEpoch}',
      'text': '...', // Use dots instead of TYPING_PLACEHOLDER
      'sender': 'typing', // Special sender type for typing
      'isNew': true,
      'isTyping': true,
      'timestamp': DateTime.now().toIso8601String(),
      'formattedTime':
          '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
    };

    // Insert at the beginning (index 0) for reverse ListView
    currentMessages.insert(0, typingMessage);

    // Update app state
    FFAppState().update(() {
      FFAppState().chatMessages = currentMessages;
    });
  } catch (e) {
    print('Error creating typing message: $e');
  }
}