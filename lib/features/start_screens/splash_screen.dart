import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/core/domain/models/providerModel.dart';
import 'package:technical_support_artphoto/features/start_screens/authorization.dart';
import 'package:technical_support_artphoto/main.dart';
import '../../core/utils/download_start_data.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
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
    final providerModel = Provider.of<ProviderModel>(context);

    return FutureBuilder(
        future: DownloadStartData.downloadStartData.getStartData(),
        builder: (context, snapshot) {
          // Check for errors
          if (snapshot.hasError) {
            return const DialogDontConnectDB();
          }
          if (snapshot.hasData) {
            providerModel.downloadAllElements(
                snapshot.data!['Photosalons'], snapshot.data!['Repairs'], snapshot.data!['Storages']);
            WidgetsBinding.instance.addPostFrameCallback((_){
              Navigator.pushReplacementNamed(context, '/Authorization');
            });
          }
          return Scaffold(
            body: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.blue, Colors.purple], begin: Alignment.topRight, end: Alignment.bottomLeft)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/logo_icon.png'),
                  CircularProgressIndicator(),
                ],
              ),
            ),
          );
        });
  }
}

class DialogDontConnectDB extends StatelessWidget {
  const DialogDontConnectDB({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.grey, Colors.white], begin: Alignment.topRight, end: Alignment.bottomLeft)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo_icon.png'),
            const Text(
              "Не удалось подключиться к базе данных.\nОбратитесь к Денису",
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
