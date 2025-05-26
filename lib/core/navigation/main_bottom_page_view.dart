import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/history/history_list.dart';
import '../../features/home/presentation/page/home_page.dart';
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
    const RepairsPage(),

    /// Troubles
    const Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Card(
            child: ListTile(
              leading: Icon(Icons.notifications_sharp),
              title: Text('Notification 1'),
              subtitle: Text('This is a notification'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.notifications_sharp),
              title: Text('Notification 2'),
              subtitle: Text('This is a notification'),
            ),
          ),
        ],
      ),
    ),

    /// History
    HistoryList(),
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
