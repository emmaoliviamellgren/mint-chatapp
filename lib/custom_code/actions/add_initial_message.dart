import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart';
import '/flutter_flow/custom_functions.dart';
import 'package:flutter/material.dart';

Future<void> addInitialMessage() async {
  try {
    // Get current messages
    final List<dynamic> currentMessages =
        List.from(FFAppState().chatMessages ?? []);

    // Only add initial message if there are no existing messages
    if (currentMessages.isEmpty) {
      final initialMessage = {
        'id': 'initial_message_${DateTime.now().millisecondsSinceEpoch}',
        'text': 'Hello! Welcome to our chat. How can I help you today?',
        'sender': 'bot',
        'timestamp': DateTime.now().toIso8601String(),
        'isNew': true,
        'formattedTime':
            '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
      };

      currentMessages.insert(0, initialMessage);

      FFAppState().update(() {
        FFAppState().chatMessages = currentMessages;
      });
    }
  } catch (e) {
    print('Error adding initial message: $e');
  }
}
