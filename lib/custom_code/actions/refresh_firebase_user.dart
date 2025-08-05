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

Future refreshFirebaseUser() async {
  try {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Only update Firebase Auth if there's a new photo URL
      if (FFAppState().userProfilePhoto != null &&
          FFAppState().userProfilePhoto!.isNotEmpty) {
        await currentUser.updatePhotoURL(FFAppState().userProfilePhoto!);
      }

      // Just update the app state display name if it changed
      FFAppState().userDisplayName = currentUser.displayName ?? 'User';
      FFAppState().update(() {});
    }
  } catch (e) {
    print('Error in quick refresh: ${e.toString()}');
  }
}
