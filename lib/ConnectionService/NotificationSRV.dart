import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mhamrah/ConnectionService/UserSRV.dart';
import 'package:mhamrah/Pages/ChatRoom/ChatScreen.dart';
import 'package:mhamrah/Pages/ChatRoom/ConsultantChannel/ChannelChatScreenView.dart';
import 'package:mhamrah/Pages/ChatRoom/ConsultantChannel/ConsChannelChatScreen.dart';
import 'package:mhamrah/Pages/User/FirstPage.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Utils/SnackAnFlushBarUtils.dart';
import 'package:mhamrah/Utils/VibrateUtils.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:notification_permissions/notification_permissions.dart';

class PushNotificationsManager {
  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance =
      PushNotificationsManager._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool initialized = false;

  Future<void> init(String username, String auth) async {
    if (!initialized && !kIsWeb) {
      Future<PermissionStatus> permissionStatus =
          NotificationPermissions.requestNotificationPermissions(
        iosSettings: const NotificationSettingsIos(
            sound: true, badge: true, alert: true),
        openSettings: true,
      );
      _firebaseMessaging.requestNotificationPermissions(
          IosNotificationSettings(sound: true, badge: true, alert: true));
      // For iOS request permission first.
      _firebaseMessaging.configure(
          onBackgroundMessage: onMessage,
          onLaunch: onMessage,
          onMessage: onMessage,
          onResume: onMessage);

      initialized = true;
    }
    sendTokenToServer(username, auth);
  }

  static Future<void> onMessage(Map<String, dynamic> data) {
    String title = data['notification']['title'];
    String body = data['notification']['body'];
    State currentState = FirstPage.currentPageState;
    String data_title = data['data']['data_title'];
    if ((currentState.runtimeType).toString() == "ChatScreenState") {
      ChatScreenState page = (currentState as ChatScreenState);
      if (data_title == "چت" || data_title == "گروه") {
        List<dynamic> usernames = json.decode(data['data']['usernames']) ?? [];
        List<String> chatScreenUsernames = page.usernames;
        if (!stringListEquality(usernames, chatScreenUsernames)) {
          showNotificationFlushBar(title, body);
        }
      } else {
        showNotificationFlushBar(title, data['notification']['body']);
      }
    } else if ((currentState.runtimeType).toString() ==
            "ConsultantChannelChatScreenState" ||
        (currentState.runtimeType).toString() == "ChannelChatScreenViewState") {
      ConsultantChannelChatScreenState page =
          (currentState as ConsultantChannelChatScreenState);
      if (data_title == "کانال") {
        List<dynamic> usernames = json.decode(data['data']['usernames']);
        List<String> chatScreenUsernames = [page.mainConsUsername];
        if (!stringListEquality(usernames, chatScreenUsernames)) {
          showNotificationFlushBar(title, body);
        }
      } else {
        showNotificationFlushBar(title, body);
      }
    } else {
      showNotificationFlushBar(title, body);
    }
  }

  void sendTokenToServer(String username, String auth) {
    UserSRV userSRV = UserSRV();
    _firebaseMessaging.getToken().then((value) {
      FBT.setFirebaseToken(value);
      userSRV.setFirebaseTokenForUser(username, auth, value);
    });
  }
}
