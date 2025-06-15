import 'package:flutter/material.dart';
import 'package:technical_support_artphoto/features/troubles/presentarion/page/troubles_page.dart';
import '../../../../core/navigation/animation_navigation.dart';
import '../../../../core/shared/gradients.dart';

class MenuTroublesPage extends StatefulWidget {
  const MenuTroublesPage({super.key});

  @override
  State<MenuTroublesPage> createState() => _MenuTroublesPageState();
}

class _MenuTroublesPageState extends State<MenuTroublesPage> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      popUpAnimationStyle: AnimationStyle(
        curve: Easing.legacy,
        duration: Duration(milliseconds: 800)),
      borderRadius: BorderRadius.circular(15),
        itemBuilder: (context) => [
          PopupMenuItem(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, animationRouteFadeTransition(const TroublesPage(isCurrentTroubles: false,)));
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
                          'Завершенные неисправности',
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
