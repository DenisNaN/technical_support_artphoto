import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/core/api/data/repositories/technical_support_repo_impl.dart';
import 'package:technical_support_artphoto/core/api/provider/provider_model.dart';
import 'package:technical_support_artphoto/core/navigation/animation_navigation.dart';
import 'package:technical_support_artphoto/core/shared/is_fields_filled.dart';
import 'package:technical_support_artphoto/core/shared/loader_overlay/loading_overlay.dart';
import 'package:technical_support_artphoto/features/home/presentation/widgets/my_custom_refresh_indicator.dart';
import 'package:technical_support_artphoto/features/troubles/models/trouble.dart';
import 'package:technical_support_artphoto/features/troubles/presentarion/page/trouble_add.dart';
import 'package:technical_support_artphoto/features/troubles/presentarion/page/trouble_view.dart';
import 'package:technical_support_artphoto/features/troubles/presentarion/widget/menu_troubles_page.dart';

import '../../../../core/shared/custom_app_bar/custom_app_bar.dart';
import '../../../../core/shared/logo_animate/logo_matrix_transition_animate.dart';
import '../../../../core/utils/enums.dart';

class TroublesPage extends StatefulWidget {
  const TroublesPage({super.key, required this.isCurrentTroubles});

  final bool isCurrentTroubles;

  @override
  State<TroublesPage> createState() => _TroublesPageState();
}

class _TroublesPageState extends State<TroublesPage> {
  final _controller = IndicatorController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.isCurrentTroubles ? AppBar(
        title: Text('Неисправности'),
        actions: [
          MenuTroublesPage()
        ],
      ) : AppBar(
        title: Text('Завершенные неисправности'),
      ),
      floatingActionButton: widget.isCurrentTroubles
          ? FloatingActionButton.extended(
              icon: Icon(Icons.add),
              label: Text('Новая проблема'),
              onPressed: () {
                Navigator.push(context, animationRouteSlideTransition(const LoadingOverlay(child: TroubleAdd())));
              },
            )
          : null,
      body: widget.isCurrentTroubles ? _buildBodyCurrentTroubles() : _buildBodyFinishedTroubles(),
    );
  }

  Widget _buildBodyCurrentTroubles() {
    final providerModel = Provider.of<ProviderModel>(context);
    final List<Trouble> troubles = providerModel.getTroubles;
    return SafeArea(
        child: WarpIndicator(
            controller: _controller,
            onRefresh: () => TechnicalSupportRepoImpl.downloadData.getTroubles().then((resultData) {
                  providerModel.refreshTroubles(resultData);
                }),
            child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: troubles.length,
                itemBuilder: (context, index) {
                  bool isDoneTrouble = isFieldEmployeeFilledTrouble(troubles[index]);
                  Trouble trouble = troubles[index];
                  return Container(
                    margin: const EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 8),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 0.5),
                        borderRadius: BorderRadius.circular(10),
                        color: isDoneTrouble ? Colors.lightGreenAccent : Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            blurRadius: 4,
                            offset: Offset(2, 4), // Shadow position
                          ),
                        ]),
                    child: ListTile(
                        onTap: () {
                          Navigator.push(context,
                              animationRouteSlideTransition(LoadingOverlay(child: TroubleView(troubleMain: trouble))));
                        },
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        title: _buildTitleListTile(context, index, troubles)),
                  );
                })));
  }

  Widget _buildBodyFinishedTroubles() {
    return FutureBuilder(
        future: TechnicalSupportRepoImpl.downloadData.getFinishedTroubles(),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            final List<Trouble> troubles = snapshot.data;
            troubles.sort();
            return SafeArea(
                child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: troubles.length,
                    itemBuilder: (context, index) {
                      bool isDoneTrouble = isFieldEmployeeFilledTrouble(troubles[index]);
                      Trouble trouble = troubles[index];
                      return Container(
                        margin: const EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 8),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 0.5),
                            borderRadius: BorderRadius.circular(10),
                            color: isDoneTrouble ? Colors.lightGreenAccent : Colors.white,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 4,
                                offset: Offset(2, 4), // Shadow position
                              ),
                            ]),
                        child: ListTile(
                            onTap: () {
                              Navigator.push(context,
                                  animationRouteSlideTransition(LoadingOverlay(child: TroubleView(troubleMain: trouble))));
                            },
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                            title: _buildTitleListTile(context, index, troubles)),
                      );
                    }));
          } else if (snapshot.hasError) {
            return Scaffold(
                appBar: CustomAppBar(typePage: TypePage.error, location: 'Произошел сбой', technic: null),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.wifi_off,
                        size: 150,
                        color: Colors.blue,
                        shadows: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.5),
                            spreadRadius: 3,
                            blurRadius: 4,
                            offset: Offset(0, 4), // changes position of shadow
                          ),
                        ],
                      ),
                      Text(
                        'Данные не загрузились.\nПроверьте подключение к сети',
                        style: TextStyle(fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ));
          } else {
            return Center(child: SizedBox(width: 200, child: MatrixTransitionLogo()));
          }
        });
  }

  Row _buildTitleListTile(BuildContext context, int index, List<Trouble> troubles) {
    bool checkboxValueEngineer;
    bool checkboxValueEmployee;

    troubles[index].fixTroubleEngineer.toString() != '' ? checkboxValueEngineer = true : checkboxValueEngineer = false;
    troubles[index].fixTroubleEmployee.toString() != '' ? checkboxValueEmployee = true : checkboxValueEmployee = false;

    return Row(
      children: [
        Expanded(
            child: Text.rich(TextSpan(
          children: [
            TextSpan(
                style: const TextStyle(fontWeight: FontWeight.bold),
                text: troubles[index].numberTechnic != 0 ? '№ ${troubles[index].numberTechnic} ' : 'БН '),
            TextSpan(
                style: const TextStyle(fontWeight: FontWeight.bold),
                text: '${troubles[index].photosalon} '),
            TextSpan(text: '${troubles[index].employee}\n'),
            TextSpan(
                style: const TextStyle(fontStyle: FontStyle.italic),
                text: '${DateFormat('d MMMM yyyy', "ru_RU").format(troubles[index].dateTrouble)}\n'),
            TextSpan(style: TextStyle(fontWeight: FontWeight.bold), text: 'Проблема: '),
            TextSpan(text: troubles[index].trouble, children: [
              WidgetSpan(
                  child: Row(children: [
                const Text('Фото: '),
                troubles[index].photoTrouble != null &&
                    troubles[index].photoTrouble!.isNotEmpty ?
                Icon(Icons.check_circle, color: Colors.green,) :
                Icon(Icons.close, color: Colors.red, )
              ]))
            ])
          ],
        ))),
        Column(
          children: [
            Row(children: [
              SizedBox(height: 30, child: Checkbox(value: checkboxValueEmployee, onChanged: (value) {})),
              const Text('Ф')
            ]),
            Row(children: [
              SizedBox(width: 48, height: 30, child: Checkbox(value: checkboxValueEngineer, onChanged: (value) {})),
              const Text('И')
            ])
          ],
        )
      ],
    );
  }
}
