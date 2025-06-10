import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/core/api/data/repositories/technical_support_repo_impl.dart';
import 'package:technical_support_artphoto/core/api/provider/provider_model.dart';
import 'package:technical_support_artphoto/features/home/presentation/widgets/my_custom_refresh_indicator.dart';
import 'package:technical_support_artphoto/features/troubles/models/trouble.dart';

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
      appBar: AppBar(
        title: Text('Неисправности'),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {}),
      body: _buildBodyCurrentRepairs(),
    );
  }

  Widget _buildBodyCurrentRepairs() {
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
                  bool isDoneTrouble = isFieldFilled(troubles[index]);
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
                        onTap: () {},
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        title: _buildTitleListTile(context, index, troubles)),
                  );
                })));
  }

  Row _buildTitleListTile(BuildContext context, int index, List troubleList) {
    bool checkboxValueEngineer;
    bool checkboxValueEmployee;
    bool checkboxValuePhoto = false;

    troubleList[index].dateCheckFixTroubleEngineer != '' ? checkboxValueEngineer = true : checkboxValueEngineer = false;
    troubleList[index].dateCheckFixTroubleEmployee != '' ? checkboxValueEmployee = true : checkboxValueEmployee = false;

    if (troubleList[index].photoTrouble != null) {
      troubleList[index].photoTrouble.isNotEmpty ? checkboxValuePhoto = true : checkboxValuePhoto = false;
    }
    return Row(
      children: [
        Expanded(
            child: Text.rich(TextSpan(
          children: [
            TextSpan(
                style: const TextStyle(fontWeight: FontWeight.bold),
                text: troubleList[index].internalID != 0 ? '№ ${troubleList[index].internalID} ' : 'БН '),
            TextSpan(
                style: const TextStyle(fontWeight: FontWeight.bold),
                text: '${troubleList[index].photosalon} '
                    '${troubleList[index].employee}\n'),
            TextSpan(
                style: const TextStyle(fontStyle: FontStyle.italic),
                text:
                    '${DateFormat('d MMMM yyyy', "ru_RU").format(DateTime.parse(troubleList[index].dateTrouble.replaceAll('.', '-')))}\n'),
            TextSpan(text: 'Проблема: ${troubleList[index].trouble}\n', children: [
              WidgetSpan(
                  child: Row(children: [
                const Text('Фото: '),
                SizedBox(width: 30, height: 10, child: Checkbox(value: checkboxValuePhoto, onChanged: null)),
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

  bool isFieldFilled(Trouble trouble) {
    bool result = false;
    if (trouble.dateFixTroubleEmployee.toString() != '') {
      result = true;
    }
    return result;
  }
}
