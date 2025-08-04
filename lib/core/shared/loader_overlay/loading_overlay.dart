import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:technical_support_artphoto/core/shared/logo_animate/logo_matrix_transition_animate.dart';

class LoadingOverlay extends StatefulWidget {
  const LoadingOverlay({super.key, required this.child});

  final Widget child;

  static _LoadingOverlayState of(BuildContext context) {
    return context.findAncestorStateOfType<_LoadingOverlayState>()!;
  }

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay> {
  bool _isLoading = false;

  void show() {
    setState(() {
      _isLoading = true;
    });
  }

  void hide() {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double sizeWidth = MediaQuery.sizeOf(context).width;
    return Stack(
      children: [
        widget.child,
        if (_isLoading)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
            child: const Opacity(
              opacity: 0.8,
              child: ModalBarrier(dismissible: false, color: Colors.black),
            ),
          ),
        if (_isLoading)
          Center(
            child: SizedBox(width: sizeWidth / 3, child: const MatrixTransitionLogo()),
          ),
      ],
    );
  }
}
