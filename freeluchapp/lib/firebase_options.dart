// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDCzQvuEXwASWwIvhxJAtHN3saW2mULpVM',
    appId: '1:760784195314:web:74f25f706a2080ce314a6b',
    messagingSenderId: '760784195314',
    projectId: 'freeluchapp-d2751',
    authDomain: 'freeluchapp-d2751.firebaseapp.com',
    storageBucket: 'freeluchapp-d2751.firebasestorage.app',
    measurementId: 'G-2ZNYY460NH',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyANFjp2ypvKyw3t3M6t1tIswhVpe3vVkbs',
    appId: '1:760784195314:android:68399fba07faea5c314a6b',
    messagingSenderId: '760784195314',
    projectId: 'freeluchapp-d2751',
    storageBucket: 'freeluchapp-d2751.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBAU08w7vhLUsiQlMVhs4mKv-r1MVzHtUE',
    appId: '1:760784195314:ios:a6815a57c89a6179314a6b',
    messagingSenderId: '760784195314',
    projectId: 'freeluchapp-d2751',
    storageBucket: 'freeluchapp-d2751.firebasestorage.app',
    iosBundleId: 'com.example.freeluchapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBhGctg3EVDDbPH_AiKXQUTZmoHsfTT-a4',
    appId: '1:336916779483:ios:c68d653bad58a2913917fe',
    messagingSenderId: '336916779483',
    projectId: 'freeluchapp',
    storageBucket: 'freeluchapp.firebasestorage.app',
    iosBundleId: 'com.example.freeluchapp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBdM8cmY7v9wP6La8MfXlnVIoQGsNx31JM',
    appId: '1:336916779483:web:6618c07837b70f243917fe',
    messagingSenderId: '336916779483',
    projectId: 'freeluchapp',
    authDomain: 'freeluchapp.firebaseapp.com',
    storageBucket: 'freeluchapp.firebasestorage.app',
    measurementId: 'G-CE1X8L5PWZ',
  );
}