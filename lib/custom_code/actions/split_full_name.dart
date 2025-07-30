// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

Future<dynamic> splitFullName(String? fullName) async {
  String firstName = '';
  String lastName = '';

  // Handle null or empty name
  if (fullName == null || fullName.trim().isEmpty) {
    return {
      'firstName': firstName,
      'lastName': lastName,
    };
  }

  // Clean up the name (remove extra spaces)
  String cleanName = fullName.trim();

  // Split by spaces
  List<String> nameParts = cleanName.split(' ');

  if (nameParts.length == 1) {
    // Only one name provided - treat as first name
    firstName = nameParts[0];
  } else if (nameParts.length == 2) {
    // Two names - first and last
    firstName = nameParts[0];
    lastName = nameParts[1];
  } else if (nameParts.length > 2) {
    // Multiple names - first name is first part, last name is everything else
    firstName = nameParts[0];
    lastName = nameParts.sublist(1).join(' ');
  }

  return {
    'firstName': firstName,
    'lastName': lastName,
  };
}
