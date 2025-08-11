import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/core/api/data/repositories/technical_support_repo_impl.dart';
import 'package:technical_support_artphoto/core/api/provider/provider_model.dart';
import 'package:technical_support_artphoto/core/navigation/animation_navigation.dart';
import 'package:technical_support_artphoto/core/shared/custom_app_bar/custom_app_bar.dart';
import 'package:technical_support_artphoto/core/shared/input_decoration/input_deroration.dart';
import 'package:technical_support_artphoto/core/shared/loader_overlay/loading_overlay.dart';
import 'package:technical_support_artphoto/core/utils/enums.dart';
import 'package:technical_support_artphoto/main.dart';

import '../../../../core/utils/formatters.dart';

class BuySupplies extends StatefulWidget {
  const BuySupplies({super.key, required this.nameSupplies});

  final String nameSupplies;

  @override
  State<BuySupplies> createState() => _BuySuppliesState();
}

class _BuySuppliesState extends State<BuySupplies> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final _countSupplies = TextEditingController();
  String? _selectedDislocation;
  bool isLabelCount = true;

  @override
  Widget build(BuildContext context) {
    final providerModel = Provider.of<ProviderModel>(context);
    return Scaffold(
      appBar: CustomAppBar(typePage: TypePage.buySupplies, location: widget.nameSupplies, technic: null),
      body: Form(
        key: formKey,
        child: Column(children: [
          SizedBox(height: 30,),
          Center(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100.0),
              child: DropdownButtonFormField<String>(
                decoration: myDecorationDropdown(),
                validator: (value) => value == null ? "Обязательное поле" : null,
                dropdownColor: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10.0),
                hint: const Text('Место хранения'),
                value: _selectedDislocation,
                items: ['Склад', 'Офис'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedDislocation = value!;
                  });
                },
              ),
          ),),
          SizedBox(height: 30,),
          Center(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 100.0),
            child: TextFormField(
              decoration: myDecorationTextFormField(isLabelCount ? 'Введите количество' : 'Количество'),
              controller: _countSupplies,
              inputFormatters: [numberFormatter],
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Обязательное поле';
                }
                return null;
              },
              onChanged: (value){
                if (value != '') {
                  setState(() {
                    isLabelCount = false;
                  });
                } else{
                  setState(() {
                    isLabelCount = true;
                  });
                }
              },
            ),
          ),),
          SizedBox(height: 30,),
          ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  print(_countSupplies.text + '11');
                }
                  // _save(technic, providerModel).then((_) {
                  //   _viewSnackBar(Icons.save, true, 'Техника сохранена', 'Техника не сохранена');
                  // });
              },
              child: const Text("Сохранить")),
        ],),
      ),
    );
  }

  Future<bool> _save(String dislocation, int count, ProviderModel providerModel) async{
    LoadingOverlay.of(context).show();
    List<Repair>? resultData =
    await TechnicalSupportRepoImpl.downloadData.saveRepair(repair);
    if(resultData != null && repair.numberTechnic == 0){
      providerModel.refreshCurrentRepairs(resultData);
      if(mounted){
        LoadingOverlay.of(context).hide();
      }
      return true;
    }
    if(resultData != null && repair.numberTechnic != 0){
      Technic? technic =
      await TechnicalSupportRepoImpl.downloadData.getTechnic(repair.numberTechnic.toString());
      if (technic != null) {
        if(technic.status == 'Тест-драйв'){
          if (technic.testDrive != null) {
            TestDrive testDrive = TestDrive(
                id: technic.testDrive!.id!,
                idTechnic: technic.id,
                categoryTechnic: technic.category,
                dislocationTechnic: technic.dislocation,
                dateStart: technic.testDrive!.dateStart,
                dateFinish: DateTime.now(),
                result: 'Увезли в ремонт',
                isCloseTestDrive: true,
                user: providerModel.user.name);
            await TechnicalSupportRepoImpl.downloadData.updateTestDrive(testDrive);
          }
        }
        technic.status = repair.status;
        if(technic.status == 'Транспортировка'){
          technic.dislocation = providerModel.user.name;
        }
        if(technic.status == 'В ремонте'){
          technic.dislocation = _selectedDropdownDislocationService!;
        }
        await TechnicalSupportRepoImpl.downloadData.updateStatusAndDislocationTechnic(technic, providerModel.user.name);
        Map<String, dynamic> technics = await TechnicalSupportRepoImpl.downloadData.refreshTechnicsData();
        providerModel.refreshTechnics(
            technics['Photosalons'], technics['Repairs'], technics['Storages'], technics['Transportation']);
      }
      providerModel.refreshCurrentRepairs(resultData);
      // await addHistory(technic, nameUser);
      if(mounted){
        LoadingOverlay.of(context).hide();
      }
      return true;
    }
    if(mounted){
      LoadingOverlay.of(context).hide();
    }
    return false;
  }

  void _viewSnackBar(IconData icon, bool isSuccessful, String successText,
      String notSuccessText, GlobalKey<ScaffoldState> scaffoldKey) {
    final contextViewSnackBar = scaffoldKey.currentContext;
    if(contextViewSnackBar != null && contextViewSnackBar.mounted){
      ScaffoldMessenger.of(contextViewSnackBar).hideCurrentSnackBar();
      ScaffoldMessenger.of(contextViewSnackBar).showSnackBar(
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
      Navigator.pushAndRemoveUntil(
          context, animationRouteSlideTransition(const ArtphotoTech(indexPage: 4,)), (Route<dynamic> route) => false);
    }
  }
}
