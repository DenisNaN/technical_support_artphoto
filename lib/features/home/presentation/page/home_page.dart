import 'dart:io';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/core/api/data/datasources/save_local_services.dart';
import 'package:technical_support_artphoto/core/api/data/repositories/technical_support_repo_impl.dart';
import 'package:technical_support_artphoto/core/api/provider/provider_model.dart';
import 'package:technical_support_artphoto/features/home/presentation/widgets/grid_view_home_page.dart';
import 'package:technical_support_artphoto/features/home/presentation/widgets/my_custom_refresh_indicator.dart';
import 'package:technical_support_artphoto/features/technics/presentation/page/technic_add.dart';

import '../../../../core/api/data/models/user.dart';
import '../../../../core/navigation/animation_navigation.dart';
import '../../../auth/presentation/page/authorization.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = IndicatorController();
  bool isVisibleExit = false;

  @override
  Widget build(BuildContext context) {
    SaveLocalServices localServices = SaveLocalServices();
    final providerModel = Provider.of<ProviderModel>(context);
    final User user = providerModel.user;
    final double height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      appBar: AppBar(
          title: Row(
        children: [
          GestureDetector(
              onTap: () async {
                final XFile? pickedImage = await localServices.pickImage();
                if (pickedImage != null) {
                  try {
                    final String imagePath = await localServices.saveImageLocally(
                      imageFile: File(pickedImage.path),
                    );
                    user.imagePath = imagePath;
                    localServices.saveUser(user);
                    providerModel.updateUser(user);
                  } on Exception catch (e) {
                    debugPrint('Error when local save image: $e');
                  }
                }
              },
              child: CircleAvatar(
                backgroundImage: user.imagePath != null ? Image.file(File(user.imagePath!)).image : Image.asset('assets/avatar/anon_avatar.jpg').image,
              )),
          TextButton(
              onPressed: () {
                setState(() {
                  isVisibleExit = !isVisibleExit;
                });
              },
              child: Text(
                user.name,
                style: TextStyle(color: Colors.white, fontSize: 18),
              )),
          isVisibleExit
              ? TextButton(
                  onPressed: () {
                    localServices.removeUser();
                    Navigator.pushReplacement(context, animationRouteFadeTransition(const Authorization()));
                  },
                  child: Text(
                    'Выйти',
                    style: TextStyle(color: Colors.white),
                  ))
              : SizedBox()
        ],
      )
          // actions: [
          //   MenuHomePage(),
          // ],
          ),
      body: SafeArea(
        child: WarpIndicator(
            controller: _controller,
            onRefresh: () => TechnicalSupportRepoImpl.downloadData.refreshData().then((resultData) {
                  providerModel.refreshAllElement(
                      resultData['Photosalons'], resultData['Repairs'], resultData['Storages']);
                }),
            child: CustomScrollView(
              physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                GridViewHomePage(locations: providerModel.technicsInPhotosalons, color: providerModel.colorPhotosalons),
                GridViewHomePage(locations: providerModel.technicsInStorages, color: providerModel.colorStorages),
                GridViewHomePage(locations: providerModel.technicsInRepairs, color: providerModel.colorRepairs),
              ],
            )),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: height / 11),
        child: FloatingActionButton.extended(
            icon: Icon(Icons.add),
            label: Text('Добавить технику'),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const TechnicAdd()));
            }),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
