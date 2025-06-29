import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/api/provider/provider_model.dart';
import '../../../../core/navigation/animation_navigation.dart';
import '../../../../core/shared/gradients.dart';
import '../page/repairs_page.dart';

class PopupMenuRepairPage extends StatefulWidget {
  const PopupMenuRepairPage({super.key});

  @override
  State<PopupMenuRepairPage> createState() => _PopupMenuRepairPageState();
}

class _PopupMenuRepairPageState extends State<PopupMenuRepairPage> {
  @override
  Widget build(BuildContext context) {
    final providerModel = Provider.of<ProviderModel>(context);
    return PopupMenuButton(
      borderRadius: BorderRadius.circular(15),
        itemBuilder: (context) => [
          PopupMenuItem(
            child: ElevatedButton(
              onPressed: () {
                bool isChange = providerModel.setChangeRedAndYellow();
                providerModel.sortListCurrentRepairs(providerModel.getCurrentRepairs, isChange);
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
                    gradient: gradientArtphoto(),
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Row(
                    spacing: 10,
                    children: [
                      Icon(Icons.published_with_changes),
                      Flexible(
                        child: Text(
                          'Поменять очередность',
                          style: TextStyle(fontSize: 15, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          PopupMenuItem(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, animationRouteFadeTransition(const RepairsPage(isCurrentRepairs: false,)));
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              child: Ink(
                decoration: BoxDecoration(
                    gradient: gradientGreenAccentGreen(),
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Row(
                    spacing: 10,
                    children: [
                      Icon(Icons.handyman, color: Colors.black54),
                      Flexible(
                        child: Text(
                          'Завершенные ремонты',
                          style: TextStyle(fontSize: 15, color: Colors.black54, overflow: TextOverflow.ellipsis),
                        ),
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
