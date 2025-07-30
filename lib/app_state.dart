import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    _safeInit(() {
      _uploadedProfilePhoto =
          prefs.getString('ff_uploadedProfilePhoto') ?? _uploadedProfilePhoto;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;

  /// Current index for slide in slideshow on landing page
  int _currentSlideIndex = 0;
  int get currentSlideIndex => _currentSlideIndex;
  set currentSlideIndex(int value) {
    _currentSlideIndex = value;
  }

  bool _isAppleButtonDisabled = true;
  bool get isAppleButtonDisabled => _isAppleButtonDisabled;
  set isAppleButtonDisabled(bool value) {
    _isAppleButtonDisabled = value;
  }

  String _uploadedProfilePhoto = '';
  String get uploadedProfilePhoto => _uploadedProfilePhoto;
  set uploadedProfilePhoto(String value) {
    _uploadedProfilePhoto = value;
    prefs.setString('ff_uploadedProfilePhoto', value);
  }

  String _firebaseErrorMessage = '';
  String get firebaseErrorMessage => _firebaseErrorMessage;
  set firebaseErrorMessage(String value) {
    _firebaseErrorMessage = value;
  }

  bool _hasFirebaseError = false;
  bool get hasFirebaseError => _hasFirebaseError;
  set hasFirebaseError(bool value) {
    _hasFirebaseError = value;
  }

  /// Firebase Auth response
  dynamic _authResult;
  dynamic get authResult => _authResult;
  set authResult(dynamic value) {
    _authResult = value;
  }

  bool _isAuthLoading = false;
  bool get isAuthLoading => _isAuthLoading;
  set isAuthLoading(bool value) {
    _isAuthLoading = value;
  }
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}
