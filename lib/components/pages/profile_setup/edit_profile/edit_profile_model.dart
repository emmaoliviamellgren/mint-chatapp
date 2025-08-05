import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'edit_profile_widget.dart' show EditProfileWidget;
import 'package:flutter/material.dart';

class EditProfileModel extends FlutterFlowModel<EditProfileWidget> {
  ///  Local state fields for this page.

  bool firstNameInputTouched = true;

  bool lastNameInputTouched = true;

  String? firstNameValue;

  String? lastNameValue;

  String? originalFirstName;

  String? originalLastName;

  bool hasSelectedPhoto = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - splitFullName] action in EditProfile widget.
  dynamic namePartsResult;
  bool isDataUploading_selectedMediaResult = false;
  FFUploadedFile uploadedLocalFile_selectedMediaResult =
      FFUploadedFile(bytes: Uint8List.fromList([]));

  // State field(s) for Email widget.
  FocusNode? emailFocusNode;
  TextEditingController? emailTextController;
  String? Function(BuildContext, String?)? emailTextControllerValidator;
  // State field(s) for FirstName widget.
  FocusNode? firstNameFocusNode;
  TextEditingController? firstNameTextController;
  String? Function(BuildContext, String?)? firstNameTextControllerValidator;
  // State field(s) for LastName widget.
  FocusNode? lastNameFocusNode;
  TextEditingController? lastNameTextController;
  String? Function(BuildContext, String?)? lastNameTextControllerValidator;
  // Stores action output result for [Custom Action - combineNames] action in Button widget.
  String? combinedFullName;
  bool isDataUploading_photoUploadResult = false;
  FFUploadedFile uploadedLocalFile_photoUploadResult =
      FFUploadedFile(bytes: Uint8List.fromList([]));
  String uploadedFileUrl_photoUploadResult = '';

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    emailFocusNode?.dispose();
    emailTextController?.dispose();

    firstNameFocusNode?.dispose();
    firstNameTextController?.dispose();

    lastNameFocusNode?.dispose();
    lastNameTextController?.dispose();
  }
}
