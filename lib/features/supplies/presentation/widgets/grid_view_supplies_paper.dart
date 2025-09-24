import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/core/api/provider/provider_model.dart';
import 'package:technical_support_artphoto/core/navigation/animation_navigation.dart';
import 'package:technical_support_artphoto/core/shared/loader_overlay/loading_overlay.dart';
import 'package:technical_support_artphoto/features/supplies/models/supplies_entity.dart';
import 'package:technical_support_artphoto/features/supplies/presentation/pages/buy_supplies.dart';
import '../../models/model_supplies.dart';

class GridViewSuppliesPaper extends StatelessWidget {
  final Color color;
  final bool isPaint;

  const GridViewSuppliesPaper({super.key, required this.color, required this.isPaint});

  @override
  Widget build(BuildContext context) {
    final providerModel = Provider.of<ProviderModel>(context);

    List<SuppliesEntity> actualSuppliesGarage = [];
    List<SuppliesEntity> actualSuppliesOffice = [];

    if(isPaint){
      for(int i = 10; i < providerModel.getSuppliesGarage.suppliesEntity.length ; i++){
        actualSuppliesGarage.add(providerModel.getSuppliesGarage.suppliesEntity[i]);
        actualSuppliesOffice.add(providerModel.getSuppliesOffice.suppliesEntity[i]);
      }
    }else{
      for(int i = 0; i < providerModel.getSuppliesGarage.suppliesEntity.length - 6; i++){
        actualSuppliesGarage.add(providerModel.getSuppliesGarage.suppliesEntity[i]);
        actualSuppliesOffice.add(providerModel.getSuppliesOffice.suppliesEntity[i]);
      }
    }
    int totalCountSupplies = actualSuppliesGarage.length;

    return SliverPadding(
      padding: const EdgeInsets.all(14.0),
      sliver: SliverGrid.builder(
          itemCount: totalCountSupplies,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (BuildContext context, int index) {
            SuppliesEntity suppliesEntityGarage = actualSuppliesGarage[index];
            SuppliesEntity suppliesEntityOffice = actualSuppliesOffice[index];
            int countAll = suppliesEntityGarage.count + suppliesEntityOffice.count;
            return GestureDetector(
              onTap: (){
                showDialog(
                    context: context,
                    builder: (_){
                  return AlertDialog(
                    title: Text('Что делать?'),
                    titleTextStyle: Theme.of(context).textTheme.headlineMedium,
                    actions: [
                      Center(child:
                        ElevatedButton(onPressed: (){
                          Navigator.pop(context);
                          Navigator.push(context,
                              animationRouteSlideTransition(LoadingOverlay(child:
                              BuySupplies(nameSupplies: suppliesEntityGarage.name))));
                        },
                            child: Text('     Покупка     ')),),
                      SizedBox(height: 10,),
                      // Center(child:
                      // ElevatedButton(onPressed: (){
                      //   Navigator.pop(context);
                      //   Navigator.push(context,
                      //       animationRouteSlideTransition(LoadingOverlay(child: BuySupplies(nameSupplies: suppliesEntityGarage.name))));
                      // },
                      //     child: Text('Перемещение')),),
                      // SizedBox(height: 10,),
                    ],
                  );
                });
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade500,
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: Offset(0, 2), // changes position of shadow
                      ),
                    ],),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3.0),
                        child: Text(suppliesEntityOffice.name, style: TextStyle(fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),),
                      ),
                      Column(children: [
                        Text('Итого: $countAll'),
                        Row(
                          children: [
                            Expanded(
                                child: Container(color: Colors.red.shade200, child: Center(child: Text('${suppliesEntityGarage.count}')))),
                            SizedBox(height: 20,
                              child: VerticalDivider(
                                width: 0, thickness: 1, color: Colors.black54,
                                indent: 2, endIndent: 2,),),
                            Expanded(child: Container(color: Colors.amberAccent.shade200, child: Center(child: Text('${suppliesEntityOffice.count}')))),
                          ],)
                      ],),
                  ],
                ),
              ),
            );
        },),
    );
  }
}
