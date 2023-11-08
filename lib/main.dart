import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:technical_support_artphoto/repair/RepairList.dart';
import 'package:technical_support_artphoto/splashScreen.dart';
import 'package:technical_support_artphoto/technics/TechnicsList.dart';
import 'utils/utils.dart' as utils;

void main() {
  startMeUp() async {

    runApp(const SplashScreenArtphoto());

    Directory docsDir = await getApplicationDocumentsDirectory();
    utils.docsDir = docsDir;

    // Technic.entityList = await ConnectToDBMySQL.connDB.getAllTechnics();
    // History.historyList = await ConnectToDBMySQL.connDB.getAllHistory();
    // CategoryDropDownValueModel.photosalons = await ConnectToDBMySQL.connDB.getPhotosalons() as List<DropDownValueModel>;
    // CategoryDropDownValueModel.nameEquipment = await ConnectToDBMySQL.connDB.getNameEquipment() as List<DropDownValueModel>;
    // CategoryDropDownValueModel.service = await ConnectToDBMySQL.connDB.getService() as List<DropDownValueModel>;
    // CategoryDropDownValueModel.statusForEquipment = await ConnectToDBMySQL.connDB.getStatusForEquipment() as List<DropDownValueModel>;
  }
  startMeUp();
}

class SplashScreenArtphoto extends StatelessWidget {
  const SplashScreenArtphoto({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate
        ],
        home: SplashScreen()
    );
  }
}

class ArtphotoTech extends StatelessWidget {
  const ArtphotoTech({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            // title: const Center(child: Text('Artphoto')),
              bottom: const TabBar(tabs: [
                Tab(icon: Icon(Icons.add_a_photo_outlined), text: "Техника"),
                Tab(icon: Icon(Icons.add_chart), text: "История"),
                Tab(icon: Icon(Icons.accessible), text: "Неисправности"),
                Tab(icon: Icon(Icons.assignment_turned_in), text: "Tasks")
              ])),
          body: const TabBarView(
              children: [TechnicsList(),RepairList(),TechnicsList(),TechnicsList()]),
          // children: [Appointments(), Contacts(), Notes(), Tasks()]),
        )
    );
  }
}

class notConnection extends StatelessWidget {
  const notConnection({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
          body: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.blue, Colors.purple],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft
                )
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/logo_icon.png'),
                Text("Не удалось подключиться к базе данных. Обратитесь к Денису")
              ],
            ),
          ),
        )
    );
  }
}

