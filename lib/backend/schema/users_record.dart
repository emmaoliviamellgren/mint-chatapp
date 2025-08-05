import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UsersRecord extends FirestoreRecord {
  UsersRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "display_name" field.
  String? _displayName;
  String get displayName => _displayName ?? '';
  bool hasDisplayName() => _displayName != null;

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "photo_url" field.
  String? _photoUrl;
  String get photoUrl => _photoUrl ?? '';
  bool hasPhotoUrl() => _photoUrl != null;

  // "phone_number" field.
  String? _phoneNumber;
  String get phoneNumber => _phoneNumber ?? '';
  bool hasPhoneNumber() => _phoneNumber != null;

  // "profile_complete" field.
  bool? _profileComplete;
  bool get profileComplete => _profileComplete ?? false;
  bool hasProfileComplete() => _profileComplete != null;

  // "botpress_user_key" field.
  String? _botpressUserKey;
  String get botpressUserKey => _botpressUserKey ?? '';
  bool hasBotpressUserKey() => _botpressUserKey != null;

  // "botpress_last_chat_time" field.
  String? _botpressLastChatTime;
  String get botpressLastChatTime => _botpressLastChatTime ?? '';
  bool hasBotpressLastChatTime() => _botpressLastChatTime != null;

  // "botpress_conversation_id" field.
  String? _botpressConversationId;
  String get botpressConversationId => _botpressConversationId ?? '';
  bool hasBotpressConversationId() => _botpressConversationId != null;

  void _initializeFields() {
    _email = snapshotData['email'] as String?;
    _displayName = snapshotData['display_name'] as String?;
    _uid = snapshotData['uid'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _photoUrl = snapshotData['photo_url'] as String?;
    _phoneNumber = snapshotData['phone_number'] as String?;
    _profileComplete = snapshotData['profile_complete'] as bool?;
    _botpressUserKey = snapshotData['botpress_user_key'] as String?;
    _botpressLastChatTime = snapshotData['botpress_last_chat_time'] as String?;
    _botpressConversationId =
        snapshotData['botpress_conversation_id'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('users');

  static Stream<UsersRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => UsersRecord.fromSnapshot(s));

  static Future<UsersRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => UsersRecord.fromSnapshot(s));

  static UsersRecord fromSnapshot(DocumentSnapshot snapshot) => UsersRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static UsersRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      UsersRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'UsersRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is UsersRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createUsersRecordData({
  String? email,
  String? displayName,
  String? uid,
  DateTime? createdTime,
  String? photoUrl,
  String? phoneNumber,
  bool? profileComplete,
  String? botpressUserKey,
  String? botpressLastChatTime,
  String? botpressConversationId,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'email': email,
      'display_name': displayName,
      'uid': uid,
      'created_time': createdTime,
      'photo_url': photoUrl,
      'phone_number': phoneNumber,
      'profile_complete': profileComplete,
      'botpress_user_key': botpressUserKey,
      'botpress_last_chat_time': botpressLastChatTime,
      'botpress_conversation_id': botpressConversationId,
    }.withoutNulls,
  );

  return firestoreData;
}

class UsersRecordDocumentEquality implements Equality<UsersRecord> {
  const UsersRecordDocumentEquality();

  @override
  bool equals(UsersRecord? e1, UsersRecord? e2) {
    return e1?.email == e2?.email &&
        e1?.displayName == e2?.displayName &&
        e1?.uid == e2?.uid &&
        e1?.createdTime == e2?.createdTime &&
        e1?.photoUrl == e2?.photoUrl &&
        e1?.phoneNumber == e2?.phoneNumber &&
        e1?.profileComplete == e2?.profileComplete &&
        e1?.botpressUserKey == e2?.botpressUserKey &&
        e1?.botpressLastChatTime == e2?.botpressLastChatTime &&
        e1?.botpressConversationId == e2?.botpressConversationId;
  }

  @override
  int hash(UsersRecord? e) => const ListEquality().hash([
        e?.email,
        e?.displayName,
        e?.uid,
        e?.createdTime,
        e?.photoUrl,
        e?.phoneNumber,
        e?.profileComplete,
        e?.botpressUserKey,
        e?.botpressLastChatTime,
        e?.botpressConversationId
      ]);

  @override
  bool isValidKey(Object? o) => o is UsersRecord;
}
