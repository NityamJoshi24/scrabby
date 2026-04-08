import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError('Unsupported platform');
  }

  static const FirebaseOptions web = FirebaseOptions(
      apiKey: "AIzaSyBsRtLDVeIVkuZtIzzNtj5LKCVwGzc7iSM",
      authDomain: "scrabble-online-7a022.firebaseapp.com",
      databaseURL: "https://scrabble-online-7a022-default-rtdb.firebaseio.com",
      projectId: "scrabble-online-7a022",
      storageBucket: "scrabble-online-7a022.firebasestorage.app",
      messagingSenderId: "516233644956",
      appId: "1:516233644956:web:e139dff8c57a428d721659",
      measurementId: "G-04X531BNNH"
  );
}