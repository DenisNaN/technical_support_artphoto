import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/core/api/provider/provider_model.dart';
import 'package:technical_support_artphoto/core/navigation/animation_navigation.dart';
import 'package:technical_support_artphoto/features/auth/presentation/page/authorization.dart';
import '../../../../core/api/data/datasources/save_local_services.dart';
import '../../../../core/api/data/models/user.dart';
import '../../../../core/api/data/repositories/technical_support_repo_impl.dart';
import '../../../../main.dart';

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
    SaveLocalServices localServices = SaveLocalServices();

    return FutureBuilder(
        future: TechnicalSupportRepoImpl.downloadData.getStartData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const DialogDontConnectDB();
          }
          if (snapshot.hasData) {
            providerModel.downloadAllElements(
                snapshot.data!['Photosalons'], snapshot.data!['Repairs'], snapshot.data!['Storages']);
            providerModel.downloadAllCategoryDropDown(
                snapshot.data!['nameEquipment'],
                snapshot.data!['namePhotosalons'],
                snapshot.data!['services'],
                snapshot.data!['statusForEquipment'],
                snapshot.data!['colorsForEquipment']);
            providerModel.downloadCurrentRepairs(snapshot.data!['AllRepairs']);
            providerModel.downloadTroubles(snapshot.data!['AllTroubles']);

            WidgetsBinding.instance.addPostFrameCallback((_) {
              User? user = localServices.getUser();
              if(user != null){
                providerModel.initUser(user);
              }
              if (user != null && (user.isAutocomplete ?? false)) {
                Navigator.pushReplacement(context, animationRouteSlideTransition(const ArtphotoTech()));
              } else {
                Navigator.pushReplacement(context, animationRouteFadeTransition(const Authorization()));
              }
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
                  Hero(tag: 'logo_hero', child: Image.asset('assets/logo/logo.png')),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Техническая\n Поддержка',
                    style: TextStyle(fontSize: 35),
                  ),
                  SizedBox(
                    height: 10,
                  ),
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
            Image.asset('assets/logo/logo.png'),
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
