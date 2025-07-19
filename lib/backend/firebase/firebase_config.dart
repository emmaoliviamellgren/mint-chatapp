import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyDk8zs3ld6UnM-J59Fpe0bjZd_4tkWl1a4",
            authDomain: "mint---chat-app.firebaseapp.com",
            projectId: "mint---chat-app",
            storageBucket: "mint---chat-app.firebasestorage.app",
            messagingSenderId: "326884314125",
            appId: "1:326884314125:web:9483b39a551fc53c275944",
            measurementId: "G-1VZWLH1WJH"));
  } else {
    await Firebase.initializeApp();
  }
}
