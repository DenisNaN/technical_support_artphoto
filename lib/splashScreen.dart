import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:technical_support_artphoto/main.dart';
import 'package:technical_support_artphoto/utils/authorization.dart';
import 'package:technical_support_artphoto/utils/downloadAllList.dart';
import 'package:technical_support_artphoto/utils/hasNetwork.dart';


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
        builder: (context, snapshot) {
          // Check for errors
          if (snapshot.hasError) {
            return const dialogDontConnectDB();
          }
          if (snapshot.hasData) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (_) => HasNetwork.isConnecting ? const Login() : const ArtphotoTech()));
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
            const Text("Не удалось подключиться к базе данных.\nОбратитесь к Денису",
            textAlign: TextAlign.center,)
          ],
        ),
      ),
    );
  }
}

