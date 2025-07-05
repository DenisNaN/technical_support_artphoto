import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/features/technics/models/technic.dart';
import 'package:technical_support_artphoto/core/api/data/repositories/technical_support_repo_impl.dart';
import 'package:technical_support_artphoto/core/navigation/animation_navigation.dart';
import 'package:technical_support_artphoto/core/utils/enums.dart';
import 'package:technical_support_artphoto/features/technics/presentation/page/history_technic_page.dart';
import 'package:technical_support_artphoto/main.dart';

import '../../../features/repairs/models/repair.dart';
import '../../../features/troubles/models/trouble.dart';
import '../../api/data/models/location.dart';
import '../../api/provider/provider_model.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key, required this.typePage, required this.location, required this.technic});

  final TypePage typePage;
  final dynamic location;
  final Technic? technic;

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    final providerModel = Provider.of<ProviderModel>(context);
    return AppBar(
        backgroundColor: Colors.grey.shade50,
        shadowColor: Colors.transparent,
        leadingWidth: 80,
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.5),
                    spreadRadius: 2,
                    blurRadius: 3,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
                color: Colors.blue,
                borderRadius: BorderRadius.only(topRight: Radius.circular(50), bottomRight: Radius.circular(50)),
              ),
              child: Icon(Icons.arrow_back_ios, color: Colors.white, size: 30,),
            ),),
        ),
      centerTitle: true,
      title: switch(widget.typePage){
        TypePage.listTechnics => _listTechnics(),
        TypePage.addTechnic => _addTechnic(),
        TypePage.viewTechnic => _viewTechnic(),
        TypePage.repair => _repair(widget.location.toString()),
        TypePage.technicRepair => _repairTechnic(),
        TypePage.history => _historyTechnic(),
        TypePage.error => _error(widget.location.toString()),
        TypePage.addRepair => _addRepair(),
        TypePage.viewRepair => _viewRepair(providerModel),
        TypePage.addTrouble => _addTrouble(),
        TypePage.viewTrouble => _viewTrouble(providerModel),
        TypePage.searchTechnic => _searchTechnic(widget.location),
      }
    );
  }

  Widget _addTechnic(){
    return const Text('Добавить новую технику', style: TextStyle(color: Colors.black));
  }

  Widget _addRepair(){
    return const Text('Новая заявка на ремонт', style: TextStyle(color: Colors.black));
  }

  Widget _addTrouble(){
    return const Text('Новая неисправность', style: TextStyle(color: Colors.black));
  }

  Widget _viewRepair(ProviderModel providerModel){
    Repair repair = widget.location;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Заявка на ремонт', style: TextStyle(color: Colors.black)),
        providerModel.user.access == 'admin' ? IconButton(
            onPressed: () {
              showDialog(context: context,
                  builder: (_){
                    return AlertDialog(
                      title: Text('Подтвердите удаление заявки'),
                      actions: [
                        ElevatedButton(onPressed: (){
                          TechnicalSupportRepoImpl.downloadData.deleteRepair(repair.id.toString()).then((result){
                            if(result){
                              providerModel.removeRepairInCurrentRepairs(repair);
                              _viewSnackBar(Icons.delete_forever, result, 'Заявка удалена', 'Заявка не удалена', false);
                            }
                          });
                          Navigator.pushAndRemoveUntil(
                              context, animationRouteFadeTransition(const ArtphotoTech(indexPage: 1,)), (Route<dynamic> route) => false);
                        }, child: Text('Удалить')),
                        ElevatedButton(onPressed: (){
                          Navigator.of(context).pop();
                        }, child: Text('Отмена'))
                      ],
                    );
                  });
            },
            icon: Icon(Icons.delete_forever, color: Colors.red.shade600, size: 35,)) : SizedBox()
      ],
    );
  }

  Widget _viewTrouble(ProviderModel providerModel){
    Trouble trouble = widget.location;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Неисправность', style: TextStyle(color: Colors.black)),
        providerModel.user.access == 'admin' ? IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (_){
                    return AlertDialog(
                      title: Text('Подтвердите удаление неисправности'),
                      actions: [
                        ElevatedButton(onPressed: (){
                          TechnicalSupportRepoImpl.downloadData.deleteTrouble(trouble.id.toString()).then((result){
                            if(result){
                              providerModel.removeTroubleInTroubles(trouble);
                              _viewSnackBar(Icons.delete_forever, result, 'Неисправность удалена', 'Неисправность не удалена', false);
                            }
                          });
                          providerModel.changeCurrentPageMainBottomAppBar(2);
                          Navigator.pushAndRemoveUntil(
                              context,
                              animationRouteSlideTransition(const ArtphotoTech(
                                indexPage: 2,
                              )),
                                  (Route<dynamic> route) => false);
                        }, child: Text('Удалить')),
                        ElevatedButton(onPressed: (){
                          Navigator.of(context).pop();
                        }, child: Text('Отмена'))
                      ],
                    );
                  });
            },
            icon: Icon(Icons.delete_forever, color: Colors.red.shade600, size: 35,)) : SizedBox()
      ],
    );
  }

  Widget _listTechnics(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(widget.location.name, style: Theme
              .of(context)
              .textTheme
              .titleLarge, ),
        ),
        Text(
          'Кол-во: ${widget.location.technics.length}',
          style: Theme
              .of(context)
              .textTheme
              .titleMedium,
        ),
      ],
    );
  }

  Widget _repairTechnic() {
    return Text(widget.technic?.name ?? 'Нет имени', style: Theme
        .of(context)
        .textTheme
        .titleLarge,);
  }

  Widget _historyTechnic(){
    return const Text('Итория техники', style: TextStyle(color: Colors.black));
  }

  Widget _viewTechnic(){
    String locationName = '';
    if(widget.location is Location){
      locationName = widget.location.name;
    }else{
      locationName = widget.location;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: Text(locationName, style: Theme
              .of(context)
              .textTheme
              .titleLarge, ),
        ),
        widget.technic?.number == 0 ? SizedBox() :
        TextButton(
          onPressed: (){
            Navigator.push(
                context, animationRouteSlideTransition(HistoryTechnicPage(numberTechnic: widget.technic?.number.toString())));
          }, child: Text('История'),
        ),
      ],
    );
  }

  Widget _error(String message) {
    return Text(message, style: TextStyle(color: Colors.black),);
  }

  Widget _searchTechnic(String nameSearching){
    return Text('Поиск по: $nameSearching', style: TextStyle(color: Colors.black));
  }

  _repair(String message) {
    return Text(message, style: TextStyle(color: Colors.black),);
  }

  void _viewSnackBar(IconData icon, bool isSuccessful, String successfulText, String notSuccessfulText, bool isSkipPrevSnackBar) {
    if (mounted) {
      if(isSkipPrevSnackBar){
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(icon, size: 40, color: isSuccessful ? Colors.green : Colors.red),
              SizedBox(
                width: 20,
              ),
              Flexible(child: Text(isSuccessful ? successfulText : notSuccessfulText)),
            ],
          ),
          duration: const Duration(seconds: 5),
          showCloseIcon: true,
        ),
      );
    }
  }
}