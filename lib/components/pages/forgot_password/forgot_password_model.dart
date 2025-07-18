import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'forgot_password_widget.dart' show ForgotPasswordWidget;
import 'package:flutter/material.dart';

class ForgotPasswordModel extends FlutterFlowModel<ForgotPasswordWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for E-mailInputReset widget.
  FocusNode? eMailInputResetFocusNode;
  TextEditingController? eMailInputResetTextController;
  String? Function(BuildContext, String?)?
      eMailInputResetTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    eMailInputResetFocusNode?.dispose();
    eMailInputResetTextController?.dispose();
  }
}
