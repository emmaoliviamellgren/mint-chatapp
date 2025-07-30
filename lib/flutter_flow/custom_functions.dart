import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'lat_lng.dart';
import 'place.dart';
import 'uploaded_file.dart';
import '/backend/backend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';

List<ChatbotsRecord> filterChatbots(
  List<ChatbotsRecord>? allChatbots,
  String? searchText,
  String? filterType,
) {
  if (allChatbots == null || allChatbots.isEmpty) return [];

  // Start with all chatbots
  List<ChatbotsRecord> filteredList = List.from(allChatbots);

  // Apply dropdown filter first
  if (filterType != null && filterType.isNotEmpty && filterType != "all") {
    filteredList = filteredList.where((chatbot) {
      switch (filterType.toLowerCase()) {
        case "popular":
          // Option 1: Using tags array
          return chatbot.tags?.contains("popular") == true;

        // Option 2: Using category field
        // return chatbot.category == "popular";

        // Option 3: Using usage count (for future BotPress analytics)
        // return (chatbot.usageCount ?? 0) > 50;

        case "favorite":
          // Option 1: Using tags array
          return chatbot.tags?.contains("favorite") == true;

        // Option 2: Using featured flag
        // return chatbot.isFeatured == true;

        // Option 3: Using rating (for future user ratings)
        // return (chatbot.rating ?? 0) >= 4.0;

        default:
          return true;
      }
    }).toList();
  }

  // Apply search text filter
  if (searchText != null && searchText.trim().isNotEmpty) {
    final searchLower = searchText.trim().toLowerCase();
    filteredList = filteredList.where((chatbot) {
      // Search in name
      bool nameMatch =
          chatbot?.name?.toLowerCase().contains(searchLower) == true;

      // Search in description (optional)
      bool descriptionMatch =
          chatbot?.description?.toLowerCase().contains(searchLower) == true;

      // Search in tags (helpful for BotPress categorization)
      bool tagMatch = chatbot?.tags
              ?.any((tag) => tag.toLowerCase().contains(searchLower)) ==
          true;

      return nameMatch || descriptionMatch || tagMatch;
    }).toList();
  }

  return filteredList;
}

bool shouldDisableUpdateProfileButton(
  String? currentFirst,
  String? currentLast,
  String? originalFirst,
  String? originalLast,
) {
  return (currentFirst == originalFirst) && (currentLast == originalLast);
}

String generateUserId() {
  return DateTime.now().millisecondsSinceEpoch.toString();
}

dynamic createMessage(
  String? text,
  String? sender,
  DateTime? timestamp,
) {
  final now = timestamp ?? DateTime.now();
  return {
    'id': DateTime.now().millisecondsSinceEpoch.toString(),
    'text': text,
    'sender': sender,
    'timestamp': now.toIso8601String(),
    'formattedTime':
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
  };
}

String formatMessageTime(DateTime timestamp) {
  return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
}

bool isValidConversationId(String? conversationId) {
  return conversationId != null && conversationId.isNotEmpty;
}

String cleanUserInput(String input) {
  return input.trim();
}

bool canSendMessage(
  String input,
  String? conversationId,
  bool isLoading,
) {
  return input.trim().isNotEmpty &&
      conversationId != null &&
      conversationId.isNotEmpty &&
      !isLoading;
}

List<dynamic> extractBotMessages(dynamic apiResponse) {
  List<dynamic> botMessages = [];

  if (apiResponse != null && apiResponse['messages'] != null) {
    List messages = apiResponse['messages'];

    for (var message in messages) {
      if (message['payload'] != null && message['payload']['type'] == 'text') {
        final now = message['createdAt'] != null
            ? DateTime.tryParse(message['createdAt']) ?? DateTime.now()
            : DateTime.now();

        Map<String, dynamic> botMessage = {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'text': message['payload']['text'],
          'sender': 'bot',
          'timestamp': now.toIso8601String(),
          'formattedTime':
              '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        };

        botMessages.add(botMessage);
      }
    }
  }

  if (botMessages.isEmpty) {
    final now = DateTime.now();
    Map<String, dynamic> errorMessage = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'text': 'Sorry, I encountered an error. Please try again.',
      'sender': 'bot',
      'timestamp': now.toIso8601String(),
      'formattedTime':
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
    };

    botMessages.add(errorMessage);
  }

  return botMessages;
}

dynamic getFirstBotMessage(dynamic apiResponse) {
  if (apiResponse != null && apiResponse['messages'] != null) {
    List messages = apiResponse['messages'];

    for (var message in messages) {
      if (message['payload'] != null && message['payload']['type'] == 'text') {
        final now = message['createdAt'] != null
            ? DateTime.tryParse(message['createdAt']) ?? DateTime.now()
            : DateTime.now();

        return {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'text': message['payload']['text'],
          'sender': 'bot',
          'timestamp': now.toIso8601String(),
          'formattedTime':
              '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        };
      }
    }
  }

// Default error message
  final now = DateTime.now();
  return {
    'id': DateTime.now().millisecondsSinceEpoch.toString(),
    'text': 'Sorry, I encountered an error. Please try again.',
    'sender': 'bot',
    'timestamp': now.toIso8601String(),
    'formattedTime':
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
  };
}
