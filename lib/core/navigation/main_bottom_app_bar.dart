import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/core/api/provider/provider_model.dart';

class MainBottomAppBar extends StatefulWidget {
  const MainBottomAppBar({super.key});

  @override
  State<MainBottomAppBar> createState() => _MainBottomAppBarState();
}

class _MainBottomAppBarState extends State<MainBottomAppBar> {
  @override
  Widget build(BuildContext context) {
    final providerModel = Provider.of<ProviderModel>(context);

    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [Colors.lightBlueAccent, Colors.purpleAccent],
          stops: [0.0, 0.8],
          tileMode: TileMode.clamp,
        ),
      ),
      child: NavigationBarTheme(
        data:  NavigationBarThemeData(
            labelTextStyle: WidgetStateProperty.all(
              const TextStyle(
                fontSize: 15.0,
                color: Colors.white,
              ),
            )),
        child: NavigationBar(
          backgroundColor: Colors.transparent,
          onDestinationSelected: (int index) {
            setState(() {
              providerModel.changeCurrentPageMainBottomAppBar(index);
            });
          },
          indicatorColor: Colors.white,
          selectedIndex: providerModel.currentPageIndexMainBottomAppBar,
          destinations: <Widget>[
            NavigationDestination(
              selectedIcon: Icon(Icons.home, color: Colors.blueAccent),
              icon: Icon(Icons.home_outlined, color: Colors.white,),
              label: 'Главная',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.settings, color: Colors.deepPurple.shade400,),
              icon: Icon(Icons.settings_outlined, color: Colors.white,),
              label: 'Ремонт',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.assignment_turned_in, color: Colors.purple.shade300),
              icon: Icon(Icons.assignment_turned_in_outlined, color: Colors.white,),
              label: 'Неисп-ти',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.history, color: Colors.purpleAccent),
              icon: Icon(Icons.history_outlined, color: Colors.white,),
              label: 'История',
            ),
          ],
        ),
      ),
    );
  }
}
