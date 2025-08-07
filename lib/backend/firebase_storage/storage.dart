import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

Future<String?> uploadData(String path, Uint8List data) async {
  try {
    final result = await FirebaseStorage.instance
        .ref()
        .child(path)
        .putData(data)
        .timeout(Duration(seconds: 30));

    if (result.state == TaskState.success) {
      return await result.ref.getDownloadURL();
    }
    return null;
  } catch (e) {
    print('Upload error: $e');
    return null;
  }
}
