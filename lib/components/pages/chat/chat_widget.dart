import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/api_requests/api_streaming.dart';
import '/backend/backend.dart';
import '/components/loader_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:async';
import 'dart:convert';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'chat_model.dart';
import '/components/voice_input_widget.dart';

export 'chat_model.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget({super.key});

  static String routeName = 'Chat';
  static String routePath = '/chat';

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget>
    with AutomaticKeepAliveClientMixin {
  late ChatModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _scrollController = ScrollController();
  StreamSubscription? _streamSubscription;
  bool _isInitialized = false;
  bool _isBotTyping = false;
  final Set<String> _animatedMessageIds = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChatModel());
    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isInitialized) {
        _initializeChat();
      }
    });
  }

  void safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  Future<void> _initializeChat() async {
    if (_isInitialized || !mounted) return;

    safeSetState(() => _model.isLoading = true);

    try {
      final userStatus = await actions.checkBotpressUserStatus();
      String botpressUserId;

      if (userStatus == 'existing_user') {
        // User already exists, get the stored key and user ID
        final storedUserKey = await actions.getBotpressUserKey();
        final storedBotpressUserId = await actions.getBotpressUserId();

        if (storedUserKey.isNotEmpty && storedBotpressUserId.isNotEmpty) {
          FFAppState().userKey = storedUserKey;
          botpressUserId = storedBotpressUserId;
        } else {
          throw Exception('Stored user data is incomplete');
        }
      } else {
        // Create new user with a unique identifier for Botpress
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        botpressUserId = '${currentUserUid}_$timestamp';

        final createUserResult = await CreateChatUserCall.call(
          userId: botpressUserId,
        );

        if (createUserResult.succeeded) {
          FFAppState().userKey =
              getJsonField(createUserResult.jsonBody, r'''$.key''').toString();

          // Store both the key and the user ID
          await actions.saveBotpressUserKey(FFAppState().userKey);
          await actions.saveBotpressUserId(botpressUserId);
        } else {
          print('Create user failed: ${createUserResult.statusCode}');
          print('Error body: ${createUserResult.bodyText}');
          throw Exception(
              'Error creating user: ${createUserResult.statusCode}');
        }
      }

      // Store the Botpress user ID in app state for message comparison
      FFAppState().botpressUserId = botpressUserId;

      final storedConversationId = await actions.getBotpressConversationId();
      if (storedConversationId != null && storedConversationId.isNotEmpty) {
        FFAppState().conversationId = storedConversationId;
      } else {
        final createConversationResult = await CreateChatConversationCall.call(
            userKey: FFAppState().userKey);

        if (createConversationResult.succeeded) {
          FFAppState().conversationId = getJsonField(
                  createConversationResult.jsonBody, r'''$.conversation.id''')
              .toString();
          await actions.saveBotpressConversationId(FFAppState().conversationId);
        } else {
          print(
              'Create conversation failed: ${createConversationResult.statusCode}');
          print('Error body: ${createConversationResult.bodyText}');
          throw Exception(
              'Error creating conversation: ${createConversationResult.statusCode}');
        }
      }

      FFAppState().chatMessages = [];
      final loadMessagesResult = await ListChatMessagesCall.call(
          userKey: FFAppState().userKey,
          conversationId: FFAppState().conversationId);

      if (loadMessagesResult.succeeded) {
        await actions.processMessages(
            loadMessagesResult.jsonBody, botpressUserId, false);

        final isEmpty =
            await actions.areMessagesEmpty(loadMessagesResult.jsonBody);
        if (isEmpty) {
          await actions.addInitialMessage();
        }
      } else {
        print('Load messages failed: ${loadMessagesResult.statusCode}');
        throw Exception(
            'Error loading messages: ${loadMessagesResult.statusCode}');
      }

      await _listenToStream();
      _isInitialized = true;
    } catch (e) {
      print('Full initialization error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to initialize chat: ${e.toString()}'),
            backgroundColor: FlutterFlowTheme.of(context).error));
      }
    } finally {
      safeSetState(() => _model.isLoading = false);
    }
  }

  Future<void> _listenToStream() async {
    await _streamSubscription?.cancel();
    final streamingApiResult = await ListenToChatConversationCall.call(
        userKey: FFAppState().userKey,
        conversationId: FFAppState().conversationId);

    if (streamingApiResult.succeeded && mounted) {
      _streamSubscription = streamingApiResult.streamedResponse?.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .transform(ServerSentEventLineTransformer())
          .map((m) => ResponseStreamMessage(message: m))
          .listen(
        (onMessageInput) async {
          if (!mounted) return;
          final dynamic jsonData = onMessageInput.serverSentEvent.jsonData;
          if (jsonData == null) return;

          final messagePayload = getJsonField(jsonData, r'''$.data''') ??
              getJsonField(jsonData, r'''$.payload''');
          if (messagePayload == null) return;

          final incomingUserId =
              getJsonField(messagePayload, r'''$.userId''').toString();
          if (incomingUserId != FFAppState().botpressUserId && _isBotTyping) {
            safeSetState(() => _isBotTyping = false);
          }

          await actions.processMessages(
              jsonData, FFAppState().botpressUserId, true);
          _scrollToBottom();
        },
        onError: (error) {
          print('SSE Stream error: $error');
          if (_isBotTyping) {
            safeSetState(() => _isBotTyping = false);
          }
        },
        onDone: () {
          if (_isBotTyping) {
            safeSetState(() => _isBotTyping = false);
          }
        },
      );
    }
  }

  Future<void> _handleSendMessage() async {
    final messageText = _model.textController.text;
    if (messageText.isEmpty || _model.isSendingMessage) return;

    safeSetState(() => _model.isSendingMessage = true);
    final messageToSend = _model.textController.text;
    _model.textController?.clear();
    FocusScope.of(context).unfocus();

    try {
      await SendChatMessageCall.call(
          userKey: FFAppState().userKey,
          conversationId: FFAppState().conversationId,
          text: messageToSend);

      // Show typing indicator AFTER sending (so user message appears first through stream)
      await Future.delayed(Duration(milliseconds: 200));
      if (mounted) {
        safeSetState(() => _isBotTyping = true);
        _scrollToBottom(isAnimated: true);
      }
    } catch (e) {
      print('Error sending message: $e');
    } finally {
      _model.isSendingMessage = false;
      if (mounted) safeSetState(() {});
    }
  }

  void _scrollToBottom({bool isAnimated = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        try {
          _scrollController.animateTo(
            0.0,
            duration: Duration(milliseconds: isAnimated ? 300 : 200),
            curve: Curves.easeOut,
          );
        } catch (e) {
          print('Could not perform scroll animation: $e');
        }
      }
    });
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _model.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    context.watch<FFAppState>();
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          automaticallyImplyLeading: false,
          title: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 10.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FlutterFlowIconButton(
                  borderColor: Colors.transparent,
                  borderRadius: 30.0,
                  borderWidth: 1.0,
                  buttonSize: 40.0,
                  icon: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: FlutterFlowTheme.of(context).primary,
                    size: 20.0,
                  ),
                  onPressed: () async {
                    context.pushNamed(UserDashboardWidget.routeName);
                  },
                ),
                Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.smart_toy_rounded,
                    color: Colors.white,
                    size: 24.0,
                  ),
                ),
                FutureBuilder<List<ChatbotsRecord>>(
                  future: queryChatbotsRecordOnce(singleRecord: true),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return SizedBox.shrink();
                    }
                    final columnChatbotsRecord =
                        snapshot.data!.isNotEmpty ? snapshot.data!.first : null;
                    return Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'You\'re chatting with',
                          style:
                              FlutterFlowTheme.of(context).labelSmall.override(
                                    font: GoogleFonts.manrope(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context).success,
                                  ),
                        ),
                        Text(
                          valueOrDefault<String>(
                              columnChatbotsRecord?.name, 'AI Assistant'),
                          style:
                              FlutterFlowTheme.of(context).titleMedium.override(
                                    font: GoogleFonts.manrope(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .fontStyle,
                                    ),
                                  ),
                        ),
                      ],
                    );
                  },
                ),
              ].divide(SizedBox(width: 12.0)),
            ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 1.0,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
            child: Column(
              children: [
                Expanded(
                  child: _model.isLoading
                      ? LoaderWidget()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.zero,
                          reverse: true,
                          itemCount: FFAppState().chatMessages.length +
                              (_isBotTyping ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (_isBotTyping && index == 0) {
                              return _buildTypingIndicator();
                            }
                            final messageIndex =
                                _isBotTyping ? index - 1 : index;
                            final message =
                                FFAppState().chatMessages[messageIndex];
                            return _buildMessageBubble(message, messageIndex);
                          },
                        ),
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 25.0),
                    child: Container(
                      decoration: BoxDecoration(),
                      child: Align(
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 10.0, 0.0, 10.0),
                          child: SafeArea(
                            child: Container(
                              width: double.infinity,
                              height: 60.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(30.0),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).alternate,
                                  width: 1.0,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16.0, 0.0, 16.0, 0.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Icon(Icons.add,
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        size: 24.0),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _model.textController,
                                        focusNode: _model.textFieldFocusNode,
                                        onFieldSubmitted: (value) =>
                                            _handleSendMessage(),
                                        autofocus: true,
                                        textInputAction: TextInputAction.send,
                                        decoration: InputDecoration(
                                          hintText: 'Ask anything',
                                          hintStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .override(
                                                    font: GoogleFonts.manrope(
                                                      fontWeight:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                    ),
                                                    color: Color(0x7D57636C),
                                                  ),
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          focusedErrorBorder: InputBorder.none,
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.manrope(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                            ),
                                      ),
                                    ),
                                    // REPLACE the static mic icon with the VoiceInputWidget
                                    VoiceInputWidget(
                                      onTextReceived: (recognizedText) {
                                        _model.textController?.text =
                                            recognizedText;
                                        // Optionally auto-send the message after voice input
                                        // Future.delayed(Duration(milliseconds: 300), () {
                                        //   _handleSendMessage();
                                        // });
                                      },
                                      isEnabled: !_model.isSendingMessage,
                                    ),
                                    FlutterFlowIconButton(
                                      borderRadius: 8.0,
                                      buttonSize: 40.0,
                                      fillColor:
                                          FlutterFlowTheme.of(context).primary,
                                      icon: Icon(
                                        Icons.send_rounded,
                                        color:
                                            FlutterFlowTheme.of(context).info,
                                        size: 24.0,
                                      ),
                                      showLoadingIndicator:
                                          _model.isSendingMessage,
                                      onPressed: _model.isSendingMessage
                                          ? null
                                          : _handleSendMessage,
                                    ),
                                  ].divide(SizedBox(width: 12.0)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, int index) {
    if (message['sender'] == null || message['text'] == null)
      return SizedBox.shrink();

    final isUser = message['sender'].toString() == 'user';
    final text = message['text'].toString();
    final messageId = (message['id'] ?? message['timestamp']).toString();

    final bool shouldAnimate = !isUser &&
        index == 0 &&
        message['isNew'] == true &&
        !_animatedMessageIds.contains(messageId);

    if (isUser) {
      return Padding(
        padding: EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 10.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                constraints: BoxConstraints(minHeight: 43.0),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primary,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    text,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.manrope(
                            fontWeight: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                          color: FlutterFlowTheme.of(context).info,
                        ),
                  ),
                ),
              ),
            ),
            Container(
              width: 36.0,
              height: 36.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).alternate,
                shape: BoxShape.circle,
              ),
              child: Align(
                alignment: AlignmentDirectional(0.0, 0.0),
                child: Icon(
                  Icons.face,
                  color: FlutterFlowTheme.of(context).tertiary,
                  size: 24.0,
                ),
              ),
            ),
          ].divide(SizedBox(width: 12.0)),
        ),
      );
    } else {
      final botTextStyle = FlutterFlowTheme.of(context).bodyMedium.override(
            font: GoogleFonts.manrope(
              fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
            ),
          );
      return Padding(
        padding: EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 10.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36.0,
              height: 36.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primary,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.smart_toy_rounded,
                  color: Colors.white, size: 20.0),
            ),
            Container(
              width: 260.0,
              constraints: BoxConstraints(minHeight: 43.0),
              decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(16.0)),
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: shouldAnimate
                    ? custom_widgets.BotMessage(
                        key: Key(messageId),
                        text: text,
                        textColor: FlutterFlowTheme.of(context).primaryText,
                        dotColor: FlutterFlowTheme.of(context).primary,
                        onComplete: () {
                          if (mounted) _animatedMessageIds.add(messageId);
                        },
                      )
                    : Text(text, style: botTextStyle),
              ),
            ),
          ].divide(SizedBox(width: 12.0)),
        ),
      );
    }
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 10.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.0,
            height: 36.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primary,
              shape: BoxShape.circle,
            ),
            child:
                Icon(Icons.smart_toy_rounded, color: Colors.white, size: 20.0),
          ),
          Container(
            constraints: BoxConstraints(minHeight: 43.0),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: custom_widgets.TypingIndicator(
                height: 20.0,
                dotColor: FlutterFlowTheme.of(context).primary,
                dotSize: 6.0,
              ),
            ),
          ),
        ].divide(SizedBox(width: 12.0)),
      ),
    );
  }
}
