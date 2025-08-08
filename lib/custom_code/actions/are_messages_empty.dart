import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart';
import '/flutter_flow/custom_functions.dart';
import 'package:flutter/material.dart';

Future<bool> areMessagesEmpty(dynamic apiResponse) async {
  try {
    if (apiResponse == null) {
      return true;
    }
    if (apiResponse['messages'] == null) {
      return true;
    }

    List messages = apiResponse['messages'] as List;
    return messages.isEmpty;
  } catch (e) {
    print('Error checking if messages are empty: ${e.toString()}');
    return true;
  }
}
