// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

Future<List<dynamic>> processMessages(
  dynamic apiResponse,
  String currentUserId,
  bool isFromStreaming, // Add this third parameter
) async {
  try {
    final List<dynamic> currentMessages =
        List.from(FFAppState().chatMessages ?? []);
    bool hasNewMessages = false;

    // Remove any temporary typing messages when real message arrives
    final removedCount = currentMessages.length;
    currentMessages.removeWhere((msg) => msg['isTyping'] == true);
    final finalCount = currentMessages.length;

    if (removedCount != finalCount) {
      print('Removed ${removedCount - finalCount} typing messages');
    }

    // Handle SSE data structure vs regular API structure
    if (apiResponse != null && apiResponse is Map) {
      List<dynamic> messages = [];

      // Check if this is SSE data (single message) or API data (array of messages)
      if (apiResponse.containsKey('type') && apiResponse.containsKey('data')) {
        // SSE format: single message in 'data' field
        messages = [apiResponse['data']];
      } else if (apiResponse.containsKey('messages')) {
        // API format: array of messages
        messages = apiResponse['messages'] ?? [];
      } else {
        // Fallback: treat as single message
        messages = [apiResponse];
      }

      // Process each message
      for (var messageData in messages) {
        if (messageData != null &&
            messageData is Map &&
            messageData['payload'] != null &&
            messageData['payload']['type'] == 'text') {
          final messageId = messageData['id'] ??
              DateTime.now().millisecondsSinceEpoch.toString();

          // Check if message already exists to avoid duplicates
          bool messageExists = currentMessages
              .any((existingMessage) => existingMessage['id'] == messageId);

          if (!messageExists) {
            final now = messageData['createdAt'] != null
                ? DateTime.tryParse(messageData['createdAt']) ?? DateTime.now()
                : DateTime.now();

            // Create new message with isNew: true for streaming messages
            final newMessage = {
              'id': messageId,
              'text': messageData['payload']['text'],
              'sender': messageData['userId'] == currentUserId ? 'user' : 'bot',
              'timestamp': now.toIso8601String(),
              'isNew': isFromStreaming, // Only new if from streaming
              'formattedTime':
                  '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
            };

            // FOR REVERSE LISTVIEW: Insert at beginning instead of end
            currentMessages.insert(0, newMessage);
            hasNewMessages = true;

            // If this is a bot message, stop typing indicator
            if (messageData['userId'] != currentUserId) {
              FFAppState().isBotTyping = false;
            }
          }
        } else {
          print('Invalid message structure or not a text message');
        }
      }

      // FOR REVERSE LISTVIEW: Sort in reverse order (newest first)
      if (hasNewMessages) {
        currentMessages.sort((a, b) {
          DateTime timeA =
              DateTime.tryParse(a['timestamp'] ?? '') ?? DateTime.now();
          DateTime timeB =
              DateTime.tryParse(b['timestamp'] ?? '') ?? DateTime.now();
          return timeB.compareTo(timeA); // Reverse order: newest first
        });

        FFAppState().update(() {
          FFAppState().chatMessages = currentMessages;
        });
      }
    }

    return currentMessages;
  } catch (e) {
    print('Error processing SSE message: $e');
    print('SSE Data that caused error: $apiResponse');
    return FFAppState().chatMessages ?? [];
  }
}
