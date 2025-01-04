import 'package:flutter/material.dart';

Route createRouteScaleTransition(Widget page) {
  return PageRouteBuilder(
    transitionDuration: const Duration(seconds: 1),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.fastOutSlowIn,
          ),
        ),
        child: child,
      );
    },
  );
}

Route createRouteSlideTransition(Widget page) {
  return PageRouteBuilder(
    transitionDuration: Duration(milliseconds: 1500),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.easeInOutCubic;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

Route createRouteScalePositionTransition(Widget page, Size biggest) {
  const double smallLogo = 100;
  const double bigLogo = 200;
  return PageRouteBuilder(
    transitionDuration: const Duration(seconds: 1),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.fastOutSlowIn,
          ),
        ),
        child: PositionedTransition(
          rect: RelativeRectTween(
            begin: RelativeRect.fromSize(
              const Rect.fromLTWH(0, 0, smallLogo, smallLogo),
              biggest,
            ),
            end: RelativeRect.fromSize(
              Rect.fromLTWH(biggest.width - bigLogo,
                  biggest.height - bigLogo, bigLogo, bigLogo),
              biggest,
            ),
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.fastOutSlowIn,
            ),
          ),
          child: child,
        ),
      );
    },
  );
}