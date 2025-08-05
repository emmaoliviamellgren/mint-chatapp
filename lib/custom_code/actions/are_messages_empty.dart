// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

Future<bool> areMessagesEmpty(dynamic apiResponse) async {
  try {
    if (apiResponse == null) {
      return true;
    }
    if (apiResponse['messages'] == null) {
      return true;
    }

    // Get the messages array
    List messages = apiResponse['messages'] as List;
    return messages.isEmpty;
  } catch (e) {
    print('Error checking if messages are empty: ${e.toString()}');
    return true;
  }
}
