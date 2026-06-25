import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'shared/presentation/widgets/global_error_screen.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/networking/hive_service.dart';
import 'firebase_options.dart';
import 'injection/core_providers.dart';
import 'app/app.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
  }
}

Future<void> main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // 1. Handle UI/Framework errors (Red Screen of Death)
      ErrorWidget.builder = (FlutterErrorDetails details) {
        return GlobalErrorScreen(errorDetails: details);
      };

      // 2. Handle framework errors gracefully by logging them
      FlutterError.onError = (FlutterErrorDetails details) {
        if (kDebugMode) {
          FlutterError.dumpErrorToConsole(details);
        }
      };

      // 3. Catch all asynchronous errors that flutter doesn't catch
      PlatformDispatcher.instance.onError = (error, stack) {
        if (kDebugMode) {
          print('Caught by PlatformDispatcher: $error');
          print(stack);
        }
        return true; // Return true to prevent the app from crashing
      };

      // Load environment variables
      await dotenv.load(fileName: ".env");

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // Initialize Local Persistence
      final prefs = await SharedPreferences.getInstance();
      await HiveService.init();

      // Disable debugPrint in release mode
      if (kReleaseMode) {
        debugPrint = (String? message, {int? wrapWidth}) {};
      }

      // Disable runtime font fetching to prevent SocketException crashes
      GoogleFonts.config.allowRuntimeFetching = false;

      runApp(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const GradStrokeApp(),
        ),
      );
    },
    (error, stackTrace) {
      if (kDebugMode) {
        print('Caught globally: $error');
        print(stackTrace);
      }
    },
    zoneSpecification: ZoneSpecification(
      print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
        // Only print if we are in debug mode
        if (kDebugMode) {
          parent.print(zone, line);
        }
      },
    ),
  );
}
