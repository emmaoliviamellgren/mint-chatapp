import 'package:flutter/material.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {}

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  /// Current index for slide in slideshow on landing page
  int _currentSlideIndex = 0;
  int get currentSlideIndex => _currentSlideIndex;
  set currentSlideIndex(int value) {
    _currentSlideIndex = value;
  }

  bool _isProfileDropdownOpen = false;
  bool get isProfileDropdownOpen => _isProfileDropdownOpen;
  set isProfileDropdownOpen(bool value) {
    _isProfileDropdownOpen = value;
  }
}
