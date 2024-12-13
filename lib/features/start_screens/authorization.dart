import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/core/data/connect_db_my_sql.dart';
import 'package:technical_support_artphoto/core/domain/models/providerModel.dart';
import 'package:technical_support_artphoto/core/utils/draggable_logo.dart';
import 'package:technical_support_artphoto/main.dart';
import '../../core/domain/models/user.dart';
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
  bool _hideText = true;

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final providerModel = Provider.of<ProviderModel>(context);
    ColorAppBar colorAppBar = ColorAppBar();
    String? version = utils.packageInfo?.version;

    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple], begin: Alignment.topRight, end: Alignment.bottomLeft)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          flexibleSpace: colorAppBar.color(),
          title: Row(children: [
            Text('v. $version', style: const TextStyle(fontSize: 12, color: Colors.white)),
            const Expanded(
                child: Center(child: Padding(padding: EdgeInsets.only(right: 45), child: Text('Авторизация')))),
          ]),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50, bottom: 30),
                child: SizedBox(
                  width: double.infinity,
                  height: 300,
                  // child: Hero(tag: 'logo_hero', child: Image.asset('assets/logo/logo.png'))
                  child: DraggableLogo(
                      child: Hero(
                          tag: 'logo_hero',
                          child: Image.asset(
                            'assets/logo/logo.png',
                            height: 200,
                            width: 200,
                          ))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey.shade50,
                        boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black54, offset: Offset(0, 6))]),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
                          child: TextField(
                            controller: passwordController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [numberFormatter],
                            obscureText: _hideText,
                            obscuringCharacter: '*',
                            // autofocus: true,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                prefixIcon: Icon(Icons.lock),
                                suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _hideText = !_hideText;
                                      });
                                    },
                                    icon: Icon(Icons.remove_red_eye)),
                                hintText: 'Пароль'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(28.0),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () async {
                                String password = passwordController.text;

                                if (password.isNotEmpty) {
                                  User user = await ConnectDbMySQL.connDB.fetchAccessLevel(password);

                                  if (user.name != 'user') {
                                    providerModel.user[user.name] = user.access;
                                    providerModel.user.remove('user');
                                    await Navigator.of(context)
                                        .pushReplacement(MaterialPageRoute(builder: (_) => const ArtphotoTech()));
                                  } else {
                                    passwordController.clear();
                                    _showDialogNotValidationUser();
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              )),
                              child: const Text(
                                'Вход',
                                style: TextStyle(color: Colors.white, fontSize: 22),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDialogNotValidationUser() async {
    return showDialog<void>(
      context: context,
      // barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Пользователь не найден'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Введите пароль еще раз', textAlign: TextAlign.center,),
              ],
            ),
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30))),
          actions: <Widget>[
            TextButton(
              child: const Text('Закрыть'),
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
