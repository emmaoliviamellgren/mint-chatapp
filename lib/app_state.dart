import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:csv/csv.dart';
import 'package:synchronized/synchronized.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  String _botpressUserId = '';
  String get botpressUserId => _botpressUserId;
  set botpressUserId(String value) {
    _botpressUserId = value;
  }

  Future initializePersistedState() async {
    secureStorage = FlutterSecureStorage();

    await _safeInitAsync(() async {
      _userKey = await secureStorage.getString('ff_userKey') ?? _userKey;
    });

    await _safeInitAsync(() async {
      _conversationId =
          await secureStorage.getString('ff_conversationId') ?? _conversationId;
    });

    await _safeInitAsync(() async {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        _userDisplayName = currentUser.displayName ?? 'User';
        _userProfilePhoto = currentUser.photoURL ?? '';

        try {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .get();

          if (userDoc.exists) {
            final userData = userDoc.data()!;
            _userDisplayName = userData['display_name'] ?? _userDisplayName;
            _userProfilePhoto = userData['photo_url'] ?? _userProfilePhoto;
          }
        } catch (e) {
          print('Error loading user data from Firestore: $e');
        }
      }
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late FlutterSecureStorage secureStorage;

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

  List<dynamic> _chatMessages = [];
  List<dynamic> get chatMessages => _chatMessages;
  set chatMessages(List<dynamic> value) {
    _chatMessages = value;
  }

  void addToChatMessages(dynamic value) {
    chatMessages.add(value);
  }

  void removeFromChatMessages(dynamic value) {
    chatMessages.remove(value);
  }

  void removeAtIndexFromChatMessages(int index) {
    chatMessages.removeAt(index);
  }

  void updateChatMessagesAtIndex(
    int index,
    dynamic Function(dynamic) updateFn,
  ) {
    chatMessages[index] = updateFn(_chatMessages[index]);
  }

  void insertAtIndexInChatMessages(int index, dynamic value) {
    chatMessages.insert(index, value);
  }

  String _userKey = '';
  String get userKey => _userKey;
  set userKey(String value) {
    _userKey = value;
    secureStorage.setString('ff_userKey', value);
  }

  void deleteUserKey() {
    secureStorage.delete(key: 'ff_userKey');
  }

  String _conversationId = '';
  String get conversationId => _conversationId;
  set conversationId(String value) {
    _conversationId = value;
    secureStorage.setString('ff_conversationId', value);
  }

  void deleteConversationId() {
    secureStorage.delete(key: 'ff_conversationId');
  }

  bool _isBotTyping = false;
  bool get isBotTyping => _isBotTyping;
  set isBotTyping(bool value) {
    _isBotTyping = value;
  }

  String _userDisplayName = 'User';
  String get userDisplayName => _userDisplayName;
  set userDisplayName(String value) {
    _userDisplayName = value;
  }

  String _userProfilePhoto = '';
  String get userProfilePhoto => _userProfilePhoto;
  set userProfilePhoto(String value) {
    _userProfilePhoto = value;
  }

  bool _shouldAutoScroll = false;
  bool get shouldAutoScroll => _shouldAutoScroll;
  set shouldAutoScroll(bool value) {
    _shouldAutoScroll = value;
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

extension FlutterSecureStorageExtensions on FlutterSecureStorage {
  static final _lock = Lock();

  Future<void> writeSync({required String key, String? value}) async =>
      await _lock.synchronized(() async {
        await write(key: key, value: value);
      });

  void remove(String key) => delete(key: key);

  Future<String?> getString(String key) async => await read(key: key);
  Future<void> setString(String key, String value) async =>
      await writeSync(key: key, value: value);

  Future<bool?> getBool(String key) async => (await read(key: key)) == 'true';
  Future<void> setBool(String key, bool value) async =>
      await writeSync(key: key, value: value.toString());

  Future<int?> getInt(String key) async =>
      int.tryParse(await read(key: key) ?? '');
  Future<void> setInt(String key, int value) async =>
      await writeSync(key: key, value: value.toString());

  Future<double?> getDouble(String key) async =>
      double.tryParse(await read(key: key) ?? '');
  Future<void> setDouble(String key, double value) async =>
      await writeSync(key: key, value: value.toString());

  Future<List<String>?> getStringList(String key) async =>
      await read(key: key).then((result) {
        if (result == null || result.isEmpty) {
          return null;
        }
        return CsvToListConverter()
            .convert(result)
            .first
            .map((e) => e.toString())
            .toList();
      });
  Future<void> setStringList(String key, List<String> value) async =>
      await writeSync(key: key, value: ListToCsvConverter().convert([value]));
}
