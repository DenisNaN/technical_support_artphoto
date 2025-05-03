import 'dart:math';
import 'package:flutter/material.dart';

class MatrixTransitionLogo extends StatefulWidget {
  const MatrixTransitionLogo({super.key});

  @override
  State<MatrixTransitionLogo> createState() =>
      _MatrixTransitionLogoState();
}

class _MatrixTransitionLogoState extends State<MatrixTransitionLogo>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: MatrixTransition(
          animation: _animation,
          child: Image.asset('assets/logo/logo.png'),
          onTransform: (double value) {
            return Matrix4.identity()
              ..setEntry(3, 2, 0.004)
              ..rotateY(pi * 2.0 * value);
          },
        ),
      ),
    );
  }
}