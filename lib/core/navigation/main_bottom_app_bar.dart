import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/core/api/provider/provider_model.dart';
import 'package:technical_support_artphoto/core/shared/gradients.dart';

class MainBottomAppBar extends StatefulWidget {
  final PageController pageController;

  const MainBottomAppBar({super.key, required this.pageController});

  @override
  State<MainBottomAppBar> createState() => _MainBottomAppBarState();
}

class _MainBottomAppBarState extends State<MainBottomAppBar> {
  @override
  Widget build(BuildContext context) {
    final providerModel = Provider.of<ProviderModel>(context);

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        gradient: gradientArtphoto(),
      ),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
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
              widget.pageController
                  .animateToPage(index, duration: const Duration(milliseconds: 600), curve: Curves.ease);
            });
          },
          indicatorColor: Colors.white,
          selectedIndex: providerModel.currentPageIndexMainBottomAppBar,
          destinations: <Widget>[
            NavigationDestination(
              selectedIcon: Icon(Icons.home, color: Colors.blueAccent),
              icon: Icon(
                Icons.home_outlined,
                color: Colors.white,
              ),
              label: 'Главная',
            ),
            NavigationDestination(
              selectedIcon: Icon(
                Icons.settings,
                color: Colors.deepPurple.shade400,
              ),
              icon: Icon(
                Icons.settings_outlined,
                color: Colors.white,
              ),
              label: 'Ремонт',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.assignment_turned_in, color: Colors.purple.shade300),
              icon: Icon(
                Icons.assignment_turned_in_outlined,
                color: Colors.white,
              ),
              label: 'Неисп-ти',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.assignment_turned_in, color: Colors.purple.shade300),
              icon: Icon(
                Icons.notifications_active,
                color: Colors.white,
              ),
              label: 'Увед',
            ),
          ],
        ),
      ),
    );
  }
}
