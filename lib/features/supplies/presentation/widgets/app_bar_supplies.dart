import 'package:flutter/material.dart';

class AppBarSupplies extends StatefulWidget implements PreferredSizeWidget{
  const AppBarSupplies({super.key});

  @override
  State<AppBarSupplies> createState() => _AppBarSuppliesState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppBarSuppliesState extends State<AppBarSupplies> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('Расходники'),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text('Склад - '),
                  Container(
                    height: 12,
                    width: 25,
                    color: Colors.red.shade200,
                  ),
                ],
              ),
              Row(
                children: [
                  Text('Офис - '),
                  Container(
                    height: 12,
                    width: 25,
                    color: Colors.amberAccent.shade200,
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
