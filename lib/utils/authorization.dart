import 'package:flutter/material.dart';
import 'package:technical_support_artphoto/utils/utils.dart';

import '../main.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formkey = GlobalKey<FormState>();
  final myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: Center(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: Image.asset('assets/logo.PNG'),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Form(
                    key: _formkey,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: TextFormField(
                              controller: myController,
                              validator: (value) {
                                if (!LoginPassword.loginPassword.containsKey(value)) {
                                  return 'Пользователь не найден';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: 'Введите пароль',
                                labelText: 'Пароль',
                                prefixIcon: Icon(
                                  Icons.key,
                                  color: Colors.green,
                                ),
                                errorStyle: TextStyle(fontSize: 18.0),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.red),
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(9.0))),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(28.0),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formkey.currentState!.validate()) {
                                    print(myController.text);
                                    LoginPassword.login = LoginPassword.loginPassword[myController.text]!;
                                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                                        builder: (_) => const ArtphotoTech()));
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
                        ]),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}