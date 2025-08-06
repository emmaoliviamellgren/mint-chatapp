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

Future updateFirebaseDisplayName(String displayName) async {
  try {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }

    // Update Firebase Auth display name
    await currentUser.updateDisplayName(displayName);

    // Reload user to refresh FlutterFlow's cached data
    await currentUser.reload();

  } catch (e) {
    print('Error updating Firebase Auth display name: ${e.toString()}');
  }
}
