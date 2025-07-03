import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/core/api/data/datasources/save_local_services.dart';
import 'package:technical_support_artphoto/core/api/data/models/user.dart';
import 'package:technical_support_artphoto/core/api/provider/provider_model.dart';
import 'package:technical_support_artphoto/core/di/init_dependencies.dart';
import 'package:technical_support_artphoto/core/navigation/main_bottom_page_view.dart';
import 'package:technical_support_artphoto/core/shared/failed_application/send_mail_failed_app.dart';
import 'package:technical_support_artphoto/features/splash_screen/presentation/page/splash_screen.dart';
import 'core/navigation/main_bottom_app_bar.dart';

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

  @override
  void initState() {
    super.initState();
    pageViewController = PageController(initialPage: widget.indexPage);
  }

  @override
  void dispose() {
    super.dispose();
    pageViewController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: MainBottomAppBar(pageController: pageViewController),
        body: MainBottomPageView(pageController: pageViewController)
    );
  }

// Widget myAppBarIconNotifications() {
//   return GestureDetector(
//     onTap: () {
//       showModalBottomSheet<void>(
//         enableDrag: true,
//         showDragHandle: true,
//         backgroundColor: Colors.purple.shade100,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
//         ),
//         context: context,
//         builder: (BuildContext context) {
//           return SizedBox(
//             height: 500,
//             child: Center(child: _buildListForBottomSheet()),
//           );
//         },
//       );
//     },
//     child: SizedBox(
//       width: 30,
//       height: 30,
//       child: Stack(
//         children: [
//           Notifications.notificationsList.isNotEmpty
//               ? const Icon(
//                   Icons.notifications_active,
//                   color: Colors.white,
//                   size: 30,
//                 )
//               : const Icon(
//                   Icons.notifications_off,
//                   color: Colors.white,
//                   size: 30,
//                 ),
//           Container(
//             width: 30,
//             height: 30,
//             alignment: Alignment.topRight,
//             margin: const EdgeInsets.only(top: 5),
//             child: Container(
//               width: 17,
//               height: 17,
//               decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: Colors.blue.shade200,
//                   border: Border.all(color: Colors.purpleAccent, width: 1)),
//               child: Padding(
//                 padding: const EdgeInsets.all(0.0),
//                 child: Center(
//                   child: Text(
//                     '${Notifications.notificationsList.length}',
//                     style: const TextStyle(fontSize: 10, color: Colors.black),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
//
// ListView _buildListForBottomSheet() {
//   return ListView.builder(
//       physics: const AlwaysScrollableScrollPhysics(),
//       itemCount: Notifications.notificationsList.length,
//       itemBuilder: (context, index) {
//         return Container(
//           margin: const EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 8),
//           decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(10),
//               gradient: const LinearGradient(
//                   colors: [Colors.white54, Colors.white], begin: Alignment.topRight, end: Alignment.bottomLeft),
//               boxShadow: const [
//                 BoxShadow(
//                   color: Colors.grey,
//                   blurRadius: 4,
//                   offset: Offset(2, 4), // Shadow position
//                 ),
//               ]),
//           child: ListTile(
//               onTap: () {
//                 switch (Notifications.notificationsList[index].section) {
//                   case 'Technic':
//                     Technic? technicFind = Technic.technicList.firstWhere(
//                         (item) => item.id == Notifications.notificationsList[index].idSection,
//                         orElse: () => null);
//                     if (technicFind != null) {
//                       Navigator.pop(context);
//                       Navigator.push(context,
//                               MaterialPageRoute(builder: (context) => TechnicViewAndChange(technic: technicFind)))
//                           .then((value) {
//                         setState(() {
//                           if (value != null) {
//                             Technic.technicList[Technic.technicList.indexWhere(
//                                 (element) => element.id == Notifications.notificationsList[index].idSection)] = value;
//                             Notifications.notificationsList.clear();
//                             Notifications.notificationsList
//                                 .addAll(DownloadAllList.downloadStartData.getNotifications());
//                           }
//                         });
//                       });
//                       break;
//                     }
//                   case 'Repair':
//                     Repair? repairFind = Repair.repairList.firstWhere(
//                         (item) => item.id == Notifications.notificationsList[index].idSection,
//                         orElse: () => null);
//                     if (repairFind != null) {
//                       Navigator.pop(context);
//                       Navigator.push(context,
//                               MaterialPageRoute(builder: (context) => RepairViewAndChange(repair: repairFind)))
//                           .then((value) {
//                         setState(() {
//                           if (value != null) {
//                             Repair.repairList[Repair.repairList.indexWhere(
//                                 (element) => element.id == Notifications.notificationsList[index].idSection)] = value;
//                             Notifications.notificationsList.clear();
//                             Notifications.notificationsList
//                                 .addAll(DownloadAllList.downloadStartData.getNotifications());
//                           }
//                         });
//                       });
//                       break;
//                     }
//                 }
//               },
//               contentPadding: const EdgeInsets.symmetric(horizontal: 12),
//               title: Text(Notifications.notificationsList[index].description)),
//         );
//       });
// }
}
