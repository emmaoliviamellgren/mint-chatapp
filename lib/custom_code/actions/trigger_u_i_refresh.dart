// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// I want to trigger a refresh/ update of the UI

Future triggerUIRefresh() async {
  // Get the current app state instance
  final appState = FFAppState();

  // Trigger a UI update by calling the update method
  appState.update(() {
    // Force a rebuild by updating the app state
    // This will notify all listeners and trigger UI refresh
  });

  // Add a small delay to ensure the UI has time to process the update
  await Future.delayed(const Duration(milliseconds: 50));
}
