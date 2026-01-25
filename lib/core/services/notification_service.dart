import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:safeguardian_ci_new/core/constants/routes.dart';

/// Background message handler (doit être top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📩 Message reçu en arrière-plan: ${message.messageId}');
}

class NotificationService with ChangeNotifier {
  late final FirebaseMessaging _firebaseMessaging;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Global navigator key for navigation from notifications
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  String? _fcmToken;
  bool _notificationsEnabled = true;
  final List<NotificationMessage> _notifications = [];
  bool _initialized = false;

  String? get fcmToken => _fcmToken;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get isInitialized => _initialized;
  List<NotificationMessage> get notifications =>
      List.unmodifiable(_notifications);

  NotificationService() {
    try {
      _firebaseMessaging = FirebaseMessaging.instance;
    } catch (e) {
      debugPrint('❌ Erreur Firebase Messaging init: $e');
      // Continue avec un stub si Firebase fail
    }
  }

  /// Initialise le service de notifications
  Future<void> initialize() async {
    if (_initialized) {
      debugPrint('⚠️ NotificationService déjà initialisé');
      return;
    }

    try {
      await _requestPermissions();
      await _initializeLocalNotifications();
      await _getFCMToken();
      _setupFirebaseListeners();

      // Configurer le handler pour les messages en arrière-plan
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      _initialized = true;
      debugPrint('✅ NotificationService initialisé avec succès');
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('❌ Erreur lors de l\'initialisation des notifications: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Demande les permissions de notifications
  Future<void> _requestPermissions() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
      );

      _notificationsEnabled =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;

      debugPrint(
        '🔔 Permissions notifications: ${settings.authorizationStatus}',
      );
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Erreur permissions: $e');
      _notificationsEnabled = false;
    }
  }

  /// Initialise les notifications locales
  Future<void> _initializeLocalNotifications() async {
    try {
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      final initialized = await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      if (initialized == true) {
        debugPrint('✅ Notifications locales initialisées');

        // Créer le canal de notification Android
        await _createAndroidNotificationChannel();
      } else {
        debugPrint('⚠️ Échec initialisation notifications locales');
      }
    } catch (e) {
      debugPrint('❌ Erreur initialisation notifications locales: $e');
    }
  }

  /// Crée le canal de notification pour Android
  Future<void> _createAndroidNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      'safeguardian_channel', // id
      'SafeGuardian Notifications', // nom
      description: 'Alertes et notifications SafeGuardian',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// Récupère le token FCM
  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      debugPrint('🔑 FCM Token: $_fcmToken');

      // Écouter les changements de token
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('🔄 Nouveau FCM Token: $newToken');
        notifyListeners();
      });
    } catch (e) {
      debugPrint('❌ Erreur récupération FCM Token: $e');
    }
  }

  /// Configure les listeners Firebase
  void _setupFirebaseListeners() {
    // Messages reçus quand l'app est au premier plan
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Messages qui ouvrent l'app depuis l'arrière-plan
    FirebaseMessaging.onMessageOpenedApp.listen(
      (msg) => _handleNotificationTap(msg),
    );

    // Message qui a ouvert l'app (app fermée)
    FirebaseMessaging.instance.getInitialMessage().then((msg) {
      if (msg != null) {
        debugPrint('📱 App ouverte par notification: ${msg.messageId}');
        _handleNotificationTap(msg);
      }
    });
  }

  /// Gère les messages reçus au premier plan
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('📨 Message reçu (foreground): ${message.notification?.title}');

    final notification = NotificationMessage.fromRemoteMessage(message);
    _notifications.insert(0, notification);
    _showLocalNotification(notification);
    notifyListeners();
  }

  /// Affiche une notification locale
  Future<void> _showLocalNotification(NotificationMessage notification) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        'safeguardian_channel',
        'SafeGuardian Notifications',
        channelDescription: 'Alertes SafeGuardian',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        playSound: true,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 500, 250, 500]),
        colorized: true,
        color: const Color(0xFFD32F2F),
        styleInformation: BigTextStyleInformation(
          notification.body,
          contentTitle: notification.title,
        ),
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        badgeNumber: 1,
      );

      final platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        notification.id,
        notification.title,
        notification.body,
        platformDetails,
        payload: json.encode(notification.toJson()),
      );
    } catch (e) {
      debugPrint('❌ Erreur affichage notification: $e');
    }
  }

  /// Gère le tap sur une notification locale
  void _onNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final notification = NotificationMessage.fromJson(
          json.decode(response.payload!),
        );
        _handleNotificationAction(notification);
      } catch (e) {
        debugPrint('❌ Erreur parsing notification payload: $e');
      }
    }
  }

  /// Gère le tap sur une notification Firebase
  void _handleNotificationTap(RemoteMessage message) {
    final notification = NotificationMessage.fromRemoteMessage(message);
    _handleNotificationAction(notification);
  }

  /// Action à effectuer lors du tap sur une notification
  void _handleNotificationAction(NotificationMessage notification) {
    debugPrint('👆 Notification tappée: ${notification.title}');

    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      debugPrint('⚠️ Navigator non disponible pour la navigation');
      return;
    }

    // Navigation selon le type de notification
    switch (notification.type) {
      case NotificationType.emergency:
        // Navigate to emergency screen with alert details
        debugPrint('🚨 Navigation vers écran d\'urgence');
        navigator.pushNamedAndRemoveUntil(
          AppRoutes.emergency,
          (route) => false,
          arguments: notification.data,
        );
        break;

      case NotificationType.communityAlert:
        // Navigate to community alerts
        debugPrint('📢 Navigation vers alertes communautaires');
        navigator.pushNamedAndRemoveUntil(
          AppRoutes.communityAlerts,
          (route) => false,
        );
        break;

      case NotificationType.contactAlert:
        // Navigate to contacts screen
        debugPrint('👥 Navigation vers contacts');
        navigator.pushNamedAndRemoveUntil(AppRoutes.contacts, (route) => false);
        break;

      case NotificationType.itemFound:
        // Navigate to items screen
        debugPrint('📄 Navigation vers objets trouvés');
        navigator.pushNamedAndRemoveUntil(AppRoutes.items, (route) => false);
        break;

      case NotificationType.documentFound:
        // Navigate to documents screen
        debugPrint('📄 Navigation vers documents');
        navigator.pushNamedAndRemoveUntil(
          AppRoutes.documents,
          (route) => false,
        );
        break;

      case NotificationType.battery:
        // Navigate to device settings
        debugPrint('🔋 Navigation vers paramètres appareil');
        navigator.pushNamedAndRemoveUntil(
          AppRoutes.deviceSettings,
          (route) => false,
        );
        break;

      case NotificationType.device:
        // Navigate to device/bluetooth settings
        debugPrint('📱 Navigation vers paramètres appareil');
        navigator.pushNamedAndRemoveUntil(
          AppRoutes.deviceSettings,
          (route) => false,
        );
        break;

      case NotificationType.system:
        // Navigate to dashboard
        debugPrint('📱 Navigation vers tableau de bord');
        navigator.pushNamedAndRemoveUntil(
          AppRoutes.dashboard,
          (route) => false,
        );
        break;
    }
  }

  /// Envoie une notification de test
  Future<void> sendTestNotification() async {
    final notification = NotificationMessage(
      id: DateTime.now().millisecondsSinceEpoch,
      title: 'Test Notification',
      body: 'Ceci est une notification de test',
      type: NotificationType.system,
      data: {'test': true},
    );

    _notifications.insert(0, notification);
    await _showLocalNotification(notification);
    notifyListeners();
  }

  /// Efface toutes les notifications
  void clearNotifications() {
    _notifications.clear();
    _localNotifications.cancelAll();
    notifyListeners();
  }

  /// Marque une notification comme lue
  void markAsRead(int id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  /// Marque toutes les notifications comme lues
  void markAllAsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  /// Supprime une notification spécifique
  void deleteNotification(int id) {
    _notifications.removeWhere((n) => n.id == id);
    _localNotifications.cancel(id);
    notifyListeners();
  }

  /// Nombre de notifications non lues
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  void dispose() {
    // Cleanup si nécessaire
    super.dispose();
  }
}

class NotificationMessage {
  final int id;
  final String title;
  final String body;
  final NotificationType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  bool isRead;

  NotificationMessage({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    DateTime? timestamp,
    this.isRead = false,
  }) : timestamp = timestamp ?? DateTime.now();

  factory NotificationMessage.fromRemoteMessage(RemoteMessage message) {
    return NotificationMessage(
      id: DateTime.now().millisecondsSinceEpoch,
      title: message.notification?.title ?? 'SafeGuardian',
      body: message.notification?.body ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == (message.data['type'] ?? 'system'),
        orElse: () => NotificationType.system,
      ),
      data: Map<String, dynamic>.from(message.data),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'type': type.name,
    'data': data,
    'timestamp': timestamp.toIso8601String(),
    'isRead': isRead,
  };

  factory NotificationMessage.fromJson(Map<String, dynamic> json) =>
      NotificationMessage(
        id: json['id'] as int,
        title: json['title'] as String,
        body: json['body'] as String,
        type: NotificationType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => NotificationType.system,
        ),
        data: Map<String, dynamic>.from(json['data'] as Map),
        timestamp: DateTime.parse(json['timestamp'] as String),
        isRead: json['isRead'] as bool? ?? false,
      );
}

enum NotificationType {
  emergency,
  communityAlert,
  contactAlert,
  itemFound,
  documentFound,
  system,
  battery,
  device,
}
