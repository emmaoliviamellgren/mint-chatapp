import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/api_requests/api_manager.dart';
import '/backend/api_requests/api_streaming.dart';
import '/backend/backend.dart';
import '/components/loader_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:convert';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'chat_model.dart';
export 'chat_model.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget({super.key});

  static String routeName = 'Chat';
  static String routePath = '/chat';

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  late ChatModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChatModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      // Init isBotTyping as false
      FFAppState().isBotTyping = false;
      safeSetState(() {});
      // Set loading
      _model.isLoading = true;
      safeSetState(() {});
      // Check Botpress User Status
      _model.userStatusResult = await actions.checkBotpressUserStatus();
      if (_model.userStatusResult == 'existing_user') {
        // Get Stored User Key
        _model.storedUserKeyResult = await actions.getBotpressUserKey();
        // Update App State with User Key
        FFAppState().userKey = _model.storedUserKeyResult!;
        safeSetState(() {});
      } else {
        // Create new user
        _model.createUserResult = await CreateChatUserCall.call(
          userId: currentUserUid,
        );

        if ((_model.createUserResult?.succeeded ?? true)) {
          // Update App State with New User Key
          FFAppState().userKey = getJsonField(
            (_model.createUserResult?.jsonBody ?? ''),
            r'''$.key''',
          ).toString();
          safeSetState(() {});
          // Save User Key to Firestore
          await actions.saveBotpressUserKey(
            getJsonField(
              (_model.createUserResult?.jsonBody ?? ''),
              r'''$.key''',
            ).toString(),
          );
        } else {
          // Error handling
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error creating user: ${(_model.createUserResult?.bodyText ?? '')}',
                style: TextStyle(
                  color: FlutterFlowTheme.of(context).primaryText,
                ),
              ),
              duration: Duration(milliseconds: 4000),
              backgroundColor: FlutterFlowTheme.of(context).error,
            ),
          );
          return;
        }
      }

      // Get Stored Conversation ID
      _model.storedConversationId = await actions.getBotpressConversationId();
      if (_model.storedConversationId != '') {
        // Use Stored Conversation ID
        FFAppState().conversationId = _model.storedConversationId!;
        safeSetState(() {});
      } else {
        // Create New Conversation
        _model.createConversationResult = await CreateChatConversationCall.call(
          userKey: FFAppState().userKey,
        );

        if ((_model.createConversationResult?.succeeded ?? true)) {
          // Store New Conversation ID
          FFAppState().conversationId = getJsonField(
            (_model.createConversationResult?.jsonBody ?? ''),
            r'''$.conversation.id''',
          ).toString();
          safeSetState(() {});
          // Save Conversation ID to Firestore
          await actions.saveBotpressConversationId(
            getJsonField(
              (_model.createConversationResult?.jsonBody ?? ''),
              r'''$.conversation.id''',
            ).toString(),
          );
        } else {
          // Error handling
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error creating conversation: ${(_model.createConversationResult?.bodyText ?? '')}',
                style: TextStyle(
                  color: FlutterFlowTheme.of(context).primaryText,
                ),
              ),
              duration: Duration(milliseconds: 4000),
              backgroundColor: FlutterFlowTheme.of(context).error,
            ),
          );
          return;
        }
      }

      if ((FFAppState().userKey != '') &&
          (FFAppState().conversationId != '')) {
        // Load Existing Messages
        _model.loadMessagesResult = await ListChatMessagesCall.call(
          userKey: FFAppState().userKey,
          conversationId: FFAppState().conversationId,
        );

        if ((_model.loadMessagesResult?.succeeded ?? true)) {
          // Process and display messages
          await actions.processMessages(
            (_model.loadMessagesResult?.jsonBody ?? ''),
            currentUserUid,
            false,
          );
          _model.isLoading = false;
          safeSetState(() {});
        } else {
          // Error handling
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error loading messages: ${(_model.loadMessagesResult?.bodyText ?? '')}',
                style: TextStyle(
                  color: FlutterFlowTheme.of(context).primaryText,
                ),
              ),
              duration: Duration(milliseconds: 4000),
              backgroundColor: FlutterFlowTheme.of(context).error,
            ),
          );
          return;
        }

        // Botpress SSE Stream
        final streamingApiResult1 = await ListenToChatConversationCall.call(
          userKey: FFAppState().userKey,
          conversationId: FFAppState().conversationId,
        );
        if (streamingApiResult1.succeeded ?? true) {
          final streamSubscription = streamingApiResult1
              .streamedResponse?.stream
              .transform(utf8.decoder)
              .transform(const LineSplitter())
              .transform(ServerSentEventLineTransformer())
              .map((m) => ResponseStreamMessage(message: m))
              .listen(
            (onMessageInput) async {
              await actions.processMessages(
                onMessageInput.serverSentEvent.jsonData,
                currentUserUid,
                true,
              );
              await actions.triggerUIRefresh();
              FFAppState().isBotTyping = false;
              safeSetState(() {});
            },
            onError: (onErrorInput) async {
              // Reconnecting info
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Connection lost, reconnecting...',
                    style: FlutterFlowTheme.of(context).labelMedium.override(
                          font: GoogleFonts.manrope(
                            fontWeight: FlutterFlowTheme.of(context)
                                .labelMedium
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .labelMedium
                                .fontStyle,
                          ),
                          color: FlutterFlowTheme.of(context).primaryText,
                          letterSpacing: 0.0,
                          fontWeight: FlutterFlowTheme.of(context)
                              .labelMedium
                              .fontWeight,
                          fontStyle: FlutterFlowTheme.of(context)
                              .labelMedium
                              .fontStyle,
                        ),
                  ),
                  duration: Duration(milliseconds: 2000),
                  backgroundColor: FlutterFlowTheme.of(context).warning,
                ),
              );
              await Future.delayed(
                Duration(
                  milliseconds: 2500,
                ),
              );

              context.goNamed(
                ChatWidget.routeName,
                extra: <String, dynamic>{
                  kTransitionInfoKey: TransitionInfo(
                    hasTransition: true,
                    transitionType: PageTransitionType.fade,
                    duration: Duration(milliseconds: 0),
                  ),
                },
              );
            },
            onDone: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Chat disconnected',
                    style: FlutterFlowTheme.of(context).labelMedium.override(
                          font: GoogleFonts.manrope(
                            fontWeight: FlutterFlowTheme.of(context)
                                .labelMedium
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .labelMedium
                                .fontStyle,
                          ),
                          color: FlutterFlowTheme.of(context).primaryText,
                          letterSpacing: 0.0,
                          fontWeight: FlutterFlowTheme.of(context)
                              .labelMedium
                              .fontWeight,
                          fontStyle: FlutterFlowTheme.of(context)
                              .labelMedium
                              .fontStyle,
                        ),
                  ),
                  duration: Duration(milliseconds: 4000),
                  backgroundColor: FlutterFlowTheme.of(context).info,
                ),
              );
            },
          );
          // Add the subscription to the active streaming response subscriptions
          // in API Manager so that it can be cancelled at a later time.
          ApiManager.instance.addActiveStreamingResponseSubscription(
            'chatId_${FFAppState().conversationId}',
            streamSubscription,
          );
        }
      } else {
        // Error handling
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              () {
                if (FFAppState().userKey == '') {
                  return 'Couldn\'t find a User Key';
                } else if (FFAppState().conversationId == '') {
                  return 'Couldn\'t find a Conversation ID';
                } else {
                  return 'Something went wrong';
                }
              }(),
              style: TextStyle(
                color: FlutterFlowTheme.of(context).primaryText,
              ),
            ),
            duration: Duration(milliseconds: 4000),
            backgroundColor: FlutterFlowTheme.of(context).error,
          ),
        );
        return;
      }
    });

    _model.textController ??=
        TextEditingController(text: _model.currentMessage);
    _model.textFieldFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
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
                  future: queryChatbotsRecordOnce(
                    singleRecord: true,
                  ),
                  builder: (context, snapshot) {
                    // Customize what your widget looks like when it's loading.
                    if (!snapshot.hasData) {
                      return LoaderWidget();
                    }
                    List<ChatbotsRecord> columnChatbotsRecordList =
                        snapshot.data!;
                    final columnChatbotsRecord =
                        columnChatbotsRecordList.isNotEmpty
                            ? columnChatbotsRecordList.first
                            : null;

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
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .labelSmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelSmall
                                        .fontStyle,
                                  ),
                        ),
                        Text(
                          valueOrDefault<String>(
                            columnChatbotsRecord?.name,
                            'AI Assistant',
                          ),
                          style:
                              FlutterFlowTheme.of(context).titleMedium.override(
                                    font: GoogleFonts.manrope(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .fontStyle,
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
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Builder(
                  builder: (context) {
                    if (!_model.isLoading) {
                      return Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                10.0, 0.0, 10.0, 10.0),
                            child: Container(
                              width: double.infinity,
                              height: MediaQuery.sizeOf(context).height * 0.715,
                              decoration: BoxDecoration(),
                              child: Builder(
                                builder: (context) {
                                  final messagesList =
                                      FFAppState().chatMessages.toList();

                                  return ListView.builder(
                                    padding: EdgeInsets.zero,
                                    reverse: true,
                                    scrollDirection: Axis.vertical,
                                    itemCount: messagesList.length,
                                    itemBuilder: (context, messagesListIndex) {
                                      final messagesListItem =
                                          messagesList[messagesListIndex];
                                      return Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 10.0, 0.0, 0.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (FFAppConstants.botSender ==
                                                getJsonField(
                                                  messagesListItem,
                                                  r'''$.sender''',
                                                ).toString())
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        0.0, 10.0, 0.0, 10.0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      width: 36.0,
                                                      height: 36.0,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        Icons.smart_toy_rounded,
                                                        color: Colors.white,
                                                        size: 20.0,
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 260.0,
                                                      constraints:
                                                          BoxConstraints(
                                                        minHeight: 43.0,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .secondaryBackground,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16.0),
                                                      ),
                                                      child: Padding(
                                                        padding: EdgeInsets.all(
                                                            12.0),
                                                        child: custom_widgets
                                                            .BotMessage(
                                                          width: 150.0,
                                                          height: 100.0,
                                                          text: getJsonField(
                                                            messagesListItem,
                                                            r'''$.text''',
                                                          ).toString(),
                                                          dotColor:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .primary,
                                                          isComplete: functions
                                                              .shouldCompleteAnimation(
                                                                  messagesListItem,
                                                                  messagesListIndex),
                                                          showTyping: true,
                                                          typingDuration: 2000,
                                                          wordDelay: 100,
                                                          dotSize: 6.0,
                                                          textColor:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .primaryText,
                                                          fontSize: 14.0,
                                                          messageIndex:
                                                              messagesListIndex,
                                                        ),
                                                      ),
                                                    ),
                                                  ].divide(
                                                      SizedBox(width: 12.0)),
                                                ),
                                              ),
                                            if (FFAppConstants.userSender ==
                                                getJsonField(
                                                  messagesListItem,
                                                  r'''$.sender''',
                                                ).toString())
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        0.0, 10.0, 0.0, 10.0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        width: 280.0,
                                                        constraints:
                                                            BoxConstraints(
                                                          minHeight: 43.0,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primary,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      16.0),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  12.0),
                                                          child: Text(
                                                            getJsonField(
                                                              messagesListItem,
                                                              r'''$.text''',
                                                            ).toString(),
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .manrope(
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  color: Colors
                                                                      .white,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 36.0,
                                                      height: 36.0,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .alternate,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                0.0, 0.0),
                                                        child: Icon(
                                                          Icons.face,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .tertiary,
                                                          size: 24.0,
                                                        ),
                                                      ),
                                                    ),
                                                  ].divide(
                                                      SizedBox(width: 12.0)),
                                                ),
                                              ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Container(
                        width: double.infinity,
                        height: MediaQuery.sizeOf(context).height * 0.70,
                        decoration: BoxDecoration(),
                        child: wrapWithModel(
                          model: _model.loaderModel,
                          updateCallback: () => safeSetState(() {}),
                          child: LoaderWidget(),
                        ),
                      );
                    }
                  },
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
                                    Icon(
                                      Icons.add,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      size: 24.0,
                                    ),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _model.textController,
                                        focusNode: _model.textFieldFocusNode,
                                        onChanged: (_) => EasyDebounce.debounce(
                                          '_model.textController',
                                          Duration(milliseconds: 2000),
                                          () async {
                                            _model.currentMessage =
                                                _model.textController.text;
                                            safeSetState(() {});
                                          },
                                        ),
                                        autofocus: true,
                                        textInputAction: TextInputAction.send,
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          hintText: 'Ask anything',
                                          hintStyle: FlutterFlowTheme.of(
                                                  context)
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
                                                letterSpacing: 0.0,
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
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
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                        validator: _model
                                            .textControllerValidator
                                            .asValidator(context),
                                      ),
                                    ),
                                    Icon(
                                      Icons.mic,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      size: 24.0,
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
                                      onPressed: ((_model.textController.text ==
                                                  '') ||
                                              (FFAppState().conversationId ==
                                                  '') ||
                                              _model.isSendingMessage)
                                          ? null
                                          : () async {
                                              FFAppState().isBotTyping = true;
                                              safeSetState(() {});
                                              await actions
                                                  .createTypingMessage();
                                              await Future.delayed(
                                                Duration(
                                                  milliseconds: 50,
                                                ),
                                              );
                                              // Store new msg in page state
                                              _model.currentMessage =
                                                  _model.textController.text;
                                              safeSetState(() {});
                                              // Set loading
                                              _model.isSendingMessage = true;
                                              safeSetState(() {});
                                              // Clear input
                                              safeSetState(() {
                                                _model.textController?.clear();
                                              });
                                              // Send message to Chat API
                                              _model.messageResponse =
                                                  await SendChatMessageCall
                                                      .call(
                                                userKey: FFAppState().userKey,
                                                conversationId:
                                                    FFAppState().conversationId,
                                                text: _model.currentMessage,
                                              );

                                              // Clear loading state
                                              _model.isSendingMessage = false;
                                              safeSetState(() {});
                                              // Update last chat time in Firestore

                                              await currentUserReference!
                                                  .update(createUsersRecordData(
                                                botpressLastChatTime:
                                                    getCurrentTimestamp
                                                        .toString(),
                                              ));

                                              safeSetState(() {});
                                            },
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
}
