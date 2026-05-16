import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'api_client.dart';

// Arka planda gelen bildirimler için top-level handler
@pragma('vm:entry-point')
Future<void> _arkaplanBildirimHandler(RemoteMessage message) async {
  // Firebase zaten arka planda otomatik gösterir, ek işlem gerekmez
}

class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _kanal = AndroidNotificationChannel(
    'halisaha_bildirimler',
    'Halı Saha Bildirimleri',
    description: 'Maç, ilan ve takım bildirimleri',
    importance: Importance.high,
    playSound: true,
  );

  Future<void> init(BuildContext context) async {
    // Arka plan handler
    FirebaseMessaging.onBackgroundMessage(_arkaplanBildirimHandler);

    // Local notification setup
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_kanal);

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: (details) =>
          _bildirimeTikla(details.payload, context),
    );

    // İzin iste
    await _izinIste();

    // Ön planda gelen bildirimleri göster
    FirebaseMessaging.onMessage.listen((msg) => _onMessage(msg, context));

    // Kullanıcı bildirime tıklayıp uygulamayı açtıysa
    FirebaseMessaging.onMessageOpenedApp
        .listen((msg) => _bildirimeTikla(msg.data['hedefId'], context));

    // Uygulama kapalıyken tıklanan bildirim
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      _bildirimeTikla(initial.data['hedefId'], context);
    }
  }

  Future<void> _izinIste() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      await tokenKaydet();
    }
  }

  Future<void> tokenKaydet() async {
    try {
      final token = await _messaging.getToken();
      if (token == null) return;
      await ApiClient().dio.post('/api/fcm/token', data: {
        'token': token,
        'platform': 'android',
      });
      // Token yenilenince otomatik kaydet
      _messaging.onTokenRefresh.listen((newToken) {
        ApiClient().dio.post('/api/fcm/token',
            data: {'token': newToken, 'platform': 'android'});
      });
    } catch (_) {}
  }

  Future<void> tokenSil() async {
    try {
      await _messaging.deleteToken();
      await ApiClient().dio.delete('/api/fcm/token?platform=android');
    } catch (_) {}
  }

  void _onMessage(RemoteMessage msg, BuildContext context) {
    final notification = msg.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _kanal.id,
          _kanal.name,
          channelDescription: _kanal.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: msg.data['hedefId'],
    );
  }

  void _bildirimeTikla(String? hedefId, BuildContext context) {
    // Navigasyon mantığı ileride genişletilebilir
  }
}
