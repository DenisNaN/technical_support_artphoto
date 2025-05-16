import 'package:flutter/material.dart';
import 'package:technical_support_artphoto/core/api/data/models/technic.dart';
import 'package:technical_support_artphoto/core/navigation/animation_navigation.dart';
import 'package:technical_support_artphoto/core/utils/enums.dart';
import 'package:technical_support_artphoto/features/technics/presentation/page/history_technic_page.dart';

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
    return AppBar(
        backgroundColor: Colors.transparent,
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
        TypePage.add => _addTechnic(),
        TypePage.view => _viewTechnic(),
        TypePage.repair => _repair(widget.location.toString()),
        TypePage.technicRepair => _repairTechnic(),
        TypePage.history => _historyTechnic(),
        TypePage.error => _error(widget.location.toString()),
      }
    );
  }

  Widget _addTechnic(){
    return const Text('Добавить новую технику', style: TextStyle(color: Colors.black));
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: Text(widget.location.name, style: Theme
              .of(context)
              .textTheme
              .titleLarge, ),
        ),
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

  _repair(String message) {
    return Text(message, style: TextStyle(color: Colors.black),);
  }
}