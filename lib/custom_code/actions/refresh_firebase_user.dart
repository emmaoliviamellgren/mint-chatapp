import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart';
import '/flutter_flow/custom_functions.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future refreshFirebaseUser() async {
  try {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    if (userDoc.exists) {
      final userData = userDoc.data()!;

      final firestorePhotoUrl = userData['photo_url'] as String?;
      final firestoreDisplayName = userData['display_name'] as String?;

      if (firestorePhotoUrl != null &&
          firestorePhotoUrl.isNotEmpty &&
          firestorePhotoUrl != currentUser.photoURL) {
        await currentUser.updatePhotoURL(firestorePhotoUrl);
      }

      if (firestoreDisplayName != null &&
          firestoreDisplayName.isNotEmpty &&
          firestoreDisplayName != currentUser.displayName) {
        await currentUser.updateDisplayName(firestoreDisplayName);
      }

      await currentUser.reload();

      FFAppState().update(() {
        FFAppState().userDisplayName = firestoreDisplayName ?? 'User';
        FFAppState().userProfilePhoto = firestorePhotoUrl ?? '';
      });
    }
  } catch (e) {
    print('Error in refreshFirebaseUser: ${e.toString()}');
  }
}
