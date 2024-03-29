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
  List troubleList = [];

  @override
  void initState() {
    super.initState();
    troubleList = _getListSortTrouble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold (
        floatingActionButton: FloatingActionButton(
            backgroundColor: HasNetwork.isConnecting ? Colors.blue : Colors.grey,
            onPressed: HasNetwork.isConnecting ? () {Navigator.push(context, MaterialPageRoute(builder: (context) => const TroubleAdd())).then((value) {
              setState(() {
                if(value != null) {
                  Trouble.troubleList.insert(0, value);
                  troubleList.clear();
                  troubleList = _getListSortTrouble();
                }
              });
            });
            } : null,
            child: const Icon(Icons.add, color: Colors.white)
        ),
        body: ListView.builder(
          itemCount: troubleList.length,
          itemBuilder: (context, index) {
            bool isDoneTrouble = isFieldFilled(troubleList[index]);
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
                  ]
              ),
              child: ListTile(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => TroubleViewAndChange(trouble: troubleList[index]))).then((value){
                    setState(() {
                      if(value != null) {
                        int tmpIndex = findIndexTouble(value);
                        Trouble.troubleList[tmpIndex] = value;
                        troubleList.clear();
                        troubleList = _getListSortTrouble();
                      }
                    });
                  });
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                title: _buildTitleListTile(context, index, troubleList)
              ),
            );
          },
        )
    );
  }

  List _getListSortTrouble(){
    List troubleList = [];
    List tmpList = [];

    Trouble.troubleList.forEach((element) {
      if(!isFieldFilled(element)) troubleList.add(element);
    });
    troubleList.sort((element1, element2) =>
        DateTime.parse(element2.dateTrouble.replaceAll('.', '-')).compareTo(
            DateTime.parse(element1.dateTrouble.replaceAll('.', '-'))));

    Trouble.troubleList.forEach((element) {
      if(isFieldFilled(element)) {
        tmpList.add(element);
      }
    });
    tmpList.sort((element1, element2) =>
        DateTime.parse(element2.dateTrouble.replaceAll('.', '-')).compareTo(
            DateTime.parse(element1.dateTrouble.replaceAll('.', '-'))));
    troubleList.addAll(tmpList);
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

  bool isFieldFilled(Trouble trouble){
    bool result = false;
    if(trouble.dateCheckFixTroubleEmployee != ''){
      result = true;
    }
    return result;
  }

  int findIndexTouble(Trouble trouble){
    int index = -1;
    for(int i = 0; i < Trouble.troubleList.length; i++){
      if(Trouble.troubleList[i].id == trouble.id) index = i;
    }
    return index;
  }
}
