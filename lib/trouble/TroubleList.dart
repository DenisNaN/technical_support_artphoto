import 'package:flutter/material.dart';
import 'package:technical_support_artphoto/trouble/TroubleAdd.dart';
import 'package:technical_support_artphoto/trouble/TroubleViewAndChange.dart';
import '../utils/hasNetwork.dart';
import 'Trouble.dart';
import 'package:intl/intl.dart';


class TroubleList extends StatefulWidget {
  const TroubleList({super.key});

  @override
  State<TroubleList> createState() => _TroubleListState();
}

class _TroubleListState extends State<TroubleList> {

  @override
  Widget build(BuildContext context) {
    List troubleList = _getListSortTrouble();

    return Scaffold (
        floatingActionButton: FloatingActionButton(
            backgroundColor: HasNetwork.isConnecting ? Colors.blue : Colors.grey,
            onPressed: HasNetwork.isConnecting ? () {Navigator.push(context, MaterialPageRoute(builder: (context) => const TroubleAdd())).then((value) {
              setState(() {
                if(value != null) Trouble.troubleList.insert(0, value);
              });
            });
            } : null,
            child: const Icon(Icons.add, color: Colors.white)
        ),
        body: ListView.separated(
          separatorBuilder: (BuildContext context, int index) => const Divider(),
          itemCount: troubleList.length,
          itemBuilder: (context, index) {
            bool isDoneTrouble = isAllFieldsFilled(troubleList[index]);
            return ListTile(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => TroubleViewAndChange(trouble: troubleList[index]))).then((value){
                  setState(() {
                    if(value != null) Trouble.troubleList[index] = value;
                  });
                });
              },
              tileColor: isDoneTrouble ? Colors.lightGreenAccent : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              title: _buildTitleListTile(context, index, troubleList)
            );
          },
        )
    );
  }

  List _getListSortTrouble(){
    List troubleList = [];

    Trouble.troubleList.forEach((element) {
      if(!isAllFieldsFilled(element)) troubleList.add(element);
    });
    Trouble.troubleList.forEach((element) {
      if(isAllFieldsFilled(element)) troubleList.add(element);
    });
    return troubleList;
  }

  Row _buildTitleListTile(BuildContext context, int index, List troubleList){
    bool checkboxValueEngineer;
    bool checkboxValueEmployee;
    bool checkboxValuePhoto = false;

    troubleList[index].dateCheckFixTroubleEngineer != '' ? checkboxValueEngineer = true :
      checkboxValueEngineer = false;
    troubleList[index].dateCheckFixTroubleEmployee != '' ? checkboxValueEmployee = true :
    checkboxValueEmployee = false;

    if(troubleList[index].photoTrouble != null){
      troubleList[index].photoTrouble.isNotEmpty ? checkboxValuePhoto = true :
      checkboxValuePhoto = false;
    }

    return Row(
      children: [
        Expanded(child:
          Text.rich(
              TextSpan(children: [
                TextSpan(
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    text: troubleList[index].internalID != 0 ?
                      '№ ${troubleList[index].internalID} ' : 'БН '),
                TextSpan(
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    text: '${troubleList[index].photosalon} '
                        '${troubleList[index].employee}\n'
                ),
                TextSpan(
                    style: const TextStyle(fontStyle: FontStyle.italic),
                    text: '${DateFormat('d MMMM yyyy', "ru_RU").format(DateTime.parse(troubleList[index].dateTrouble.replaceAll('.', '-')))}\n'),
                TextSpan(
                  text: 'Проблема: ${troubleList[index].trouble}\n',
                  children: [WidgetSpan(child:
                      Row(children: [
                        const Text( 'Фото: '),
                        SizedBox(
                            width: 30,
                            height: 10,
                            child: Checkbox(value: checkboxValuePhoto, onChanged: null)),
                        ]
                      )
                    )
                  ]
                )
              ],
          ))),
        Column(
          children: [
              Row(children: [SizedBox(
                  height: 30,
                  child: Checkbox(value: checkboxValueEmployee, onChanged: (value){})), const Text('Ф')]),
              Row(children: [SizedBox(
                  width: 48,
                  height: 30,
                  child: Checkbox(value: checkboxValueEngineer, onChanged: (value){})), const Text('И')])
        ],)
      ],
    );
  }

  bool isAllFieldsFilled(Trouble trouble){
    bool result = false;
    if(trouble.dateCheckFixTroubleEmployee != '' &&
        trouble.dateCheckFixTroubleEngineer != ''){
      result = true;
    }
    return result;
  }
}
