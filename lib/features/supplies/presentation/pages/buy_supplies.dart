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
                  _save(_selectedDislocation!, int.parse(_countSupplies.text), providerModel).then((result) {
                    _viewSnackBar(Icons.save, result, 'Данные сохраннены', 'Данные не сохраннены');
                  });
                }
              },
              child: const Text("Сохранить")),
        ],),
      ),
    );
  }

  Future<bool> _save(String dislocation, int count, ProviderModel providerModel) async{
    bool result;
    LoadingOverlay.of(context).show();
    if(dislocation == 'Склад'){
      result = await TechnicalSupportRepoImpl.downloadData.saveSupplies(widget.nameSupplies, count, providerModel.getSuppliesGarage);
    }else{
      result = await TechnicalSupportRepoImpl.downloadData.saveSupplies(widget.nameSupplies, count, providerModel.getSuppliesOffice);
    }
    if(result){
      TechnicalSupportRepoImpl.downloadData.refreshSuppliesData().then((resultData) {
        providerModel.refreshSupplies(resultData);
      });
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
      String notSuccessText) {
    if(mounted){
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
      Navigator.pushAndRemoveUntil(
          context, animationRouteSlideTransition(const ArtphotoTech(indexPage: 4,)), (Route<dynamic> route) => false);
    }
  }
}
