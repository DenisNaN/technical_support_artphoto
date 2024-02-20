import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

Directory? docsDir;
PackageInfo? packageInfo;

class LoginPassword{
  static Map<String, List> loginPassword = {};
  static String login = 'Артфото';
  static String access = '';
}

class ColorAppBar{
  Container color(){
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [Colors.lightBlueAccent, Colors.purpleAccent]),
      ),
    );
  }
}