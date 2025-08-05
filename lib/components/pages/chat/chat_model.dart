import '/backend/api_requests/api_calls.dart';
import '/backend/api_requests/api_manager.dart';
import '/components/loader_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'chat_widget.dart' show ChatWidget;
import 'package:flutter/material.dart';

class ChatModel extends FlutterFlowModel<ChatWidget> {
  ///  Local state fields for this page.

  String? currentMessage;

  bool isLoading = false;

  bool isSendingMessage = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - checkBotpressUserStatus] action in Chat widget.
  String? userStatusResult;
  // Stores action output result for [Custom Action - getBotpressUserKey] action in Chat widget.
  String? storedUserKeyResult;
  // Stores action output result for [Backend Call - API (createChatUser)] action in Chat widget.
  ApiCallResponse? createUserResult;
  // Stores action output result for [Custom Action - getBotpressConversationId] action in Chat widget.
  String? storedConversationId;
  // Stores action output result for [Backend Call - API (createChatConversation)] action in Chat widget.
  ApiCallResponse? createConversationResult;
  // Stores action output result for [Backend Call - API (listChatMessages)] action in Chat widget.
  ApiCallResponse? loadMessagesResult;
  // Model for Loader component.
  late LoaderModel loaderModel;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Stores action output result for [Backend Call - API (sendChatMessage)] action in IconButton widget.
  ApiCallResponse? messageResponse;

  @override
  void initState(BuildContext context) {
    loaderModel = createModel(context, () => LoaderModel());
  }

  @override
  void dispose() {
    loaderModel.dispose();
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
