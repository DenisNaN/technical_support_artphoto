import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/core/api/data/repositories/technical_support_repo_impl.dart';
import 'package:technical_support_artphoto/core/api/provider/provider_model.dart';
import 'package:technical_support_artphoto/core/navigation/animation_navigation.dart';
import 'package:technical_support_artphoto/core/shared/gradients.dart';
import 'package:technical_support_artphoto/core/shared/input_decoration/input_deroration.dart';
import 'package:technical_support_artphoto/core/shared/loader_overlay/loading_overlay.dart';
import 'package:technical_support_artphoto/core/utils/enums.dart';
import 'package:technical_support_artphoto/core/utils/formatters.dart';
import 'package:technical_support_artphoto/features/search_technics/presentation/page/grid_view_search_technics.dart';
import 'package:technical_support_artphoto/features/technics/models/technic.dart';
import 'package:technical_support_artphoto/features/technics/presentation/page/technic_view.dart';

class PopupMenuHomePage extends StatefulWidget {
  const PopupMenuHomePage({super.key});

  @override
  State<PopupMenuHomePage> createState() => _PopupMenuHomePageState();
}

class _PopupMenuHomePageState extends State<PopupMenuHomePage> {
  final _numberTechnic = TextEditingController();
  final _nameTechnic = TextEditingController();
  String? _selectedDropdownStatus;
  String? _selectedDropdownCategory;

  @override
  Widget build(BuildContext context) {
    final providerModel = Provider.of<ProviderModel>(context);
    return PopupMenuButton(
      icon: Icon(Icons.search),
        itemBuilder: (context) => [
              PopupMenuItem(
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (_){
                          List<String> elementsDropdown = [];
                          elementsDropdown.addAll(providerModel.statusForEquipment);
                          elementsDropdown.remove('Списана');
                          return AlertDialog(
                            title: Column(
                              spacing: 10,
                              children: [
                                DropdownButtonFormField<String>(
                                  decoration: myDecorationDropdown(),
                                  borderRadius: BorderRadius.circular(10.0),
                                  hint: const Text('Статус техники'),
                                  validator: (value) => value == null ? "Обязательное поле" : null,
                                  dropdownColor: Colors.blue.shade50,
                                  value: _selectedDropdownStatus,
                                  items: elementsDropdown.map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (String? value) {
                                    setState(() {
                                      _selectedDropdownStatus = value;
                                    });
                                  },
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                        onPressed: (){
                                          _navigationOnSearchTechnics(TypeSearch.filterByStatus, _selectedDropdownStatus);
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
                      List<String> elementsDropdown = [];
                      elementsDropdown.addAll(providerModel.namesEquipments);
                      elementsDropdown.remove('Большой копир');
                      elementsDropdown.remove('Вспышка');
                      return AlertDialog(
                        title: Column(
                          spacing: 10,
                          children: [
                            DropdownButtonFormField<String>(
                              decoration: myDecorationDropdown(),
                              borderRadius: BorderRadius.circular(10.0),
                              hint: const Text('Категория техники'),
                              validator: (value) => value == null ? "Обязательное поле" : null,
                              dropdownColor: Colors.blue.shade50,
                              value: _selectedDropdownCategory,
                              items: elementsDropdown.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  _selectedDropdownCategory = value;
                                });
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                    onPressed: (){
                                      _navigationOnSearchTechnics(TypeSearch.filterByCategory, _selectedDropdownCategory);
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
                      Icon(Icons.category_outlined),
                      Expanded(
                        child: Text(
                          overflow: TextOverflow.ellipsis,
                          'Техника по категории',
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
                                  controller: _nameTechnic,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Обязательное поле';
                                    }
                                    return null;
                                  },
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                        onPressed: (){
                                          _navigationOnSearchTechnics(TypeSearch.searchByName, _nameTechnic.text);
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

  void _navigationOnSearchTechnics(TypeSearch typeSearch, String? value) {
      Navigator.push(
        context,
        animationRouteSlideTransition(
            LoadingOverlay(child: GridViewSearchTechnics(value, typeSearch: typeSearch,))));
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
