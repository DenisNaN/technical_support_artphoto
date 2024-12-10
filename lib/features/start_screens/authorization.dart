import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/core/data/connect_db_my_sql.dart';
import 'package:technical_support_artphoto/core/domain/models/providerModel.dart';
import 'package:technical_support_artphoto/main.dart';
import '../../core/domain/models/user.dart';
import '../../core/utils/logo_matrixTransition_animate.dart';
import '../../core/utils/utils.dart';
import '../../core/utils/utils.dart' as utils;

class Authorization extends StatefulWidget {
  const Authorization({super.key});

  @override
  State<Authorization> createState() => _AuthorizationState();
}

class _AuthorizationState extends State<Authorization> {
  final passwordController = TextEditingController();
  final numberFormatter = FilteringTextInputFormatter.allow(
    RegExp(r'[0-9]'),
  );

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final providerModel = Provider.of<ProviderModel>(context);
    bool hideText = true;
    ColorAppBar colorAppBar = ColorAppBar();
    String? version = utils.packageInfo?.version;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: colorAppBar.color(),
        title: Row(children: [
          Text('v. $version', style: const TextStyle(fontSize: 12, color: Colors.white)),
          const Expanded(child:
          Center(child:
          Padding(
              padding: EdgeInsets.only(right: 45),
              child: Text('Login')))),
        ]),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.blue, Colors.purple], begin: Alignment.topRight, end: Alignment.bottomLeft)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 10.0, bottom: 0),
              child: Center(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: MatrixTransitionLogo(),
                  // child: Image.asset('assets/logo.PNG'),
                ),
              ),
            ),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                height: 200,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey.shade50,
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 16,
                        spreadRadius: 16,
                        color: Colors.black54,
                      )
                    ]),
                child: Center(
                  child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    controller: passwordController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [numberFormatter],
                    obscureText: hideText,
                    obscuringCharacter: '*',
                    decoration: InputDecoration(
                      icon: Icon(Icons.lock),
                      prefixIcon: IconButton(
                          onPressed: (){
                            setState(() {
                              hideText = !hideText;
                            });
                          },
                          icon: Icon(Icons.remove_red_eye)),
                      hintText: 'Пароль'
                    ),
                  ),
                  ),
                )),
            Padding(
              padding: const EdgeInsets.all(28.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async{
                    User user = await ConnectDbMySQL.connDB.fetchAccessLevel(passwordController.text);
                    if (user.name != 'user') {
                      providerModel.user[user.name] = user.access;
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (_) => const ArtphotoTech()));
                    }else{
                      await _showDialogNotValidationUser();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      )
                  ),
                  child: const Text(
                    'Вход',
                    style: TextStyle(
                        color: Colors.white, fontSize: 22),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDialogNotValidationUser() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Пользователь не найден'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Are you sure want to cancel booking?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
