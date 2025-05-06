import 'package:flutter/material.dart';
import 'package:technical_support_artphoto/core/api/data/models/technic.dart';

class AppBarTechnicRepairs extends StatefulWidget implements PreferredSizeWidget {
  const AppBarTechnicRepairs({super.key, required this.technic});

  final Technic technic;

  @override
  State<AppBarTechnicRepairs> createState() => _AppBarTechnicRepairsState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _AppBarTechnicRepairsState extends State<AppBarTechnicRepairs> {
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
      title: Text(widget.technic.name, style: Theme
          .of(context)
          .textTheme
          .titleLarge, ),
      centerTitle: true,
    );
  }
}