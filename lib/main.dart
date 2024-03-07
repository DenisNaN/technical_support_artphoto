import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:technical_support_artphoto/history/HistoryList.dart';
import 'package:technical_support_artphoto/repair/Repair.dart';
import 'package:technical_support_artphoto/repair/RepairList.dart';
import 'package:technical_support_artphoto/repair/RepairViewAndChange.dart';
import 'package:technical_support_artphoto/splashScreen.dart';
import 'package:technical_support_artphoto/technics/Technic.dart';
import 'package:technical_support_artphoto/technics/TechnicViewAndChange.dart';
import 'package:technical_support_artphoto/technics/TechnicsList.dart';
import 'package:technical_support_artphoto/findedEntitys/ViewFindedTechnic.dart';
import 'package:technical_support_artphoto/trouble/TroubleList.dart';
import 'package:technical_support_artphoto/utils/downloadAllList.dart';
import 'package:technical_support_artphoto/utils/notifications.dart';
import 'utils/utils.dart' as utils;
import 'package:technical_support_artphoto/utils/utils.dart';


void main() {
  startMeUp() async {
    WidgetsFlutterBinding.ensureInitialized();

    Directory docsDir = await getApplicationDocumentsDirectory();
    utils.docsDir = docsDir;
    runApp(const SplashScreenArtphoto());
  }
  startMeUp();
}

class SplashScreenArtphoto extends StatelessWidget {
  const SplashScreenArtphoto({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate
        ],
        theme: ThemeData(
          useMaterial3: false,
        ),
        home: const SplashScreen()
    );
  }
}

class ArtphotoTech extends StatefulWidget {
  const ArtphotoTech({super.key});

  @override
  State<ArtphotoTech> createState() => _ArtphotoTechState();
}

class _ArtphotoTechState extends State<ArtphotoTech> with SingleTickerProviderStateMixin{
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 4);
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
    ColorAppBar colorAppBar = ColorAppBar();
    return DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
              flexibleSpace: colorAppBar.color(),
            title: buildTitleAppBar(),
            bottom: TabBar(
              controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.add_a_photo_outlined), text: "Техника"),
                  Tab(icon: Icon(Icons.settings), text: "Ремонт"),
                  Tab(icon: Icon(Icons.assignment_turned_in), text: "Неисп-ти"),
                  Tab(icon: Icon(Icons.history), text: "История")
                ])),
          body: TabBarView(
            controller: _tabController,
              children: const [TechnicsList(),RepairList(),TroubleList(),HistoryList()]),
        )
    );
  }

  Row buildTitleAppBar(){
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(LoginPassword.login),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                padding: EdgeInsets.all(12),
              ),
              child: Icon(Icons.search),
              onPressed: () {
                switch (_selectedIndex){
                  case 0:
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ViewFindedTechnic()));
                    break;
                }
              },
            ),
          ),
      // Expanded(
      //   flex: 5,
      //   child: Container(height: 40,
      //     padding: const EdgeInsets.only(left: 20, top: 5),
      //     child: TextField(
      //       decoration: InputDecoration(
      //           prefixIcon: const Icon(Icons.search),
      //           suffixIcon: IconButton(
      //             icon: const Icon(Icons.clear),
      //             onPressed: () {
      //               setState(() {
      //                 _findController.text = '';
      //               });
      //             }),
      //           contentPadding: const EdgeInsets.only(top: 5, left: 10),
      //           filled: true,
      //           fillColor: Colors.white70,
      //         hintText: "Поиск",
      //         border: OutlineInputBorder(
      //             borderRadius: BorderRadius.circular(10))
      //       ),
      //       controller: _findController,
      //       onSubmitted: (value)=> setState(() {
      //         getListFindTechnic();
      //         Navigator.push(context, MaterialPageRoute(builder: (context) => const ViewFindTechnic()));
      //         }),
      //     ),
      //   ),
      // ),
      Expanded(
        child: Container(
          alignment: Alignment.centerRight,
          child: myAppBarIconNotifications()
      )),
    ]);
  }

  Widget myAppBarIconNotifications(){
    return GestureDetector(
      onTap: (){
        Notifications.notificationsList.clear();
        Notifications.notificationsList.addAll(DownloadAllList.downloadAllList.getNotifications());
        showModalBottomSheet<void>(
          enableDrag: true,
          showDragHandle: true,
          backgroundColor: Colors.purple.shade100,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          context: context,
          builder: (BuildContext context) {
            return SizedBox(
              height: 500,
              child: Center(
                  child: _buildListForBottomSheet()
              ),
            );
          },
        );
      },
      child: SizedBox(
        width: 30,
        height: 30,
        child: Stack(
          children: [
            Notifications.notificationsList.isNotEmpty ? const Icon(
              Icons.notifications_active,
              color: Colors.white,
              size: 30,
            ) : const Icon(
              Icons.notifications_off,
              color: Colors.white,
              size: 30,
            ),
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.topRight,
              margin: const EdgeInsets.only(top: 5),
              child: Container(
                width: 17,
                height: 17,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.shade200,
                    border: Border.all(color: Colors.purpleAccent, width: 1)),
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Center(
                    child: Text('${Notifications.notificationsList.length}',
                      style: const TextStyle(fontSize: 10, color: Colors.black),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  RefreshIndicator _buildListForBottomSheet() {
    return RefreshIndicator(
      onRefresh: () {
        return Future.delayed(
          const Duration(seconds: 1),
            (){
              setState(() {
                Notifications.notificationsList.clear();
                Notifications.notificationsList.addAll(DownloadAllList.downloadAllList.getNotifications());
                Navigator.pop(context);
              });
            }
        );
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: Notifications.notificationsList.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                    colors: [Colors.white54, Colors.white],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 4,
                    offset: Offset(2, 4), // Shadow position
                  ),
                ]
            ),
            child: ListTile(
                onTap: () {
                  switch(Notifications.notificationsList[index].section){
                    case 'Technic':
                      Technic? technicFind = Technic.technicList.firstWhere((item) => item.id == Notifications.notificationsList[index].idSection,
                          orElse: () => null);
                      if(technicFind != null) {
                        Navigator.pop(context);
                        Navigator.push(
                            context, MaterialPageRoute(
                            builder: (context) =>
                                TechnicViewAndChange(technic: technicFind)));
                        break;
                      }
                    case 'Repair':
                      Repair? repairFind = Repair.repairList.firstWhere((item) => item.id == Notifications.notificationsList[index].idSection,
                          orElse: () => null);
                      if(repairFind != null) {
                        Navigator.pop(context);
                        Navigator.push(
                            context, MaterialPageRoute(
                            builder: (context) => RepairViewAndChange(repair: repairFind)));
                        break;
                      }
                  }
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                title: Text(Notifications.notificationsList[index].description)
            ),
          );
        }),
    );
  }


}
