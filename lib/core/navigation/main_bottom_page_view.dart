import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/features/troubles/presentarion/page/troubles_page.dart';
import '../../features/home/presentation/page/home_page.dart';
import '../../features/notifications/presentation/page/notifications.dart';
import '../../features/repairs/presentation/page/repairs_page.dart';
import '../api/provider/provider_model.dart';

class MainBottomPageView extends StatefulWidget {
  final PageController pageController;

  const MainBottomPageView({super.key, required this.pageController});

  @override
  State<MainBottomPageView> createState() => _MainBottomPageViewState();
}

class _MainBottomPageViewState extends State<MainBottomPageView> with TickerProviderStateMixin {
  List<Widget> pages = <Widget>[
    /// Home page
    const HomePage(),

    /// Repair
    const RepairsPage(isCurrentRepairs: true,),

    /// Troubles
    const TroublesPage(isCurrentTroubles: true),

    /// Notifications
    const Notifications(),
  ];

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: widget.pageController,
      onPageChanged: _handlePageViewChanged,
      children: pages,
    );
  }

  void _handlePageViewChanged(int currentPageIndex) {
    final providerModel = Provider.of<ProviderModel>(context, listen: false);
    providerModel.changeCurrentPageMainBottomAppBar(currentPageIndex);
  }
}
