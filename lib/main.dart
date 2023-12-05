import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:technical_support_artphoto/repair/RepairList.dart';
import 'package:technical_support_artphoto/splashScreen.dart';
import 'package:technical_support_artphoto/technics/TechnicsList.dart';
import 'utils/utils.dart' as utils;
import 'package:technical_support_artphoto/utils/utils.dart';

void main() {
  startMeUp() async {
    WidgetsFlutterBinding.ensureInitialized();

    Directory docsDir = await getApplicationDocumentsDirectory();
    print(docsDir);
    utils.docsDir = docsDir;
    runApp(const SplashScreenArtphoto());
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
            title: Center(child: Text(LoginPassword.login)),
              bottom: const TabBar(tabs: [
                Tab(icon: Icon(Icons.add_a_photo_outlined), text: "Техника"),
                Tab(icon: Icon(Icons.add_chart), text: "Ремонт"),
                Tab(icon: Icon(Icons.accessible), text: "История"),
                Tab(icon: Icon(Icons.assignment_turned_in), text: "Неисп-ти")
              ])),
          body: const TabBarView(
              children: [TechnicsList(),RepairList(),TechnicsList(),TechnicsList()]),
          // children: [Appointments(), Contacts(), Notes(), Tasks()]),
        )
    );
  }
}

