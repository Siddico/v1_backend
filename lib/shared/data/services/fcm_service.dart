import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:convert';

// Removed firebase_auth import
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router.dart';
import '../../../core/constants/app_constants.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../features/patient/presentation/pages/patient_messages_page.dart';
import '../../domain/entities/call_session_entity.dart';
import '../../domain/entities/notification_entity.dart';
import '../../presentation/widgets/notifications/notification_popup.dart';

class FcmService {
  FcmService._privateConstructor();

  static final FcmService instance = FcmService._privateConstructor();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  // Local Notifications Plugin for foreground notifications
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<String>? _tokenRefreshSubscription;
  String? _currentUserId;

  // Android Notification Channel
  final AndroidNotificationChannel _channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.max,
  );

  /// Request permissions and initialize FCM services
  Future<void> initialize(String userId) async {
    if (userId.isEmpty) return;
    _currentUserId = userId;

    try {
      // 1. Request notification permissions (iOS/Android)
      final settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      // Request Android 13+ POST_NOTIFICATIONS permission if needed
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }

      // Initialize local notifications
      await _initLocalNotifications();

      // 2. Fetch and register token if authorized
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        final token = await _fcm.getToken();
        if (token != null) {
          await _registerToken(userId, token);
        }

        // 3. Listen for token refreshes
        _tokenRefreshSubscription?.cancel();
        _tokenRefreshSubscription = _fcm.onTokenRefresh.listen((newToken) {
          _registerToken(userId, newToken);
        });

        // 4. Configure foreground presentation options (so notifications show up when app is active)
        await _fcm.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

        // 5. Setup message handlers
        _setupMessageHandlers();
      }
    } catch (e) {
      // Silently handle or log exception to prevent blocking initialization
      debugPrint('Error initializing FCM: $e');
    }
  }

  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_notification');

    // iOS initialization settings can be added here if needed
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
          defaultPresentSound: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await _localNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle foreground notification tap
        if (response.payload != null) {
          try {
            final data = jsonDecode(response.payload!) as Map<String, dynamic>;
            _handleNotificationTap(data);
          } catch (e) {
            _handleNotificationTap({});
          }
        } else {
          _handleNotificationTap({});
        }
      },
    );

    // Create the channel on the device (for Android 8.0+)
    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);
  }

  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        _localNotificationsPlugin.show(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              icon: '@drawable/ic_notification',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
            ),
            iOS: const DarwinNotificationDetails(sound: 'default'),
          ),
          payload: jsonEncode(message.data),
        );

        // Show In-App Notification Popup
        final context = rootNavigatorKey.currentContext;
        if (context != null) {
          final entity = NotificationEntity(
            id:
                message.messageId ??
                DateTime.now().millisecondsSinceEpoch.toString(),
            title: notification.title ?? 'New Notification',
            subtitle: notification.body ?? '',
            time: 'Just now', // Will be translated in widget
            isUnread: true,
            createdAt: DateTime.now(),
            senderImage:
                message.data['contactImage'] as String? ??
                message.data['senderImage'] as String?,
            conversationId: message.data['conversationId'] as String?,
            senderId:
                message.data['otherId'] as String? ??
                message.data['senderId'] as String?,
          );
          // ignore: use_build_context_synchronously
          NotificationPopup.show(context, entity);
        }
      }
    });

    // Handle background notification tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message.data);
    });

    // Handle notification tap when app is fully terminated
    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) {
      if (message != null) {
        // Add a small delay to ensure GoRouter is fully initialized from splash
        Future.delayed(const Duration(milliseconds: 500), () {
          _handleNotificationTap(message.data);
        });
      }
    });
  }

  Future<void> _handleNotificationTap(Map<String, dynamic> data) async {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;

    // Optional: Mark at least one unread notification as read in Firestore
    // to decrease the count.
    _decrementNotificationCount();

    final type = data['type'] as String?;

    if (type == 'message_new') {
      final otherId = data['otherId'] as String? ?? '';
      final contactName = data['contactName'] as String? ?? 'Someone';
      final contactImage = data['contactImage'] as String? ?? '';
      final conversationId = data['conversationId'] as String? ?? '';

      context.push(
        AppConstants.routeMessages,
        extra: PatientChatArgs(
          contactName: contactName,
          contactImage: contactImage,
          conversationId: conversationId,
          otherId: otherId,
        ),
      );
    } else {
      context.push(AppConstants.routeNotifications);
    }
  }

  Future<void> _decrementNotificationCount() async {
    // Optional: Decrement unread notification count via API if supported
    // For now, this is a no-op as the backend handles unread state
  }

  /// Register token via API (if supported by backend)
  Future<void> _registerToken(String userId, String token) async {
    if (userId.isEmpty || token.isEmpty) return;
    // TODO: Send token to backend when endpoint is available
    debugPrint('FCM Token generated: $token');
  }

  /// Remove device token (use this during logout)
  Future<void> removeToken(String userId) async {
    _currentUserId = null;
    try {
      await _fcm.deleteToken();
      _tokenRefreshSubscription?.cancel();
      _tokenRefreshSubscription = null;
    } catch (e) {
      debugPrint('Error removing FCM token: $e');
    }
  }

  String _getPlatformName() {
    // Simple helper to log platform
    try {
      return Uri.base.scheme == 'http' || Uri.base.scheme == 'https'
          ? 'web'
          : 'mobile';
    } catch (_) {
      return 'unknown';
    }
  }
}
