import 'package:flutter/material.dart';
import 'package:technical_support_artphoto/core/shared/custom_app_bar/custom_app_bar.dart';
import 'package:technical_support_artphoto/core/shared/input_decoration/input_deroration.dart';
import 'package:technical_support_artphoto/core/utils/enums.dart';

import '../../../../core/utils/formatters.dart';

class BuySupplies extends StatefulWidget {
  const BuySupplies({super.key, required this.nameSupplies});

  final String nameSupplies;

  @override
  State<BuySupplies> createState() => _BuySuppliesState();
}

class _BuySuppliesState extends State<BuySupplies> {
  final _countSupplies = TextEditingController();
  bool isLabelCount = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(typePage: TypePage.buySupplies, location: widget.nameSupplies, technic: null),
      body: Column(children: [
        SizedBox(height: 30,),
        Center(child:
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 100.0),
          child: TextFormField(
            decoration: myDecorationTextFormField(isLabelCount ? 'Введите количество' : 'Количество'),
            controller: _countSupplies,
            inputFormatters: [numberFormatter],
            keyboardType: TextInputType.number,
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
        SizedBox(height: 20,),
        ElevatedButton(
            onPressed: () {
              if (_countSupplies.text != '') {
                print(_countSupplies.text + '11');
              }
                // _save(technic, providerModel).then((_) {
                //   _viewSnackBar(Icons.save, true, 'Техника сохранена', 'Техника не сохранена');
                // });
            },
            child: const Text("Сохранить")),
      ],),
    );
  }
}
