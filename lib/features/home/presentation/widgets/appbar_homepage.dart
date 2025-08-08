import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/features/home/presentation/widgets/popup_menu_home_page.dart';

import '../../../../core/api/data/datasources/save_local_services.dart';
import '../../../../core/api/data/models/user.dart';
import '../../../../core/api/provider/provider_model.dart';
import '../../../../core/navigation/animation_navigation.dart';
import '../../../auth/presentation/page/authorization.dart';

class AppBarHomepage extends StatefulWidget implements PreferredSizeWidget{
  const AppBarHomepage({super.key});

  @override
  State<AppBarHomepage> createState() => _AppBarHomepageState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppBarHomepageState extends State<AppBarHomepage> {
  bool isVisibleExit = false;

  @override
  Widget build(BuildContext context) {
    SaveLocalServices localServices = SaveLocalServices();
    final providerModel = Provider.of<ProviderModel>(context);
    final User user = providerModel.user;
    return AppBar(
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
      ),
      actions: [
        PopupMenuHomePage(),
      ],
    );
  }
}
