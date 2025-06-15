import 'package:flutter/material.dart';
import 'package:technical_support_artphoto/core/shared/gradients.dart';
import 'package:technical_support_artphoto/features/technics/presentation/page/technic_add.dart';

class MenuHomePage extends StatefulWidget {
  const MenuHomePage({super.key});

  @override
  State<MenuHomePage> createState() => _MenuHomePageState();
}

class _MenuHomePageState extends State<MenuHomePage> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
        itemBuilder: (context) => [
              PopupMenuItem(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const TechnicAdd()));
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
                      padding: EdgeInsets.only(left: 15, top: 3, bottom: 3),
                      child: const Row(
                        children: [
                          Icon(Icons.add),
                          Text(
                            'Добавить технику',
                            style: TextStyle(fontSize: 15),
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
                    debugPrint('Hi there');
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
                      padding: EdgeInsets.only(left: 15, top: 3, bottom: 3),
                      child: const Row(
                        children: [
                          Icon(Icons.check),
                          Text(
                            'Проверить технику',
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
