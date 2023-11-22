import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:technical_support_artphoto/repair/RepairSQFlite.dart';
import 'package:technical_support_artphoto/technics/Technic.dart';
import 'package:technical_support_artphoto/utils/categoryDropDownValueModel.dart';
import 'package:technical_support_artphoto/utils/downloadAllList.dart';
import 'ConnectToDBMySQL.dart';
import 'repair/Repair.dart';
import 'main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin{

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: DownloadAllList.downloadAllList.getAllList(),
        // future: ConnectToDBMySQL.connDB.getAll(),
        builder: (context, snapshot) {
          // Check for errors
          if (snapshot.hasError) {
            return const dialogDontConnectDB();
          }

          if (snapshot.hasData) {
            Technic.technicList.addAll(snapshot.data?[0]);
            Repair.repairList.addAll(snapshot.data?[1]);
            CategoryDropDownValueModel.nameEquipment.addAll(snapshot.data?[2]);
            CategoryDropDownValueModel.photosalons.addAll(snapshot.data?[3]);
            CategoryDropDownValueModel.service.addAll(snapshot.data?[4]);
            CategoryDropDownValueModel.statusForEquipment.addAll(snapshot.data?[5]);

            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (_) => const ArtphotoTech()));
            });
          }

          // return const Center(child: CircularProgressIndicator());
          return Scaffold(
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
                ],
              ),
            ),
          );
        });
  }
}

class dialogDontConnectDB extends StatelessWidget {
  const dialogDontConnectDB({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.grey, Colors.white],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft
            )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo_icon.png'),
            const Text("Не удалось подключиться к базе данных. Обратитесь к Денису",
            textAlign: TextAlign.center,)
          ],
        ),
      ),
    );
  }
}

