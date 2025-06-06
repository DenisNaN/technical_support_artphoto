import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/features/technics/presentation/page/technic_add.dart';

import '../../../../core/api/provider/provider_model.dart';

class MenuRepairPage extends StatefulWidget {
  const MenuRepairPage({super.key});

  @override
  State<MenuRepairPage> createState() => _MenuRepairPageState();
}

class _MenuRepairPageState extends State<MenuRepairPage> {
  @override
  Widget build(BuildContext context) {
    final providerModel = Provider.of<ProviderModel>(context);
    return PopupMenuButton(
      popUpAnimationStyle: AnimationStyle(
        curve: Easing.legacy,
        duration: Duration(milliseconds: 800)),
      borderRadius: BorderRadius.circular(15),
        itemBuilder: (context) => [
          PopupMenuItem(
            child: ElevatedButton(
              onPressed: () {
                bool isChange = providerModel.setChangeRedAndYellow();
                providerModel.sortListRepairs(providerModel.getAllRepairs, isChange);
                providerModel.manualNotifyListeners();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              child: Ink(
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      colors: [Colors.lightBlueAccent, Colors.purpleAccent],
                      stops: [0.0, 0.8],
                      tileMode: TileMode.clamp,
                    ),
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Row(
                    spacing: 10,
                    children: [
                      Icon(Icons.published_with_changes),
                      Text(
                        'Поменять очередность',
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ]);
  }
}