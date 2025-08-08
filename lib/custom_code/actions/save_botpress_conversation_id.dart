import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart';
import '/flutter_flow/custom_functions.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Save conversation ID to Firestore
Future saveBotpressConversationId(String conversationId) async {
  try {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('No authenticated user found');
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .update({
      'botpress_conversation_id': conversationId,
      'botpress_last_chat_time': DateTime.now().toIso8601String(),
    });

  } catch (e) {
    print('Error saving Botpress conversation ID: ${e.toString()}');
  }
}
