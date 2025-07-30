import 'dart:convert';
import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

class InitializeBotPressConversationCall {
  static Future<ApiCallResponse> call() async {
    final ffApiRequestBody = '''
{
  "integrationName": "api",
  "channel": "api",
  "tags": {}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'initializeBotPressConversation',
      apiUrl: 'https://api.botpress.cloud/v1/chat/conversations',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer bp_pat_0BlMwWjwbU35hl6tZIl4c3beAnshE4zZtdVc',
        'x-bot-id': '2c28bc34-3bae-4112-ae29-978eb231dee6',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class SendMessageToBotPressCall {
  static Future<ApiCallResponse> call({
    String? conversationId = '',
    String? message = '',
    String? userId = '',
  }) async {
    final ffApiRequestBody = '''
{
  "conversationId": "\$conversationId",
  "payload": {
    "type": "text",
    "text": "\$message"
  },
  "channel": "api",
  "tags": {},
  "userId": "\$userId"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'sendMessageToBotPress',
      apiUrl: 'https://api.botpress.cloud/v1/chat/messages',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer 2c28bc34-3bae-4112-ae29-978eb231dee6',
        'x-bot-id': '2c28bc34-3bae-4112-ae29-978eb231dee6',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class CreateChatUserCall {
  static Future<ApiCallResponse> call({
    String? userId = '',
  }) async {
    final ffApiRequestBody = '''
{
  "id": "\$userId",
  "name": "User"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'createChatUser',
      apiUrl:
          'https://chat.botpress.cloud/c05e40ad-fe6f-4461-ba87-9057867cd6e1/users',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class CreateChatConversationCall {
  static Future<ApiCallResponse> call({
    String? userKey = '',
    String? conversationId = '',
  }) async {
    final ffApiRequestBody = '''
{
  "id": "\$conversationId"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'createChatConversation',
      apiUrl:
          'https://chat.botpress.cloud/c05e40ad-fe6f-4461-ba87-9057867cd6e1/conversations',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'x-user-key': '\$userKey',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class SendChatMessageCall {
  static Future<ApiCallResponse> call({
    String? userKey = '',
    String? conversationId = '',
    String? message = '',
  }) async {
    final ffApiRequestBody = '''
{
  "type": "text",
  "text": "\$message"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'sendChatMessage',
      apiUrl:
          'https://chat.botpress.cloud/c05e40ad-fe6f-4461-ba87-9057867cd6e1/conversations/\$conversationId/messages',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'x-user-key': '\$userKey',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class CheckCall {
  static Future<ApiCallResponse> call() async {
    return ApiManager.instance.makeApiCall(
      callName: 'check',
      apiUrl:
          'https://chat.botpress.cloud/c05e40ad-fe6f-4461-ba87-9057867cd6e1/hello',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _toEncodable(dynamic item) {
  if (item is DocumentReference) {
    return item.path;
  }
  return item;
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("List serialization failed. Returning empty list.");
    }
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
}

String? escapeStringForJson(String? input) {
  if (input == null) {
    return null;
  }
  return input
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\n')
      .replaceAll('\t', '\\t');
}
