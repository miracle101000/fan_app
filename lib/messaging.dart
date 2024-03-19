import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
      options: Platform.isAndroid ? DefaultOptions.android : null);
  if (message.notification != null) {
  }
  return;
}


class DefaultOptions {
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyC9V8qOOmaB3ULoXGteZd23ILfr4_IAKxo",
    appId: "1:96286293654:android:e86f776b1b7301e459ccb7",
    messagingSenderId: '96286293654',
    projectId: "fan-app-4cff1",
    // databaseURL:
    //     'https://flutterfire-e2e-tests-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: "fan-app-4cff1.appspot.com",
  );
}