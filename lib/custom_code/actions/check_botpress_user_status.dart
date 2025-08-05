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

/// Check if user has Botpress account
Future<String> checkBotpressUserStatus() async {
  try {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return 'no_auth';
    }

    // Get user document from Firestore
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    if (!userDoc.exists) {
      return 'no_firestore_doc';
    }

    final userData = userDoc.data()!;
    final existingUserKey = userData['botpress_user_key'] as String?;

    if (existingUserKey != null && existingUserKey.isNotEmpty) {
      return 'existing_user';
    } else {
      return 'new_user';
    }
  } catch (e) {
    print('Error checking Botpress user status: ${e.toString()}');
    return 'error';
  }
}
