// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAhQ3U8b44FaNfXxVhzMPFoRJj30Ee_MGw',
    appId: '1:587032975119:web:f946848a3ddda54967507a',
    messagingSenderId: '587032975119',
    projectId: 'mobil-proje-1',
    authDomain: 'mobil-proje-1.firebaseapp.com',
    storageBucket: 'mobil-proje-1.appspot.com',
    measurementId: 'G-KPCR6JNB6X',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDxV4n_T6oqb1xe3D-A9qtSCw6Vx-7bLHM',
    appId: '1:587032975119:android:7d6fa06ab843026967507a',
    messagingSenderId: '587032975119',
    projectId: 'mobil-proje-1',
    storageBucket: 'mobil-proje-1.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDBUONYx4U-gVKPcoqk5ahlDJ69gvRKGws',
    appId: '1:587032975119:ios:f1c9eedce426a0e067507a',
    messagingSenderId: '587032975119',
    projectId: 'mobil-proje-1',
    storageBucket: 'mobil-proje-1.appspot.com',
    iosClientId: '587032975119-psb7ho3mu60qgosh2i8esi6hpdgmhkka.apps.googleusercontent.com',
    iosBundleId: 'com.example.mobilProjesi',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDBUONYx4U-gVKPcoqk5ahlDJ69gvRKGws',
    appId: '1:587032975119:ios:f1c9eedce426a0e067507a',
    messagingSenderId: '587032975119',
    projectId: 'mobil-proje-1',
    storageBucket: 'mobil-proje-1.appspot.com',
    iosClientId: '587032975119-psb7ho3mu60qgosh2i8esi6hpdgmhkka.apps.googleusercontent.com',
    iosBundleId: 'com.example.mobilProjesi',
  );
}
