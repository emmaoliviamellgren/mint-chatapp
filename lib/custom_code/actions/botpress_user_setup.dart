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

Future botpressUserSetup() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await docRef.get();

    // Only update if botpress fields don't exist
    if (!doc.exists || !doc.data()!.containsKey('botpress_user_key')) {
      await docRef.set({
        'botpress_user_key': null,
        'botpress_conversation_id': null,
        'botpress_last_chat_time': null,
      }, SetOptions(merge: true));
    }
  }
}
