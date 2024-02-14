import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:technical_support_artphoto/history/HistoryList.dart';
import 'package:technical_support_artphoto/repair/RepairList.dart';
import 'package:technical_support_artphoto/splashScreen.dart';
import 'package:technical_support_artphoto/technics/TechnicsList.dart';
import 'package:technical_support_artphoto/trouble/TroubleList.dart';
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
          // appBarTheme: AppBarTheme(
          //     backgroundColor: Colors.purple)
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
    return DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      colors: [Colors.lightBlueAccent, Colors.purpleAccent]),
                ),
              ),
            title: Center(child: Text(LoginPassword.login)),
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
}