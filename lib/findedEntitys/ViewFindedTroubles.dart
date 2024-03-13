import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:technical_support_artphoto/findedEntitys/FiltersForTrouble.dart';
import 'package:technical_support_artphoto/trouble/Trouble.dart';
import 'package:intl/intl.dart';
import '../trouble/TroubleViewAndChange.dart';
import '../utils/utils.dart';
import 'FiltersForTechnic.dart';

class ViewFindedTrouble extends StatefulWidget {
  const ViewFindedTrouble({super.key});

  @override
  State<ViewFindedTrouble> createState() => _ViewFindedTroubleState();
}

class _ViewFindedTroubleState extends State<ViewFindedTrouble> {
  List tmpTroubleList = [];
  final _findController = TextEditingController();
  late FocusNode myFocusNode;
  int regularize = -1;
  Map filtersMap = {};

  @override
  void initState() {
    super.initState();
    tmpTroubleList = _getListSortTrouble();
    myFocusNode = FocusNode();
    myFocusNode.requestFocus();
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ColorAppBar colorAppBar = ColorAppBar();
    return Scaffold (
        appBar: AppBar(
          flexibleSpace: colorAppBar.color(),
          title: Container(
            height: 40,
            child: Row(
              children: [
                Flexible(
                  child: TextField(
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    focusNode: myFocusNode,
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        contentPadding: const EdgeInsets.only(top: 5, left: 10),
                        filled: true,
                        fillColor: Colors.white70,
                        hintText: "Поиск",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))
                    ),
                    controller: _findController,
                    keyboardType: TextInputType.number,
                    onSubmitted: (value)=> setState(() {
                      getListFindTroubles(value);
                    }),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: TextButton(
                      onPressed: (){
                        setState(() {
                          _findController.text = '';
                          tmpTroubleList.clear();
                          tmpTroubleList = _getListSortTrouble();
                          regularize = -1;
                          filtersMap.clear();
                        });
                      },
                      child: const Row(
                          children: [
                            Icon(Icons.clear, color: Colors.white,),
                            Text('Сброс', style: TextStyle(color: Colors.white),),
                          ])),
                )
              ],
            ),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Colors.lightBlueAccent, Colors.purpleAccent]),
          ),
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shadowColor: Colors.transparent,
                      backgroundColor: Colors.black.withOpacity(0.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.all(12),
                    ),
                    onPressed: (){
                      setState(() {
                        if(regularize == 1){
                          tmpTroubleList.sort((a, b) => a.internalID.compareTo(b.internalID));
                          regularize = 0;
                        } else if(regularize == 0){
                          tmpTroubleList.sort((a, b) => b.internalID.compareTo(a.internalID));
                          regularize = 1;
                        }else{
                          tmpTroubleList.sort((a, b) => a.internalID.compareTo(b.internalID));
                          regularize = 0;
                        }
                      });
                    },
                    child: Row(
                      children: [
                        regularize == 1 ? const Icon(Icons.expand_less) : const SizedBox(),
                        regularize == 0 ? const Icon(Icons.expand_more) : const SizedBox(),
                        regularize == -1 ? const SizedBox(width: 24) : const SizedBox(),
                        const Icon(Icons.sort_by_alpha),
                        const SizedBox(width: 3),
                        const Text('Упорядочить'),
                      ],
                    )),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shadowColor: Colors.transparent,
                      backgroundColor: Colors.black.withOpacity(0.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.all(12),
                    ),
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => FiltersForTrouble(filtMap: filtersMap))).then((map){
                        setState(() {
                          if(map != null){
                            tmpTroubleList.clear();
                            filtersMap.clear();
                            Trouble.troubleList.forEach((element) {
                              int countCoincidence = 0;
                              map.forEach((key, value) {
                                if(element.photosalon == value) countCoincidence++;
                                if(countCoincidence == map.length) tmpTroubleList.add(element);
                                filtersMap[key] = value;
                              });
                            });
                          }
                        });
                      });
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.filter_alt),
                        Text('Фильтры'),
                      ],
                    ))
              ],),
              Expanded(
                child: ListView.builder(
                  itemCount: tmpTroubleList.length,
                  itemBuilder: (context, index) {
                    bool isDoneTrouble = isFieldFilled(tmpTroubleList[index]);
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
                            Navigator.push(context, MaterialPageRoute(builder: (context) => TroubleViewAndChange(trouble: tmpTroubleList[index]))).then((value){
                              setState(() {
                                if(value != null) {
                                  int tmpIndex = findIndexTouble(value);
                                  Trouble.troubleList[tmpIndex] = value;
                                  tmpTroubleList.clear();
                                  tmpTroubleList = _getListSortTrouble();
                                }
                              });
                            });
                          },
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          title: _buildTitleListTile(context, index, tmpTroubleList)
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        )
    );
  }

  void getListFindTroubles(dynamic value){
    if(value != ''){
      int numberTechnic = int.parse(value);
      var troubles = Trouble.troubleList.where((element) => element.internalID == numberTechnic);
      if(troubles.isEmpty) {
        viewSnackBar('Ремонт не найден');
      } else {
        tmpTroubleList.clear();
        tmpTroubleList.addAll(troubles);
      }
    }
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

  void viewSnackBar(String text){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.bolt, size: 40, color: Colors.white),
            Text(text),
          ],
        ),
        duration: const Duration(seconds: 5),
        showCloseIcon: true,
      ),
    );
  }
}
