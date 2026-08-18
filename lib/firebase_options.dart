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
    apiKey: 'AIzaSyAt7oZ4B4E7UPdsL3fe41N2sEGfzqIjaNs',
    appId: '1:16257399137:web:1293ea3f02031cce5fad20',
    messagingSenderId: '16257399137',
    projectId: 'disaster-rescue-nhattuan9393',
    authDomain: 'disaster-rescue-nhattuan9393.firebaseapp.com',
    storageBucket: 'disaster-rescue-nhattuan9393.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD-nsfLbsGtym6VGg54MFovGV_OCy0HNHY',
    appId: '1:16257399137:android:37fca9f8172ef99e5fad20',
    messagingSenderId: '16257399137',
    projectId: 'disaster-rescue-nhattuan9393',
    storageBucket: 'disaster-rescue-nhattuan9393.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAsjL7ntxLveo0ymcnVO69Zymoxu5bqJ_Y',
    appId: '1:16257399137:ios:61c2889c18b43bc45fad20',
    messagingSenderId: '16257399137',
    projectId: 'disaster-rescue-nhattuan9393',
    storageBucket: 'disaster-rescue-nhattuan9393.firebasestorage.app',
    iosBundleId: 'com.disasterrescue.disasterRescue',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAsjL7ntxLveo0ymcnVO69Zymoxu5bqJ_Y',
    appId: '1:16257399137:ios:61c2889c18b43bc45fad20',
    messagingSenderId: '16257399137',
    projectId: 'disaster-rescue-nhattuan9393',
    storageBucket: 'disaster-rescue-nhattuan9393.firebasestorage.app',
    iosBundleId: 'com.disasterrescue.disasterRescue',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAt7oZ4B4E7UPdsL3fe41N2sEGfzqIjaNs',
    appId: '1:16257399137:web:f73c1d96cc1bd13d5fad20',
    messagingSenderId: '16257399137',
    projectId: 'disaster-rescue-nhattuan9393',
    authDomain: 'disaster-rescue-nhattuan9393.firebaseapp.com',
    storageBucket: 'disaster-rescue-nhattuan9393.firebasestorage.app',
  );
}
