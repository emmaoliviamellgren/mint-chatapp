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

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!

Future<void> handleFirebaseAuth(
  String email,
  String password,
  bool isSignUp,
) async {
  try {
    UserCredential userCredential;

    if (isSignUp) {
      userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // CREATE FIRESTORE DOCUMENT FOR NEW USER
      if (userCredential.user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'email': email,
          'firstName': '',
          'lastName': '',
          'displayName': '',
          'profilePhoto': '',
          'phoneNumber': '',
          'createdAt': FieldValue.serverTimestamp(),
          'lastActiveTime': FieldValue.serverTimestamp(),
          'profileComplete': false,
        });
      }
    } else {
      userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // UPDATE LAST ACTIVE TIME FOR LOGIN
      if (userCredential.user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .update({
          'lastActiveTime': FieldValue.serverTimestamp(),
        });
      }
    }

    // Success - Update App State
    FFAppState().update(() {
      FFAppState().hasFirebaseError = false;
      FFAppState().firebaseErrorMessage = '';
      FFAppState().isAuthLoading = false;
    });

    print('Auth success with Firestore doc: ${userCredential.user?.email}');
  } on FirebaseAuthException catch (e) {
    String errorMessage;

    switch (e.code) {
      case 'user-not-found':
        errorMessage = 'No account found with this email address.';
        break;
      case 'wrong-password':
        errorMessage = 'Incorrect password. Please try again.';
        break;
      case 'email-already-in-use':
        errorMessage = 'An account with this email already exists.';
        break;
      case 'weak-password':
        errorMessage = 'Password should be at least 6 characters long.';
        break;
      case 'invalid-email':
        errorMessage = 'Please enter a valid email address.';
        break;
      case 'user-disabled':
        errorMessage = 'This account has been disabled.';
        break;
      case 'too-many-requests':
        errorMessage = 'Too many failed attempts. Please try again later.';
        break;
      case 'operation-not-allowed':
        errorMessage = 'This sign-in method is not enabled.';
        break;
      case 'invalid-credential':
        errorMessage = 'The provided credentials are invalid.';
        break;
      case 'network-request-failed':
        errorMessage = 'Network error. Please check your connection.';
        break;
      default:
        errorMessage = e.message ?? 'An unexpected error occurred.';
    }

    // Error - Update App State
    FFAppState().update(() {
      FFAppState().hasFirebaseError = true;
      FFAppState().firebaseErrorMessage = errorMessage;
      FFAppState().isAuthLoading = false;
    });

    print('Auth error: ${e.code} - $errorMessage');
  } catch (e) {
    // Unknown error - Update App State
    FFAppState().update(() {
      FFAppState().hasFirebaseError = true;
      FFAppState().firebaseErrorMessage = 'An unexpected error occurred.';
      FFAppState().isAuthLoading = false;
    });

    print('Unknown error: ${e.toString()}');
  }
}
