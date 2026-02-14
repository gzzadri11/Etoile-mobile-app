import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../router/app_router.dart';

/// Service for managing push notifications (FCM + local notifications)
class PushNotificationService {
  final SupabaseClient _supabaseClient;

  PushNotificationService({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Current active conversation ID (set by ChatPage, null if not on a chat)
  String? activeConversationId;

  /// Global navigator key for showing snackbars and navigating
  GlobalKey<NavigatorState>? navigatorKey;

  /// GoRouter instance for deep linking
  GoRouter? router;

  // ==========================================================================
  // INITIALIZATION
  // ==========================================================================

  /// Initialize Firebase Messaging and local notifications
  Future<void> initialize({
    GlobalKey<NavigatorState>? navigatorKey,
    GoRouter? router,
  }) async {
    this.navigatorKey = navigatorKey;
    this.router = router;

    // Skip on web - FCM push not supported in v1
    if (kIsWeb) {
      debugPrint('[PushNotif] Web platform - skipping FCM setup');
      return;
    }

    try {
      // Request permission (iOS + Android 13+)
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      debugPrint('[PushNotif] Permission: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('[PushNotif] Notifications denied by user');
        return;
      }

      // Setup local notifications (Android notification channel)
      await _setupLocalNotifications();

      // Listen to foreground messages
      FirebaseMessaging.onMessage.listen(_onForegroundMessage);

      // Listen to notification tap (app in background → opened)
      FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

      // Check if app was opened from a terminated state notification
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('[PushNotif] App opened from terminated notification');
        _handleNotificationTap(initialMessage);
      }

      // Listen to token refresh
      _messaging.onTokenRefresh.listen(_onTokenRefresh);

      debugPrint('[PushNotif] Initialized successfully');
    } catch (e) {
      debugPrint('[PushNotif] Initialization error: $e');
    }
  }

  /// Setup flutter_local_notifications with Android channel
  Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint('[PushNotif] Local notification tapped: ${response.payload}');
        // Deep link handled via payload
        if (response.payload != null) {
          _handlePayloadTap(response.payload!);
        }
      },
    );

    // Create Android notification channel
    const channel = AndroidNotificationChannel(
      'messages',
      'Messages',
      description: 'Notifications pour les nouveaux messages',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // ==========================================================================
  // TOKEN MANAGEMENT
  // ==========================================================================

  /// Register FCM token in Supabase after login
  Future<void> registerToken() async {
    if (kIsWeb) return;

    try {
      final token = await _messaging.getToken();
      if (token == null) {
        debugPrint('[PushNotif] No FCM token available');
        return;
      }

      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('[PushNotif] No user logged in');
        return;
      }

      final platform = Platform.isAndroid ? 'android' : 'ios';

      debugPrint('[PushNotif] Registering token for $platform...');

      // Upsert: insert or update if token already exists
      await _supabaseClient.from('device_tokens').upsert(
        {
          'user_id': userId,
          'token': token,
          'platform': platform,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'user_id,token',
      );

      debugPrint('[PushNotif] Token registered successfully');
    } catch (e) {
      debugPrint('[PushNotif] Error registering token: $e');
    }
  }

  /// Remove FCM token from Supabase on logout
  Future<void> removeToken() async {
    if (kIsWeb) return;

    try {
      final token = await _messaging.getToken();
      if (token == null) return;

      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) return;

      debugPrint('[PushNotif] Removing token...');

      await _supabaseClient
          .from('device_tokens')
          .delete()
          .eq('user_id', userId)
          .eq('token', token);

      debugPrint('[PushNotif] Token removed');
    } catch (e) {
      debugPrint('[PushNotif] Error removing token: $e');
    }
  }

  /// Handle token refresh (FCM may rotate tokens)
  Future<void> _onTokenRefresh(String newToken) async {
    debugPrint('[PushNotif] Token refreshed, updating...');
    await registerToken();
  }

  // ==========================================================================
  // FOREGROUND HANDLER
  // ==========================================================================

  /// Handle incoming message when app is in foreground
  void _onForegroundMessage(RemoteMessage message) {
    debugPrint('[PushNotif] Foreground message: ${message.data}');

    final type = message.data['type'];
    final conversationId = message.data['conversation_id'];

    // Don't show notification if user is already on this chat
    if (type == 'new_message' && conversationId == activeConversationId) {
      debugPrint('[PushNotif] Already on this chat, skipping notification');
      return;
    }

    // Show in-app snackbar
    _showInAppNotification(message);
  }

  /// Show a snackbar/material banner for in-app notification
  void _showInAppNotification(RemoteMessage message) {
    final context = navigatorKey?.currentContext;
    if (context == null) return;

    final title = message.notification?.title ?? 'Notification';
    final body = message.notification?.body ?? '';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.notifications, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (body.isNotEmpty)
                    Text(
                      body,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70),
                    ),
                ],
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'Voir',
          textColor: const Color(0xFFFFB800),
          onPressed: () => _handleNotificationTap(message),
        ),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1A1A1A),
        margin: const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 8),
      ),
    );
  }

  // ==========================================================================
  // NOTIFICATION TAP (DEEP LINKING)
  // ==========================================================================

  /// Handle notification tap (from background or terminated)
  void _onMessageOpenedApp(RemoteMessage message) {
    debugPrint('[PushNotif] Notification tapped: ${message.data}');
    _handleNotificationTap(message);
  }

  /// Navigate to the appropriate screen based on notification data
  void _handleNotificationTap(RemoteMessage message) {
    final type = message.data['type'];
    final goRouter = router;
    if (goRouter == null) return;

    switch (type) {
      case 'new_message':
      case 'new_conversation':
        final conversationId = message.data['conversation_id'];
        if (conversationId != null) {
          goRouter.push(AppRoutes.chatWith(conversationId));
        }
        break;
      case 'profile_reminder':
        final userRole = message.data['user_role'];
        if (userRole == 'recruiter') {
          goRouter.push(AppRoutes.editRecruiterProfile);
        } else {
          goRouter.push(AppRoutes.editProfile);
        }
        break;
      default:
        debugPrint('[PushNotif] Unknown notification type: $type');
    }
  }

  /// Handle tap from local notification payload (JSON string)
  void _handlePayloadTap(String payload) {
    // Payload format: "type:conversation_id" or "type:role"
    final parts = payload.split(':');
    if (parts.length < 2) return;

    final goRouter = router;
    if (goRouter == null) return;

    final type = parts[0];
    final value = parts[1];

    switch (type) {
      case 'new_message':
      case 'new_conversation':
        goRouter.push(AppRoutes.chatWith(value));
        break;
      case 'profile_reminder':
        if (value == 'recruiter') {
          goRouter.push(AppRoutes.editRecruiterProfile);
        } else {
          goRouter.push(AppRoutes.editProfile);
        }
        break;
    }
  }
}

/// Top-level background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('[PushNotif] Background message: ${message.messageId}');
  // Android/iOS will automatically show the notification from the
  // "notification" key in the FCM payload. No extra handling needed.
}
