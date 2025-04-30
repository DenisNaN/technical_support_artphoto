import 'dart:math';

import 'package:flutter/material.dart';

class TechnicImage extends StatelessWidget {
  const TechnicImage({super.key, required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      category == 'Телевизор' ? Image.asset(_screenImage()) : SizedBox(),
      Image.asset(_switchIconTechnic(category))
    ]);
  }

  String _switchIconTechnic(String category) {
    switch (category) {
      case 'Принтер':
        return 'assets/icons_gridview_technical/printer.png';
      case 'Копир':
        return 'assets/icons_gridview_technical/copier.png';
      case 'Фотоаппарат':
        return 'assets/icons_gridview_technical/camera.png';
      case 'Вспышка':
        return 'assets/icons_gridview_technical/flash.png';
      case 'Ламинатор':
        return 'assets/icons_gridview_technical/laminator.png';
      case 'Сканер':
        return 'assets/icons_gridview_technical/scanner.png';
      case 'Телевизор':
        return 'assets/icons_gridview_technical/television.png';
      default:
        return '';
    }
  }

  String _screenImage() {
    return category == 'Телевизор' ? _randomScreenForTV() : '';
  }

  String _randomScreenForTV() {
    return 'assets/icons_gridview_technical/screens_tv/screentv-${Random().nextInt(33) + 1}.png';
  }
}
