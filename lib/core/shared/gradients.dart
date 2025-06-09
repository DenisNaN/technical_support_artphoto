import 'package:flutter/material.dart';

LinearGradient gradientArtphoto() {
  return LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [Colors.lightBlueAccent, Colors.purpleAccent],
    stops: [0.0, 0.8],
    tileMode: TileMode.clamp,
  );
}

LinearGradient gradientGreenAccentGreen() {
  return LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [Colors.greenAccent, Colors.lightGreenAccent],
    stops: [0.0, 0.8],
    tileMode: TileMode.clamp,
  );
}