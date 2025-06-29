import 'package:flutter/material.dart';
import 'package:technical_support_artphoto/core/api/data/repositories/technical_support_repo_impl.dart';
import 'package:technical_support_artphoto/core/navigation/animation_navigation.dart';
import 'package:technical_support_artphoto/core/shared/gradients.dart';
import 'package:technical_support_artphoto/core/shared/input_decoration/input_deroration.dart';
import 'package:technical_support_artphoto/core/shared/loader_overlay/loading_overlay.dart';
import 'package:technical_support_artphoto/core/utils/formatters.dart';
import 'package:technical_support_artphoto/features/technics/models/technic.dart';
import 'package:technical_support_artphoto/features/technics/presentation/page/technic_add.dart';
import 'package:technical_support_artphoto/features/technics/presentation/page/technic_view.dart';

class PopupMenuHomePage extends StatefulWidget {
  const PopupMenuHomePage({super.key});

  @override
  State<PopupMenuHomePage> createState() => _PopupMenuHomePageState();
}

class _PopupMenuHomePageState extends State<PopupMenuHomePage> {
  final _numberTechnic = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: Icon(Icons.search),
        itemBuilder: (context) => [
              PopupMenuItem(
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (_){
                          return AlertDialog(
                            title: Column(
                              spacing: 10,
                              children: [
                                TextFormField(
                                  autofocus: true,
                                  decoration: myDecorationTextFormField('Выберите статус техники'),
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
                                          // TechnicalSupportRepoImpl.downloadData.getTechnic(_numberTechnic.text).then((technic){
                                          //   if(technic != null){
                                          //     _navigationOnTechnicView(technic);
                                          //   }else{
                                          //     _viewSnackBar(Icons.delete_forever, false, '', 'Техника не найдена');
                                          //   }
                                          // });
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
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                  child: Ink(
                    decoration: BoxDecoration(
                        gradient: gradientArtphoto(),
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: EdgeInsets.only(left: 15, top: 3, bottom: 3),
                      child: const Row(
                        spacing: 5,
                        children: [
                          Icon(Icons.query_stats),
                          Expanded(
                            child: Text(
                              overflow: TextOverflow.ellipsis,
                              'Техника по статусу',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              PopupMenuItem(
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (_){
                          return AlertDialog(
                            title: Column(
                              spacing: 10,
                              children: [
                                TextFormField(
                                  autofocus: true,
                                  decoration: myDecorationTextFormField('Введите название техники'),
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
                                          // TechnicalSupportRepoImpl.downloadData.getTechnic(_numberTechnic.text).then((technic){
                                          //   if(technic != null){
                                          //     _navigationOnTechnicView(technic);
                                          //   }else{
                                          //     _viewSnackBar(Icons.delete_forever, false, '', 'Техника не найдена');
                                          //   }
                                          // });
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
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                  child: Ink(
                    decoration: BoxDecoration(
                        gradient: gradientArtphoto(),
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: EdgeInsets.only(left: 15, top: 3, bottom: 3),
                      child: const Row(
                        spacing: 5,
                        children: [
                          Icon(Icons.text_fields),
                          Expanded(
                            child: Text(
                              overflow: TextOverflow.ellipsis,
                              'Техника по названию',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          PopupMenuItem(
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (_){
                        return AlertDialog(
                          title: Column(
                            spacing: 10,
                            children: [
                              TextFormField(
                                autofocus: true,
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
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                child: Ink(
                  decoration: BoxDecoration(
                      gradient: gradientArtphoto(),
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: EdgeInsets.only(left: 15, top: 3, bottom: 3),
                    child: const Row(
                      spacing: 5,
                      children: [
                        Icon(Icons.format_list_numbered),
                        Expanded(
                          child: Text(
                            overflow: TextOverflow.ellipsis,
                            'Техника по номеру',
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ),
            ]);
  }

  void _navigationOnTechnicView(Technic technic) {
    Navigator.push(
        context,
        animationRouteSlideTransition(
            LoadingOverlay(child: TechnicView(location: technic.dislocation, technic: technic))));
  }

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
