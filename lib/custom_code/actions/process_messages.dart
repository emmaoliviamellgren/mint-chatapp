import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart';
import '/flutter_flow/custom_functions.dart';
import 'package:flutter/material.dart';

Future<void> processMessages(
  dynamic apiResponse,
  String currentUserId,
  bool isFromStreaming,
) async {
  try {
    if (apiResponse == null) return;

    List<dynamic> currentMessages = List.from(FFAppState().chatMessages);
    bool hasChanges = false;
    
    List<dynamic> messagesToProcess = [];
    
    // Handle different response formats
    if (apiResponse is Map) {
      if (apiResponse.containsKey('messages')) {
        // Historical messages
        messagesToProcess = apiResponse['messages'] ?? [];
      } else if (apiResponse.containsKey('type') && apiResponse['type'] == 'message.created') {
        // SSE message
        messagesToProcess = [apiResponse['data']];
      } else if (apiResponse.containsKey('data')) {
        // Direct data format
        messagesToProcess = [apiResponse['data']];
      } else {
        // Fallback - treat whole response as message
        messagesToProcess = [apiResponse];
      }
    }

    for (var messageData in messagesToProcess) {
      // Check if we have valid message data
      if (messageData != null && 
          messageData['id'] != null && 
          messageData['payload'] != null &&
          messageData['payload']['type'] == 'text') {
        
        final messageId = messageData['id'].toString();
        
        // Check if message already exists
        final messageExists = currentMessages.any((m) => m['id'] == messageId);

        if (!messageExists) {
          final now = DateTime.tryParse(messageData['createdAt'] ?? '') ?? DateTime.now();
          final isUser = messageData['userId'] == currentUserId;
          
          // Remove typing indicator when bot message arrives
          if (!isUser && isFromStreaming) {
            currentMessages.removeWhere((msg) => 
              msg['isTyping'] == true || 
              msg['sender'] == 'typing'
            );
          }
          
          final newMessage = {
            'id': messageId,
            'text': messageData['payload']['text'],
            'sender': isUser ? 'user' : 'bot',
            'userId': messageData['userId'],
            'timestamp': now.toIso8601String(),
            'isNew': isFromStreaming && !isUser, // Mark bot messages from streaming as new for animation
          };
          
          currentMessages.insert(0, newMessage);
          hasChanges = true;
          
          print('Added ${isUser ? "user" : "bot"} message: ${messageData['payload']['text']}');
        }
      }
    }

    if (hasChanges) {
      // Sort messages by timestamp (newest first for reverse ListView)
      currentMessages.sort((a, b) =>
          (DateTime.tryParse(b['timestamp'] ?? '') ?? DateTime(1970))
              .compareTo(DateTime.tryParse(a['timestamp'] ?? '') ?? DateTime(1970)));
      
      // Update app state
      FFAppState().update(() {
        FFAppState().chatMessages = currentMessages;
      });
      
      print('Updated chat messages. Total count: ${currentMessages.length}');
    }
  } catch (e) {
    print('Error processing messages: $e');
  }
}