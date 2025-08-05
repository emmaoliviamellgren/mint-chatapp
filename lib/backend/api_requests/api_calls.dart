import 'dart:convert';
import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

class CreateChatUserCall {
  static Future<ApiCallResponse> call({
    String? userId = '',
  }) async {
    final ffApiRequestBody = '''
{
  "id": "${escapeStringForJson(userId)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'createChatUser',
      apiUrl:
          'https://chat.botpress.cloud/ea356259-4e7b-4120-ae01-89f37ef5d3c3/users',
      callType: ApiCallType.POST,
      headers: {},
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
  }) async {
    final ffApiRequestBody = '''
{}''';
    return ApiManager.instance.makeApiCall(
      callName: 'createChatConversation',
      apiUrl:
          'https://chat.botpress.cloud/ea356259-4e7b-4120-ae01-89f37ef5d3c3/conversations',
      callType: ApiCallType.POST,
      headers: {
        'x-user-key': '${userKey}',
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
    String? text = '',
  }) async {
    final ffApiRequestBody = '''
{
  "payload": {
    "type": "text",
    "text": "${escapeStringForJson(text)}"
  },
  "conversationId": "${escapeStringForJson(conversationId)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'sendChatMessage',
      apiUrl:
          'https://chat.botpress.cloud/ea356259-4e7b-4120-ae01-89f37ef5d3c3/messages',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'x-user-key': '${userKey}',
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

class ListChatMessagesCall {
  static Future<ApiCallResponse> call({
    String? conversationId = '',
    String? userKey = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'listChatMessages',
      apiUrl:
          'https://chat.botpress.cloud/ea356259-4e7b-4120-ae01-89f37ef5d3c3/conversations/${conversationId}/messages',
      callType: ApiCallType.GET,
      headers: {
        'x-user-key': '${userKey}',
      },
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

class GetChatUserCall {
  static Future<ApiCallResponse> call({
    String? userKey = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getChatUser',
      apiUrl:
          'https://chat.botpress.cloud/ea356259-4e7b-4120-ae01-89f37ef5d3c3/users/me',
      callType: ApiCallType.GET,
      headers: {
        'x-user-key': '${userKey}',
      },
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

class ListenToChatConversationCall {
  static Future<ApiCallResponse> call({
    String? conversationId = '',
    String? userKey = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'listenToChatConversation',
      apiUrl:
          'https://chat.botpress.cloud/ea356259-4e7b-4120-ae01-89f37ef5d3c3/conversations/${conversationId}/listen',
      callType: ApiCallType.GET,
      headers: {
        'x-user-key': '${userKey}',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: true,
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
