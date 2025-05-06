import 'package:flutter/material.dart';
import 'package:technical_support_artphoto/core/navigation/animation_navigation.dart';
import 'package:technical_support_artphoto/features/technics/presentation/page/history_technic_page.dart';

class AppBarTechnicView extends StatefulWidget implements PreferredSizeWidget {
  const AppBarTechnicView({super.key, this.isLength = true, required this.location, required this.numberTechnic});

  final dynamic location;
  final bool isLength;
  final int? numberTechnic;

  @override
  State<AppBarTechnicView> createState() => _AppBarTechnicViewState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _AppBarTechnicViewState extends State<AppBarTechnicView> {
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
      title: Row(
        mainAxisAlignment: widget.isLength ? MainAxisAlignment.spaceBetween : MainAxisAlignment.spaceAround,
        children: [
          Text(widget.location.name, style: Theme
              .of(context)
              .textTheme
              .titleLarge, ),
          widget.isLength ? Text(
            'Кол-во: ${widget.location.technics.length}',
            style: Theme
                .of(context)
                .textTheme
                .titleMedium,
          ) : SizedBox(),
          widget.isLength ? SizedBox() :
          TextButton(
            onPressed: (){
              Navigator.push(
                  context, animationRouteSlideTransition(HistoryTechnicPage(numberTechnic: widget.numberTechnic.toString())));
            }, child: Text('История'),
          ),
        ],
      ),
    );
  }
}