import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/core/domain/models/providerModel.dart';
import 'package:technical_support_artphoto/core/utils/utils.dart';
import 'package:technical_support_artphoto/features/photosalons/photosolons_list.dart';
import 'package:technical_support_artphoto/features/start_screens/authorization.dart';
import 'package:technical_support_artphoto/features/start_screens/splash_screen.dart';
import 'package:technical_support_artphoto/features/technics/technics_list.dart';
import 'package:technical_support_artphoto/core/utils/utils.dart' as utils;

void main() {
  startMeUp() async {
    WidgetsFlutterBinding.ensureInitialized();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    utils.packageInfo = packageInfo;
    runApp(ChangeNotifierProvider(create: (_) => ProviderModel(), child: const SplashScreenArtphoto()));
  }

  startMeUp();
}

class SplashScreenArtphoto extends StatelessWidget {
  const SplashScreenArtphoto({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // localizationsDelegates: const [GlobalMaterialLocalizations.delegate],
        initialRoute: '/SplashScreen',
        routes: {
          '/SplashScreen': (context) => const SplashScreen(),
          '/Authorization': (context) => const Authorization(),
          '/ArtphotoTech': (context) => const ArtphotoTech(),
        },
        theme: ThemeData(
          useMaterial3: false,
        ));
  }
}

class ArtphotoTech extends StatefulWidget {
  const ArtphotoTech({super.key});

  @override
  State<ArtphotoTech> createState() => _ArtphotoTechState();
}

class _ArtphotoTechState extends State<ArtphotoTech> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 1);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final providerModel = Provider.of<ProviderModel>(context);
    ColorAppBar colorAppBar = ColorAppBar();
      return MyBottomAppBar();
    // return DefaultTabController(
    //     length: 1,
    //     child: Scaffold(
    //       appBar: AppBar(
    //           flexibleSpace: colorAppBar.color(),
    //           title: buildTitleAppBar(providerModel.user.keys.first),
    //           bottom: TabBar(controller: _tabController, tabs: const [
    //             Tab(icon: Icon(Icons.add_a_photo_outlined), text: "Главная"),
    //             // Tab(icon: Icon(Icons.settings), text: "Ремонт"),
    //             // Tab(icon: Icon(Icons.assignment_turned_in), text: "Неисп-ти"),
    //             // Tab(icon: Icon(Icons.history), text: "История")
    //           ])),
    //       body: TabBarView(controller: _tabController, children: const [Technicslist()]),
    //       // bottomNavigationBar: ,
    //     ));
  }

  Row buildTitleAppBar(String nameUser) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(nameUser),
      _selectedIndex == 3
          ? const SizedBox()
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shadowColor: Colors.transparent,
            backgroundColor: Colors.black.withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.all(12),
          ),
          child: const Row(
            children: [Icon(Icons.search), Text('Поиск и сортировка')],
          ),
          onPressed: () {
            switch (_selectedIndex) {
              case 0:
              // Navigator.push(context, MaterialPageRoute(builder: (context) => const ViewFindedTechnic()));
                break;
              case 1:
              // Navigator.push(context, MaterialPageRoute(builder: (context) => const ViewFindedRepairs()));
                break;
              case 2:
              // Navigator.push(context, MaterialPageRoute(builder: (context) => const ViewFindedTrouble()));
                break;
            }
          },
        ),
      ),
      // Expanded(child: Container(alignment: Alignment.centerRight, child: myAppBarIconNotifications())),
    ]);
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

class MyBottomAppBar extends StatefulWidget {
  const MyBottomAppBar({super.key});

  @override
  State<MyBottomAppBar> createState() => _MyBottomAppBarState();
}

class _MyBottomAppBarState extends State<MyBottomAppBar> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    ColorAppBar colorAppBar = ColorAppBar();
    return Scaffold(
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          // color: Colors.yellow
          gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [Colors.lightBlueAccent, Colors.purpleAccent],
              stops: [0.0, 0.8],
              tileMode: TileMode.clamp,
          ),
        ),
        child: NavigationBar(
          // backgroundColor: Colors.blueAccent,

          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          indicatorColor: Colors.amber,
          selectedIndex: currentPageIndex,
          destinations: const <Widget>[
            NavigationDestination(
              selectedIcon: Icon(Icons.home),
              icon: Icon(Icons.home_outlined, color: Colors.deepPurple,),
              label: 'Главная',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings),
              label: 'Ремонт',
            ),
            NavigationDestination(
              icon: Icon(Icons.assignment_turned_in),
              label: 'Неисп-ти',
            ),
            NavigationDestination(
              icon: Icon(Icons.history),
              label: 'История',
            ),
          ],
        ),
      ),
      body: <Widget>[

        /// Home page
        PhotosolonsList(),

        Card(
          shadowColor: Colors.transparent,
          margin: const EdgeInsets.all(8.0),
          child: SizedBox.expand(
            child: Center(
              child: Text(
                'Home page',
              ),
            ),
          ),
        ),

        /// Notifications page
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Card(
                child: ListTile(
                  leading: Icon(Icons.notifications_sharp),
                  title: Text('Notification 1'),
                  subtitle: Text('This is a notification'),
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.notifications_sharp),
                  title: Text('Notification 2'),
                  subtitle: Text('This is a notification'),
                ),
              ),
            ],
          ),
        ),

        /// Messages page
        ListView.builder(
          reverse: true,
          itemCount: 2,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return Align(
                alignment: Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    'Hello',
                  ),
                ),
              );
            }
            return Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  'Hi!',
                ),
              ),
            );
          },
        ),
      ][currentPageIndex],
    );
  }
}
