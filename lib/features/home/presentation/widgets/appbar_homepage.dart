import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/core/api/data/repositories/technical_support_repo_impl.dart';
import 'package:technical_support_artphoto/core/shared/input_decoration/input_deroration.dart';
import 'package:technical_support_artphoto/core/shared/loader_overlay/loading_overlay.dart';
import 'package:technical_support_artphoto/features/technics/models/technic.dart';
import 'package:technical_support_artphoto/features/technics/presentation/page/technic_view.dart';

import '../../../../core/api/data/datasources/save_local_services.dart';
import '../../../../core/api/data/models/user.dart';
import '../../../../core/api/provider/provider_model.dart';
import '../../../../core/navigation/animation_navigation.dart';
import '../../../auth/presentation/page/authorization.dart';

class AppBarHomepage extends StatefulWidget  implements PreferredSizeWidget{
  const AppBarHomepage({super.key});

  @override
  State<AppBarHomepage> createState() => _AppBarHomepageState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppBarHomepageState extends State<AppBarHomepage> {
  bool isVisibleExit = false;
  final _numberTechnic = TextEditingController();

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
        IconButton(
            onPressed: (){
              showDialog(
                  context: context,
                  builder: (_){
                    return AlertDialog(
                      title: Column(
                        spacing: 10,
                        children: [
                          TextFormField(
                            decoration: myDecorationTextFormField('Введите номер техники'),
                            controller: _numberTechnic,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Обязательное поле';
                              }
                              return null;
                            },
                            inputFormatters: [numberFormatter],
                            keyboardType: TextInputType.number,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                  onPressed: (){
                                    TechnicalSupportRepoImpl.downloadData.getTechnic(_numberTechnic.text).then((technic){
                                      if(technic != null){
                                        _navigationOnTechnicView(technic);
                                      }else{
                                        _viewSnackBar(Icons.delete_forever, false, '', 'Техника не найдена');
                                      }
                                    });
                                  }, child: Text('Искать')),
                              ElevatedButton(onPressed: (){
                                Navigator.of(context).pop();
                              }, child: Text('Отмена'))
                          ],)
                        ],
                      ),
                    );
                  });
            },
            icon: Icon(Icons.search))
      ],
    );
  }

  void _navigationOnTechnicView(Technic technic) {
    Navigator.push(
        context,
        animationRouteSlideTransition(
            LoadingOverlay(child: TechnicView(location: technic.dislocation, technic: technic))));
  }

  final numberFormatter = FilteringTextInputFormatter.allow(
    RegExp(r'[0-9]'),
  );

  void _viewSnackBar(IconData icon, bool isSuccessful, String successText, String notSuccessText) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(icon, size: 40, color: isSuccessful ? Colors.green : Colors.red),
              SizedBox(
                width: 20,
              ),
              Flexible(child: Text(isSuccessful ? successText : notSuccessText)),
            ],
          ),
          duration: const Duration(seconds: 5),
          showCloseIcon: true,
        ),
      );
      Navigator.pop(context);
    }
  }
}
