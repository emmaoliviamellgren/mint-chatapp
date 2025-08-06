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
    if (apiResponse is Map && apiResponse.containsKey('messages')) {
      messagesToProcess = apiResponse['messages'] ?? []; // Historik
    } else if (apiResponse is Map && apiResponse.containsKey('type') && apiResponse['type'] == 'message.created') {
      messagesToProcess = [apiResponse['data']]; // SSE-meddelande
    } else if (apiResponse is Map) {
      messagesToProcess = [apiResponse]; // Fallback för andra format
    }

    for (var messageData in messagesToProcess) {
      // Dubbelkolla att vi har all nödvändig data
      if (messageData?['id'] != null && messageData?['payload']?['type'] == 'text') {
        final messageId = messageData['id'].toString();
        
        final messageExists = currentMessages.any((m) => m['id'] == messageId);

        if (!messageExists) {
          final now = DateTime.tryParse(messageData['createdAt'] ?? '') ?? DateTime.now();
          final newMessage = {
            'id': messageId,
            'text': messageData['payload']['text'],
            'sender': messageData['userId'] == currentUserId ? 'user' : 'bot',
            'userId': messageData['userId'],
            'timestamp': now.toIso8601String(),
          };
          currentMessages.insert(0, newMessage);
          hasChanges = true;
        }
      }
    }

    if (hasChanges) {
      // Sortera listan för att säkerställa korrekt ordning
      currentMessages.sort((a, b) =>
          (DateTime.tryParse(b['timestamp'] ?? '') ?? DateTime(1970))
              .compareTo(DateTime.tryParse(a['timestamp'] ?? '') ?? DateTime(1970)));
      
      // Använd en säker uppdatering
      FFAppState().update(() {
        FFAppState().chatMessages = currentMessages;
      });
    }
  } catch (e) {
    print('Error processing messages: $e');
  }
}