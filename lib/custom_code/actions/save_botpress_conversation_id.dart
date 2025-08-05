// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

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
      'botpress_last_chat_time': FieldValue.serverTimestamp(),
    });

    print('Successfully saved Botpress conversation ID to Firestore');
  } catch (e) {
    print('Error saving Botpress conversation ID: ${e.toString()}');
  }
}
