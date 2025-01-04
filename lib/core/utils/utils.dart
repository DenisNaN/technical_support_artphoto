import 'dart:io';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

Directory? docsDir;
PackageInfo? packageInfo;

class MyColor{
  Container appBar(){
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [Colors.lightBlueAccent, Colors.purpleAccent]),
      ),
    );
  }

  LinearGradient getMyGradient(){
    return LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [Colors.lightBlueAccent, Colors.purpleAccent]);
  }
}

