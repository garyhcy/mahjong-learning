// ignore_for_file: lines_longer_than_80_chars
// ignore: depend_on_referenced_packages
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyDB-Q9V3Xr52w7S3vlbR3zHvv5MHCaQwmw',
    appId: '1:154204299071:web:264fda333bdf76fdcefd8a',
    messagingSenderId: '154204299071',
    projectId: 'ludi-mahjong-46d78',
    authDomain: 'ludi-mahjong-46d78.firebaseapp.com',
    storageBucket: 'ludi-mahjong-46d78.firebasestorage.app',
    measurementId: 'G-CR8BKBHTSD',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDB-Q9V3Xr52w7S3vlbR3zHvv5MHCaQwmw',
    appId: '1:154204299071:web:264fda333bdf76fdcefd8a',
    messagingSenderId: '154204299071',
    projectId: 'ludi-mahjong-46d78',
    authDomain: 'ludi-mahjong-46d78.firebaseapp.com',
    storageBucket: 'ludi-mahjong-46d78.firebasestorage.app',
    measurementId: 'G-CR8BKBHTSD',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDB-Q9V3Xr52w7S3vlbR3zHvv5MHCaQwmw',
    appId: '1:154204299071:web:264fda333bdf76fdcefd8a',
    messagingSenderId: '154204299071',
    projectId: 'ludi-mahjong-46d78',
    authDomain: 'ludi-mahjong-46d78.firebaseapp.com',
    storageBucket: 'ludi-mahjong-46d78.firebasestorage.app',
    measurementId: 'G-CR8BKBHTSD',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDB-Q9V3Xr52w7S3vlbR3zHvv5MHCaQwmw',
    appId: '1:154204299071:web:264fda333bdf76fdcefd8a',
    messagingSenderId: '154204299071',
    projectId: 'ludi-mahjong-46d78',
    authDomain: 'ludi-mahjong-46d78.firebaseapp.com',
    storageBucket: 'ludi-mahjong-46d78.firebasestorage.app',
    measurementId: 'G-CR8BKBHTSD',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDB-Q9V3Xr52w7S3vlbR3zHvv5MHCaQwmw',
    appId: '1:154204299071:web:264fda333bdf76fdcefd8a',
    messagingSenderId: '154204299071',
    projectId: 'ludi-mahjong-46d78',
    authDomain: 'ludi-mahjong-46d78.firebaseapp.com',
    storageBucket: 'ludi-mahjong-46d78.firebasestorage.app',
    measurementId: 'G-CR8BKBHTSD',
  );
}
