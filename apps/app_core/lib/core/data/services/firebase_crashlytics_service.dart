import 'dart:async';

import 'package:app_core/app/config/app_config.dart';
import 'package:app_core/app/enum.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Toggle this for testing Crashlytics in your app locally.
const _kTestingCrashlytics = true;

class FirebaseCrashlyticsService {
  /// Initialize firebase crashlytics if env is production
  /// To check for Dummy crash use following line
  /// FirebaseCrashlytics.instance.log('Dummy Crash');
  static void init() {
    if (Env.production == AppConfig.environment) {
      FlutterError.onError = (errorDetails) {
        /// If you wish to record a "non-fatal" exception, please use `FirebaseCrashlytics.instance.recordFlutterError` instead
        unawaited(FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails));
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        /// If you wish to record a "non-fatal" exception, please remove the "fatal" parameter
        unawaited(FirebaseCrashlytics.instance.recordError(error, stack, fatal: true));
        return true;
      };
      unawaited(method());
    }
  }

  static Future<void> method() async {
    if (_kTestingCrashlytics) {
      /// Force enable crashlytics collection enabled if we're testing it.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    } else {
      /// Else only enable it in non-debug builds.
      /// You could additionally extend this to allow users to opt-in.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
        !kDebugMode,
      );
    }
  }
}
