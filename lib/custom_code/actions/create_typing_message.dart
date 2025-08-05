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
    currentMessages.removeWhere((msg) => msg['isTyping'] == true);

    // FORCE: Remove any messages that might interfere and put typing at absolute top
    // This ensures typing message is always at index 0

    // Create temporary typing message as JSON string then parse back
    final tempMessageJson = jsonEncode({
      'id': 'typing_${DateTime.now().millisecondsSinceEpoch}',
      'text': 'TYPING_PLACEHOLDER',
      'sender': 'bot',
      'isNew': true,
      'timestamp': DateTime.now().toIso8601String(),
      'isTyping': true,
      'formattedTime':
          '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
    });

    final tempMessage = jsonDecode(tempMessageJson);

    // Insert at the very beginning (index 0) for reverse ListView
    currentMessages.insert(0, tempMessage);

    // Update app state immediately
    FFAppState().update(() {
      FFAppState().chatMessages = currentMessages;
    });

    print('Created typing message with ID: ${tempMessage['id']} at index 0');
    print('Total messages now: ${currentMessages.length}');
  } catch (e) {
    print('Error creating typing message: $e');
  }
}
