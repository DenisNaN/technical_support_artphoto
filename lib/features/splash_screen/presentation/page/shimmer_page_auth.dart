import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:technical_support_artphoto/core/shared/gradients.dart';
import 'package:technical_support_artphoto/core/shared/logo_animate/draggable_logo.dart';
import 'package:technical_support_artphoto/core/utils/utils.dart' as utils;
import 'package:technical_support_artphoto/features/splash_screen/widgets/placeholders.dart';

class ShimmerPageAuth extends StatefulWidget {
  const ShimmerPageAuth({super.key});

  @override
  State<ShimmerPageAuth> createState() => _ShimmerPageAuthState();
}

class _ShimmerPageAuthState extends State<ShimmerPageAuth> {
  @override
  Widget build(BuildContext context) {
    String? version = utils.packageInfo?.version;

    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple], begin: Alignment.topRight, end: Alignment.bottomLeft)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(gradient: gradientArtphoto()),
          ),
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
                    height: 200,
                    child: DraggableLogo(
                      child1: Image.asset('assets/logo/girl/girl2.png'),
                      child2: Image.asset(
                        'assets/logo/logo.png',
                        height: 200,
                        width: 200,
                      ),
                      child3: Image.asset('assets/logo/girl/girl1.png'),
                    )),
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
                          padding: EdgeInsets.only(left: 10, right: 10, top: 30, bottom: 10),
                          child: Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              enabled: true,
                              child: ContainerPlaceholder(width: double.infinity, height: 58))
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Row(
                            children: [
                              Checkbox(
                                  side: BorderSide(color: Colors.blue, width: 1),
                                  splashRadius: 10,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  value: false,
                                  onChanged: (bool? value) {}),
                              Text('Сохранить пароль'),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(28),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: null,
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
}
