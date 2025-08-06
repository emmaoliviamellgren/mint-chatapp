import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/firebase_storage/storage.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'edit_profile_model.dart';
export 'edit_profile_model.dart';

class EditProfileWidget extends StatefulWidget {
  const EditProfileWidget({super.key});

  static String routeName = 'EditProfile';
  static String routePath = '/editProfile';

  @override
  State<EditProfileWidget> createState() => _EditProfileWidgetState();
}

class _EditProfileWidgetState extends State<EditProfileWidget> {
  late EditProfileModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  void safeSetStateIfMounted(VoidCallback fn) {
    if (mounted) {
      safeSetState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EditProfileModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      // Run name split function
      _model.namePartsResult = await actions.splitFullName(
        FFAppState().userDisplayName,
      );
      await Future.wait([
        Future(() async {
          // Update page with first name
          _model.firstNameValue = getJsonField(
            _model.namePartsResult,
            r'''$.firstName''',
          ).toString();
          safeSetStateIfMounted(() {});
        }),
        Future(() async {
          // Update page with last name
          _model.lastNameValue = getJsonField(
            _model.namePartsResult,
            r'''$.lastName''',
          ).toString();
          safeSetStateIfMounted(() {});
        }),
      ]);
      // Store original first name
      _model.originalFirstName = getJsonField(
        _model.namePartsResult,
        r'''$.firstName''',
      ).toString();
      safeSetStateIfMounted(() {});
      // Store original last name
      _model.originalLastName = getJsonField(
        _model.namePartsResult,
        r'''$.lastName''',
      ).toString();
      safeSetStateIfMounted(() {});
    });

    _model.emailTextController ??=
        TextEditingController(text: currentUserEmail);
    _model.emailFocusNode ??= FocusNode();

    _model.firstNameTextController ??= TextEditingController(
        text: _model.firstNameValue != null && _model.firstNameValue != ''
            ? _model.firstNameValue
            : '');
    _model.firstNameFocusNode ??= FocusNode();
    _model.firstNameFocusNode!.addListener(
      () async {
        _model.firstNameInputTouched = true;
        safeSetStateIfMounted(() {});
      },
    );
    _model.lastNameTextController ??= TextEditingController(
        text: _model.lastNameValue != null && _model.lastNameValue != ''
            ? _model.lastNameValue
            : '');
    _model.lastNameFocusNode ??= FocusNode();
    _model.lastNameFocusNode!.addListener(
      () async {
        _model.lastNameInputTouched = true;
        safeSetStateIfMounted(() {});
      },
    );
  }

  @override
  void dispose() {
    // On page dispose action.
    () async {
      if (mounted) {
        _model.hasSelectedPhoto = false;
        safeSetState(() {});
      }
    }();

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
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(56.0),
          child: AppBar(
            backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
            automaticallyImplyLeading: false,
            leading: FlutterFlowIconButton(
              borderColor: Colors.transparent,
              borderRadius: 30.0,
              borderWidth: 1.0,
              buttonSize: 60.0,
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                color: FlutterFlowTheme.of(context).primary,
                size: 20.0,
              ),
              onPressed: () async {
                context.safePop();
              },
            ),
            title: Text(
              'Edit information',
              style: FlutterFlowTheme.of(context).bodyLarge.override(
                    font: GoogleFonts.manrope(
                      fontWeight:
                          FlutterFlowTheme.of(context).bodyLarge.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                    ),
                    letterSpacing: 0.0,
                    fontWeight:
                        FlutterFlowTheme.of(context).bodyLarge.fontWeight,
                    fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                  ),
            ),
            actions: [],
            centerTitle: true,
            toolbarHeight: 56.0,
            elevation: 1.0,
          ),
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 0.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Stack(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          children: [
                            Container(
                              width: 70.0,
                              height: 70.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).secondary,
                                  width: 3.0,
                                ),
                              ),
                              child: Builder(
                                builder: (context) {
                                  if (_model.hasSelectedPhoto == true) {
                                    return Container(
                                      width: 100.0,
                                      height: 100.0,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                      ),
                                      child: Image.memory(
                                        _model.uploadedLocalFile_selectedMediaResult
                                                .bytes ??
                                            Uint8List.fromList([]),
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  } else if ((_model.hasSelectedPhoto ==
                                          false) &&
                                      (FFAppState().userProfilePhoto != '')) {
                                    return Container(
                                      width: 100.0,
                                      height: 100.0,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                      ),
                                      child: Image.network(
                                        FFAppState().userProfilePhoto,
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  } else {
                                    return Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Icon(
                                        Icons.face,
                                        color: FlutterFlowTheme.of(context)
                                            .secondary,
                                        size: 32.0,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FFButtonWidget(
                              onPressed: () async {
                                final selectedMedia =
                                    await selectMediaWithSourceBottomSheet(
                                  context: context,
                                  maxHeight: 400.00,
                                  allowPhoto: true,
                                  backgroundColor:
                                      FlutterFlowTheme.of(context).info,
                                  textColor:
                                      FlutterFlowTheme.of(context).primary,
                                  pickerFontFamily: 'Manrope',
                                );
                                if (selectedMedia != null &&
                                    selectedMedia.every((m) =>
                                        validateFileFormat(
                                            m.storagePath, context))) {
                                  safeSetStateIfMounted(() => _model
                                          .isDataUploading_selectedMediaResult =
                                      true);
                                  var selectedUploadedFiles =
                                      <FFUploadedFile>[];

                                  try {
                                    selectedUploadedFiles = selectedMedia
                                        .map((m) => FFUploadedFile(
                                              name:
                                                  m.storagePath.split('/').last,
                                              bytes: m.bytes,
                                              height: m.dimensions?.height,
                                              width: m.dimensions?.width,
                                              blurHash: m.blurHash,
                                            ))
                                        .toList();
                                  } finally {
                                    if (mounted) {
                                      _model.isDataUploading_selectedMediaResult =
                                          false;
                                    }
                                  }
                                  if (selectedUploadedFiles.length ==
                                      selectedMedia.length) {
                                    safeSetStateIfMounted(() {
                                      _model.uploadedLocalFile_selectedMediaResult =
                                          selectedUploadedFiles.first;
                                    });
                                  } else {
                                    safeSetStateIfMounted(() {});
                                    return;
                                  }
                                }

                                _model.hasSelectedPhoto = true;
                                safeSetStateIfMounted(() {});
                              },
                              text: 'Choose a photo',
                              options: FFButtonOptions(
                                width: MediaQuery.sizeOf(context).width * 0.5,
                                height: 44.0,
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16.0, 0.0, 16.0, 0.0),
                                iconPadding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                color: FlutterFlowTheme.of(context)
                                    .primaryBackground,
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      font: GoogleFonts.manrope(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontStyle,
                                      ),
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                elevation: 0.0,
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).primary,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ].divide(SizedBox(height: 8.0)),
                        ),
                      ].divide(SizedBox(width: 20.0)),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email',
                          style:
                              FlutterFlowTheme.of(context).labelLarge.override(
                                    font: GoogleFonts.manrope(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .labelLarge
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .labelLarge
                                          .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .labelLarge
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelLarge
                                        .fontStyle,
                                  ),
                        ),
                        Container(
                          width: double.infinity,
                          child: TextFormField(
                            controller: _model.emailTextController,
                            focusNode: _model.emailFocusNode,
                            autofocus: false,
                            textCapitalization: TextCapitalization.words,
                            readOnly: true,
                            obscureText: false,
                            decoration: InputDecoration(
                              hintText: 'First Name',
                              hintStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.manrope(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color:
                                        FlutterFlowTheme.of(context).alternate,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).alternate,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).alternate,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).alternate,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).alternate,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              filled: true,
                              fillColor: FlutterFlowTheme.of(context).accent4,
                              contentPadding: EdgeInsetsDirectional.fromSTEB(
                                  16.0, 16.0, 16.0, 16.0),
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.manrope(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color: Color(0x7D57636C),
                                  fontSize: 14.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                            keyboardType: TextInputType.emailAddress,
                            validator: _model.emailTextControllerValidator
                                .asValidator(context),
                            inputFormatters: [
                              if (!isAndroid && !isiOS)
                                TextInputFormatter.withFunction(
                                    (oldValue, newValue) {
                                  return TextEditingValue(
                                    selection: newValue.selection,
                                    text: newValue.text.toCapitalization(
                                        TextCapitalization.words),
                                  );
                                }),
                            ],
                          ),
                        ),
                      ].divide(SizedBox(height: 16.0)),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Name',
                          style:
                              FlutterFlowTheme.of(context).labelLarge.override(
                                    font: GoogleFonts.manrope(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .labelLarge
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .labelLarge
                                          .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .labelLarge
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelLarge
                                        .fontStyle,
                                  ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              width: double.infinity,
                              child: TextFormField(
                                controller: _model.firstNameTextController,
                                focusNode: _model.firstNameFocusNode,
                                onChanged: (_) => EasyDebounce.debounce(
                                  '_model.firstNameTextController',
                                  Duration(milliseconds: 0),
                                  () async {
                                    _model.firstNameValue =
                                        _model.firstNameTextController.text;
                                    safeSetStateIfMounted(() {});
                                  },
                                ),
                                autofocus: false,
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                obscureText: false,
                                decoration: InputDecoration(
                                  hintText: _model.firstNameValue != null &&
                                          _model.firstNameValue != ''
                                      ? _model.firstNameValue
                                      : 'First Name',
                                  hintStyle: FlutterFlowTheme.of(context)
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
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context)
                                          .alternate,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  filled: true,
                                  fillColor: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  contentPadding:
                                      EdgeInsetsDirectional.fromSTEB(
                                          16.0, 16.0, 16.0, 16.0),
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.manrope(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      fontSize: 14.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                keyboardType: TextInputType.name,
                                cursorColor:
                                    FlutterFlowTheme.of(context).primary,
                                validator: _model
                                    .firstNameTextControllerValidator
                                    .asValidator(context),
                                inputFormatters: [
                                  if (!isAndroid && !isiOS)
                                    TextInputFormatter.withFunction(
                                        (oldValue, newValue) {
                                      return TextEditingValue(
                                        selection: newValue.selection,
                                        text: newValue.text.toCapitalization(
                                            TextCapitalization.words),
                                      );
                                    }),
                                ],
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              child: TextFormField(
                                controller: _model.lastNameTextController,
                                focusNode: _model.lastNameFocusNode,
                                onChanged: (_) => EasyDebounce.debounce(
                                  '_model.lastNameTextController',
                                  Duration(milliseconds: 0),
                                  () async {
                                    _model.lastNameValue =
                                        _model.lastNameTextController.text;
                                    safeSetStateIfMounted(() {});
                                  },
                                ),
                                autofocus: false,
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                obscureText: false,
                                decoration: InputDecoration(
                                  hintText: _model.lastNameValue != null &&
                                          _model.lastNameValue != ''
                                      ? _model.lastNameValue
                                      : 'Last Name',
                                  hintStyle: FlutterFlowTheme.of(context)
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
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context)
                                          .alternate,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  filled: true,
                                  fillColor: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  contentPadding:
                                      EdgeInsetsDirectional.fromSTEB(
                                          16.0, 16.0, 16.0, 16.0),
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.manrope(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      fontSize: 14.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                keyboardType: TextInputType.name,
                                cursorColor:
                                    FlutterFlowTheme.of(context).primary,
                                validator: _model
                                    .lastNameTextControllerValidator
                                    .asValidator(context),
                                inputFormatters: [
                                  if (!isAndroid && !isiOS)
                                    TextInputFormatter.withFunction(
                                        (oldValue, newValue) {
                                      return TextEditingValue(
                                        selection: newValue.selection,
                                        text: newValue.text.toCapitalization(
                                            TextCapitalization.words),
                                      );
                                    }),
                                ],
                              ),
                            ),
                          ].divide(SizedBox(height: 12.0)),
                        ),
                      ].divide(SizedBox(height: 16.0)),
                    ),
                  ].divide(SizedBox(height: 24.0)),
                ),
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional(0.0, 1.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        FFButtonWidget(
                          onPressed: functions.shouldDisableUpdateProfileButton(
                                  _model.firstNameValue,
                                  _model.lastNameValue,
                                  _model.originalFirstName,
                                  _model.originalLastName,
                                  _model.hasSelectedPhoto)
                              ? null
                              : () async {
                                  final firestoreBatch =
                                      FirebaseFirestore.instance.batch();
                                  try {
                                    // Combine first + last name for FB
                                    _model.combinedFullName =
                                        await actions.combineNames(
                                      _model.firstNameValue,
                                      _model.lastNameValue,
                                    );
                                    if (_model.hasSelectedPhoto == true) {
                                      // Upload the photo to FB
                                      {
                                        safeSetStateIfMounted(() => _model
                                                .isDataUploading_photoUploadResult =
                                            true);

                                        var selectedUploadedFiles =
                                            <FFUploadedFile>[];
                                        var selectedMedia = <SelectedFile>[];
                                        var downloadUrls = <String>[];

                                        try {
                                          selectedUploadedFiles = _model
                                                  .uploadedLocalFile_selectedMediaResult
                                                  .bytes!
                                                  .isNotEmpty
                                              ? [
                                                  _model
                                                      .uploadedLocalFile_selectedMediaResult
                                                ]
                                              : <FFUploadedFile>[];
                                          selectedMedia =
                                              selectedFilesFromUploadedFiles(
                                                  selectedUploadedFiles);
                                          downloadUrls = (await Future.wait(
                                            selectedMedia.map(
                                              (m) async => await uploadData(
                                                  m.storagePath, m.bytes),
                                            ),
                                          ))
                                              .where((u) => u != null)
                                              .map((u) => u!)
                                              .toList();
                                        } finally {
                                          if (mounted) {
                                            _model.isDataUploading_photoUploadResult =
                                                false;
                                          }
                                        }

                                        if (selectedUploadedFiles.length ==
                                                selectedMedia.length &&
                                            downloadUrls.length ==
                                                selectedMedia.length) {
                                          safeSetStateIfMounted(() {
                                            _model.uploadedLocalFile_photoUploadResult =
                                                selectedUploadedFiles.first;
                                            _model.uploadedFileUrl_photoUploadResult =
                                                downloadUrls.first;
                                          });
                                        } else {
                                          safeSetStateIfMounted(() {});
                                          return;
                                        }
                                      }

                                      // Add photo to user doc
                                      firestoreBatch.update(
                                          currentUserReference!,
                                          createUsersRecordData(
                                            photoUrl: _model
                                                .uploadedFileUrl_photoUploadResult,
                                          ));
                                      // Set profile photo in app
                                      FFAppState().userProfilePhoto = _model
                                          .uploadedFileUrl_photoUploadResult;
                                      safeSetStateIfMounted(() {});
                                      // Set hasSelectedPhoto to false
                                      _model.hasSelectedPhoto = false;
                                      safeSetStateIfMounted(() {});
                                    }
                                    // Update Firestore
                                    firestoreBatch.update(
                                        currentUserReference!,
                                        createUsersRecordData(
                                          displayName: _model.combinedFullName,
                                        ));

                                    if ((_model.firstNameValue !=
                                            _model.originalFirstName) ||
                                        (_model.lastNameValue !=
                                            _model.originalLastName)) {
                                      // Update Firebase Auth
                                      await actions.updateFirebaseDisplayName(
                                          _model.combinedFullName!);

                                      // Update O.G. first name value
                                      _model.originalFirstName =
                                          _model.firstNameValue;
                                      safeSetStateIfMounted(() {});

                                      // Update O.G last name value
                                      _model.originalLastName =
                                          _model.lastNameValue;
                                      safeSetStateIfMounted(() {});
                                    }
                                    // Refresh widgets
                                    await actions.refreshFirebaseUser();

                                    // Navigera endast om widgeten fortfarande är mounted
                                    if (mounted) {
                                      context.goNamed(
                                          ProfileSettingsWidget.routeName);
                                    }
                                  } finally {
                                    await firestoreBatch.commit();
                                  }

                                  safeSetStateIfMounted(() {});
                                },
                          text: 'Save Changes',
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: 48.0,
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            iconPadding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: FlutterFlowTheme.of(context).primary,
                            textStyle: FlutterFlowTheme.of(context)
                                .titleMedium
                                .override(
                                  font: GoogleFonts.manrope(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context).info,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .fontStyle,
                                ),
                            elevation: 2.0,
                            borderRadius: BorderRadius.circular(8.0),
                            disabledColor:
                                FlutterFlowTheme.of(context).primaryMuted,
                          ),
                        ),
                        FFButtonWidget(
                          onPressed: () async {
                            context.safePop();
                          },
                          text: 'Cancel',
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: 40.0,
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            iconPadding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color:
                                FlutterFlowTheme.of(context).primaryBackground,
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  font: GoogleFonts.manrope(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context).secondary,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .fontStyle,
                                ),
                            elevation: 0.0,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ].divide(SizedBox(
                          height: FFAppConstants.horizontalButtonsSpacing
                              .toDouble())),
                    ),
                  ),
                ),
              ].divide(SizedBox(height: 32.0)),
            ),
          ),
        ),
      ),
    );
  }
}
