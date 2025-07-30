import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ChatbotsRecord extends FirestoreRecord {
  ChatbotsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "id" field.
  String? _id;
  String get id => _id ?? '';
  bool hasId() => _id != null;

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  // "tags" field.
  List<String>? _tags;
  List<String> get tags => _tags ?? const [];
  bool hasTags() => _tags != null;

  void _initializeFields() {
    _id = snapshotData['id'] as String?;
    _name = snapshotData['name'] as String?;
    _description = snapshotData['description'] as String?;
    _tags = getDataList(snapshotData['tags']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('chatbots');

  static Stream<ChatbotsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ChatbotsRecord.fromSnapshot(s));

  static Future<ChatbotsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ChatbotsRecord.fromSnapshot(s));

  static ChatbotsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ChatbotsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ChatbotsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ChatbotsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ChatbotsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ChatbotsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createChatbotsRecordData({
  String? id,
  String? name,
  String? description,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
    }.withoutNulls,
  );

  return firestoreData;
}

class ChatbotsRecordDocumentEquality implements Equality<ChatbotsRecord> {
  const ChatbotsRecordDocumentEquality();

  @override
  bool equals(ChatbotsRecord? e1, ChatbotsRecord? e2) {
    const listEquality = ListEquality();
    return e1?.id == e2?.id &&
        e1?.name == e2?.name &&
        e1?.description == e2?.description &&
        listEquality.equals(e1?.tags, e2?.tags);
  }

  @override
  int hash(ChatbotsRecord? e) =>
      const ListEquality().hash([e?.id, e?.name, e?.description, e?.tags]);

  @override
  bool isValidKey(Object? o) => o is ChatbotsRecord;
}
