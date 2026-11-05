import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:app_notification_service/notification_service.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class OneSignalService implements NotificationServiceInterface {
  /// This will return us the device specific id that can be used in login and sign up API
  @override
  Future<String> getNotificationSubscriptionId() async {
    final playerID = OneSignal.User.pushSubscription.id;
    return playerID ?? '';
  }

  /// Initialize Onesignal and set the log level for debugging purpose
  @override
  Future<void> init(String appId, {bool shouldLog = true}) async {
    await OneSignal.consentRequired(true);
    await OneSignal.consentGiven(true);
    if (Platform.isIOS) {
      await OneSignal.Location.setShared(false);
    }

    await OneSignal.initialize(appId);
    if (shouldLog) {
      await OneSignal.Debug.setLogLevel(OSLogLevel.fatal);
    }
  }

  @override
  Future<void> setData(NotificationUserModel model) async {
    // Pass in email provided by customer
    await OneSignal.User.addEmail(model.email);
    final externalId = model.userId;
    await OneSignal.login(externalId);
  }

  @override
  Future<bool> requestNotificationPermission() async {
    try {
      if (!OneSignal.Notifications.permission) {
        final isGranted = await OneSignal.Notifications.requestPermission(true);
        log('Permission request: $isGranted');
        listenForNotification();
        return isGranted;
      } else {
        log('Permission request: its already having');
        listenForNotification();
        return true;
      }
    } catch (e) {
      log('Permission request error: $e');
      return false;
    }
  }

  @override
  void listenForNotification() {
    OneSignal.Notifications.addClickListener((event) {
      final data = event.notification.additionalData;
      final notificationEventModel = NotificationObserverEvent(
        title: event.notification.title,
        body: event.notification.body,
        data: data,
      );
      notificationObserverStream.sink.add(notificationEventModel);
    });
  }

  @override
  Stream<NotificationObserverEvent> get listenForNotifications =>
      notificationObserverStream.stream;

  @override
  Future<void> dispose() async {
    await notificationObserverStream.close();
  }

  @override
  Future<void> logout() async {
    await OneSignal.logout();
  }

  /// This stream is used for listening notifications from the app side
  @override
  StreamController<NotificationObserverEvent> notificationObserverStream =
      StreamController();
}
