import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/history/history_list.dart';
import '../../features/home/presentation/page/home_page.dart';
import '../../features/repairs/presentation/page/repairs_page.dart';
import '../api/provider/provider_model.dart';

class MainBottomBodyFlipAnimation extends StatefulWidget {
  const MainBottomBodyFlipAnimation({super.key});

  @override
  State<MainBottomBodyFlipAnimation> createState() => _MainBottomBodyFlipAnimationState();
}

class _MainBottomBodyFlipAnimationState extends State<MainBottomBodyFlipAnimation> {
  late bool _flipXAxis;
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
  void initState() {
    super.initState();
    _flipXAxis = true;
  }

  @override
  Widget build(BuildContext context) {
    final providerModel = Provider.of<ProviderModel>(context);
    String? swipeDirection;
    return GestureDetector(
      onPanUpdate: (details) {
        swipeDirection = details.delta.dx < 0 ? 'left' : 'right';
      },
      onPanEnd: (details) {
        if (swipeDirection == null) {
          return;
        }
        if (swipeDirection == 'left') {
          providerModel.changeLeftSwipeValue(true);
          if (providerModel.currentPageIndexMainBottomAppBar < 3) {
            providerModel.changeCurrentPageMainBottomAppBar(providerModel.currentPageIndexMainBottomAppBar + 1);
          }
        }
        if (swipeDirection == 'right') {
            providerModel.changeLeftSwipeValue(false);
          if (providerModel.currentPageIndexMainBottomAppBar > 0) {
            providerModel.changeCurrentPageMainBottomAppBar(providerModel.currentPageIndexMainBottomAppBar - 1);
          }
        }
      },
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 800),
        transitionBuilder: _transitionBuilder,
        layoutBuilder: (widget, list) => Stack(children: [widget!, ...list]),
        switchInCurve: Curves.ease,
        switchOutCurve: Curves.ease.flipped,
        child: pages[providerModel.currentPageIndexMainBottomAppBar],
      ),
    );
  }

  Widget _transitionBuilder(Widget widget, Animation<double> animation) {
    final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
    return AnimatedBuilder(
      animation: rotateAnim,
      child: widget,
      builder: (context, widget) {
        final isUnder = (ValueKey(Provider.of<ProviderModel>(context).leftSwipeValue) != widget!.key);
        var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
        tilt *= Provider.of<ProviderModel>(context).leftSwipeValue ? 1.0 : -1.0;
        final value = isUnder ? min(rotateAnim.value, pi / 2) : rotateAnim.value;
        return Transform(
          transform: _flipXAxis
              ? (Matrix4.rotationY(value)..setEntry(3, 0, tilt))
              : (Matrix4.rotationX(value)..setEntry(3, 1, tilt)),
          alignment: Alignment.center,
          child: widget,
        );
      },
    );
  }
}
