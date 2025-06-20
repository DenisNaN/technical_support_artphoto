import 'package:flutter/material.dart';

Future<dynamic> dialogFailedApp(BuildContext context) async {
  return await showGeneralDialog(
      barrierLabel: "Label",
      barrierDismissible: true,
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          backgroundColor: Colors.transparent.withValues(alpha: 0.5),
          body: GestureDetector(
            onTap: (){Navigator.of(context).pop();},
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                    backgroundColor: Colors.red,
                    child: Icon(Icons.close, color: Colors.white,)),
                Text('Сорри!\nПриложение вызвало ошибку.\nТехнический сотрудник уже занимается исправлением.', textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 35, color: Colors.white, fontWeight: FontWeight.bold, shadows: [BoxShadow(
                    color: Colors.black45,
                    blurRadius: 4,
                    offset: Offset(2, 4), // Shadow position
                  ),]),),
              ],
            ),
          ),
        );
      });
}
