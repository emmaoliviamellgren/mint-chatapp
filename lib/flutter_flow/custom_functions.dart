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

  List<ChatbotsRecord> filteredList = List.from(allChatbots);

  if (filterType != null && filterType.isNotEmpty && filterType != "all") {
    filteredList = filteredList.where((chatbot) {
      switch (filterType.toLowerCase()) {
        case "popular":
          return chatbot.tags?.contains("popular") == true;
        case "favorite":
          return chatbot.tags?.contains("favorite") == true;
        default:
          return true;
      }
    }).toList();
  }

  // search text filter
  if (searchText != null && searchText.trim().isNotEmpty) {
    final searchLower = searchText.trim().toLowerCase();
    filteredList = filteredList.where((chatbot) {
      bool nameMatch =
          chatbot?.name?.toLowerCase().contains(searchLower) == true;
      bool descriptionMatch =
          chatbot?.description?.toLowerCase().contains(searchLower) == true;
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
  bool hasSelectedPhoto,
) {
  // Check if names have changed
  bool namesChanged =
      (currentFirst != originalFirst) || (currentLast != originalLast);

  // Enable button if either names changed OR photo selected
  bool shouldEnable = namesChanged || hasSelectedPhoto;

  return !shouldEnable;
}

dynamic createMessage(
  String text,
  String sender,
  DateTime? timestamp,
  bool? isNew,
) {
  final now = timestamp ?? DateTime.now();
  return {
    'id': DateTime.now().millisecondsSinceEpoch.toString(),
    'text': text,
    'sender': sender,
    'timestamp': now.toIso8601String(),
    'isNew': isNew ?? false,
    'formattedTime':
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
  };
}

List<dynamic> getChatMessages(List<dynamic> chatMessages) {
  return List.from(chatMessages ?? []);
}

bool shouldCompleteAnimation(
  dynamic message,
  int messageIndex,
) {
  try {
    // Check if it's a typing placeholder message
    final messageText = message['text']?.toString() ?? '';
    if (messageText == 'TYPING_PLACEHOLDER') {
      return false; // Don't complete - should animate
    }

    // Check if message has isNew flag and is at index 0 (newest message in reverse list)
    final isNew = message['isNew'];
    if ((isNew == true || isNew == 'true') && messageIndex == 0) {
      return false; // Don't complete - should animate
    }

    // Complete animation for all other cases
    return true;
  } catch (e) {
    print('Error in shouldCompleteAnimation: $e');
    return true;
  }
}
