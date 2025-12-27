import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/core/api/data/models/user.dart';
import 'package:technical_support_artphoto/core/api/provider/provider_model.dart';

class AppBarShimmerHomePage extends StatefulWidget implements PreferredSizeWidget{
  const AppBarShimmerHomePage({super.key});

  @override
  State<AppBarShimmerHomePage> createState() => _AppBarShimmerHomePageState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppBarShimmerHomePageState extends State<AppBarShimmerHomePage> {
  @override
  Widget build(BuildContext context) {
    final providerModel = Provider.of<ProviderModel>(context);
    final User user = providerModel.user;

    return AppBar(
      title: Row(
        children: [
          CircleAvatar(
            backgroundImage: user.imagePath != null ? Image.file(File(user.imagePath!)).image : Image.asset('assets/avatar/anon_avatar.jpg').image,
          ),
          SizedBox(width: 10,),
          Text(
            user.name,
            style: TextStyle(color: Colors.white, fontSize: 18),
          )
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(Icons.search),
        )
      ],
    );
  }
}
