import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/core/api/data/datasources/save_local_services.dart';
import 'package:technical_support_artphoto/core/api/data/models/user.dart';
import 'package:technical_support_artphoto/core/api/provider/provider_model.dart';
import 'package:technical_support_artphoto/core/di/init_dependencies.dart';
import 'package:technical_support_artphoto/core/navigation/main_bottom_page_view.dart';
// import 'package:technical_support_artphoto/core/shared/failed_application/send_mail_failed_app.dart';
import 'package:technical_support_artphoto/features/home/presentation/page/home_page.dart';
import 'package:technical_support_artphoto/features/notifications/models/push_notifications.dart';
import 'package:technical_support_artphoto/features/notifications/presentation/widgets/notification_badge.dart';
import 'package:technical_support_artphoto/features/splash_screen/presentation/page/splash_screen.dart';
import 'core/navigation/main_bottom_app_bar.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    // await Firebase.initializeApp(); // Required if not already done
    debugPrint('Handling a background message: ${message.messageId}');
    // Do your isolate-safe background processing here
  } catch (e, stack) {
    debugPrint('Error in background handler: $e\n$stack');
  }
}

void main() {
  runZonedGuarded<Future<void>>(
        () async {
      WidgetsFlutterBinding.ensureInitialized();
      await initDependencies();
      SaveLocalServices localServices = SaveLocalServices();
      User? user = localServices.getUser();
      FlutterError.onError = (FlutterErrorDetails details) {
        // sendEmailNewTrouble(error: null, stack: null, flutterErrorDetails: '${details.exception}\n\nStack: ${details.stack}',
        //     user: user);
        debugPrint('🔥 FlutterError.onError поймал ошибку: ${details.exception}');
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        // sendEmailNewTrouble(error: error, stack: stack, flutterErrorDetails: '',
        //     user: user);
        debugPrint('🔥 PlatformDispatcher поймал ошибку: $error');
        return true;
      };

      // await Firebase.initializeApp();
      // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      runApp(const MyApp());
    },
        (Object error, StackTrace stack) {
          SaveLocalServices localServices = SaveLocalServices();
          User? user = localServices.getUser();
          // sendEmailNewTrouble(error: error, stack: stack, flutterErrorDetails: '', user: user);
          debugPrint('ARTPHOTO [CrashEvent] [DEBUG] $error\n$stack');
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProviderModel(),
      child: OverlaySupport(
        child: MaterialApp(
            localizationsDelegates: const [GlobalMaterialLocalizations.delegate],
            home: const SplashScreen(),
            theme: ThemeData(
              useMaterial3: false,
              textTheme: TextTheme(
                headlineMedium: GoogleFonts.philosopher(
                  fontSize: 21,
                  color: Colors.black54,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                ),
                titleSmall: GoogleFonts.philosopher(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )),
      ),
    );
  }
}

class ArtphotoTech extends StatefulWidget {
  const ArtphotoTech({super.key, this.indexPage = 0,});

  final int indexPage;

  @override
  State<ArtphotoTech> createState() => _ArtphotoTechState();
}

class _ArtphotoTechState extends State<ArtphotoTech> {
  late PageController pageViewController;
  late int _totalNotifications;
  late final FirebaseMessaging _messaging;
  PushNotification? _notificationInfo;

  DateTime? currentBackPressTime;
  bool canPopNow = false;
  int requiredSeconds = 2;

  @override
  void initState() {
    super.initState();
    pageViewController = PageController(initialPage: widget.indexPage);
    _totalNotifications = 0;
    // registerNotification();

    // checkForInitialMessage();

    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    //   PushNotification notification = PushNotification(
    //     title: message.notification?.title,
    //     body: message.notification?.body,
    //   );
    //   setState(() {
    //     _notificationInfo = notification;
    //     _totalNotifications++;
    //   });

      // _handleMessage(message);
    // });
  }

  @override
  void dispose() {
    super.dispose();
    pageViewController.dispose();
  }

  void _handleMessage(RemoteMessage message) {
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => HomePage()));
  }

  checkForInitialMessage() async {
    await Firebase.initializeApp();
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      PushNotification notification = PushNotification(
        title: initialMessage.notification?.title,
        body: initialMessage.notification?.body,
      );
      setState(() {
        _notificationInfo = notification;
        _totalNotifications++;
      });
    }
  }

  void registerNotification() async {
    // 1. Initialize the Firebase app
    await Firebase.initializeApp();

    // 2. Instantiate Firebase Messaging
    _messaging = FirebaseMessaging.instance;

    // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    // print('TOKEN - ${await _messaging.getToken()}');

    // 3. On iOS, this helps to take the user permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
      // TODO: handle the received notifications
    } else {
      debugPrint('User declined or has not accepted permission');
    }

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');

      // For handling the received notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        // Parse the message received
        PushNotification notification = PushNotification(
          title: message.notification?.title,
          body: message.notification?.body,
        );

        setState(() {
          _notificationInfo = notification;
          _totalNotifications++;
        });
      });
    } else {
      debugPrint('User declined or has not accepted permission');
    }

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        // ...
        if (_notificationInfo != null) {
          // For displaying the notification as an overlay
          showSimpleNotification(
            Text(_notificationInfo!.title!),
            leading: NotificationBadge(totalNotifications: _totalNotifications),
            subtitle: Text(_notificationInfo!.body!),
            background: Colors.cyan.shade700,
            duration: Duration(seconds: 2),
          );
        }
      });
    } else {
      debugPrint('User declined or has not accepted permission');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: MainBottomAppBar(pageController: pageViewController),
        body: PopScope(
            canPop: false,
            onPopInvokedWithResult: (bool didPop, Object? result) async {
              final bool shouldPop = await _onPopInvokedWithResult();
              if (shouldPop) {
                SystemNavigator.pop();
              }
            },
            child: MainBottomPageView(pageController: pageViewController))
    );
  }

  Future<bool> _onPopInvokedWithResult() {
      _showSnackBar();
      DateTime now = DateTime.now();
      if (currentBackPressTime == null ||
          now.difference(currentBackPressTime!) > Duration(seconds: requiredSeconds)) {
        currentBackPressTime = now;
        return Future.delayed(Duration.zero, (){
          return false;
        });
      }
      return Future.delayed(Duration.zero, (){
        return true;
      });
    }

  void _showSnackBar(){
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)
        ),
        // padding: EdgeInsets.all(20),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(Icons.exit_to_app, size: 40, color: Colors.black),
            SizedBox(width: 5,),
            Flexible(child: const Text('Для выхода нажмите назад, еще раз', style: TextStyle(color: Colors.black),)),
          ],
        ),
        backgroundColor: Color(0xFFFFD039),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  }
