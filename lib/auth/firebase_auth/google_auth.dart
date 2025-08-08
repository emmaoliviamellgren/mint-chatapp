import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

final _googleSignIn = GoogleSignIn.instance;

Future<UserCredential?> googleSignInFunc() async {
  if (kIsWeb) {
    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
  }

  try {
    // Initialize GoogleSignIn
    await _googleSignIn.initialize();

    // Sign out first to ensure clean state
    await signOutWithGoogle().catchError((_) => null);

    // Authenticate the user (this will show the sign-in UI)
    await _googleSignIn.authenticate();

    // Listen to authentication events to get the signed-in user
    GoogleSignInAccount? googleUser;

    // Set up a completer to wait for authentication
    final completer = Completer<GoogleSignInAccount?>();
    late StreamSubscription<GoogleSignInAuthenticationEvent> subscription;

    subscription = _googleSignIn.authenticationEvents.listen((event) {
      switch (event) {
        case GoogleSignInAuthenticationEventSignIn():
          subscription.cancel();
          completer.complete(event.user);
          break;
        case GoogleSignInAuthenticationEventSignOut():
          subscription.cancel();
          completer.complete(null);
          break;
      }
    });

    googleUser = await completer.future;

    if (googleUser == null) {
      return null;
    }

    // Get authentication tokens using the authorization client
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create credential for Firebase using idToken only initially
    // In version 7.x, access tokens might be handled differently
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  } catch (e) {
    print('Google sign in error: $e');
    return null;
  }
}

Future signOutWithGoogle() => _googleSignIn.signOut();
