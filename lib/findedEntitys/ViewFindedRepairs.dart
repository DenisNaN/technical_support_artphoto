import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:technical_support_artphoto/findedEntitys/FiltersForRepair.dart';
import '../repair/Repair.dart';
import '../repair/RepairViewAndChange.dart';
import '../utils/utils.dart';

class ViewFindedRepairs extends StatefulWidget {
  const ViewFindedRepairs({super.key});

  @override
  State<ViewFindedRepairs> createState() => _ViewFindedRepairsState();
}

class _ViewFindedRepairsState extends State<ViewFindedRepairs> {
  List tmpRepairsList = [];
  final _findController = TextEditingController();
  late FocusNode myFocusNode;
  int regularize = -1;
  Map filtersMap = {};

  @override
  void initState() {
    super.initState();
    tmpRepairsList.addAll(Repair.repairList);
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
          title: Container(height: 40,
            padding: const EdgeInsets.only(left: 20, top: 5),
            child: TextField(
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              focusNode: myFocusNode,
              decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _findController.text = '';
                          tmpRepairsList.clear();
                          tmpRepairsList.addAll(Repair.repairList);
                          regularize = -1;
                          filtersMap.clear();
                        });
                      }),
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
                getListFindRepairs(value);
              }),
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
                          tmpRepairsList.sort((a, b) => a.internalID.compareTo(b.internalID));
                          regularize = 0;
                        } else if(regularize == 0){
                          tmpRepairsList.sort((a, b) => b.internalID.compareTo(a.internalID));
                          regularize = 1;
                        }else{
                          tmpRepairsList.sort((a, b) => a.internalID.compareTo(b.internalID));
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => FiltersForRepair(filtMap: filtersMap))).then((map){
                        setState(() {
                          if(map != null){
                            tmpRepairsList.clear();
                            filtersMap.clear();
                            Repair.repairList.forEach((element) {
                              int countCoincidence = 0;
                              map.forEach((key, value) {
                                if(element.category == value) countCoincidence++;
                                if(element.status == value) countCoincidence++;
                                if(element.dislocationOld == value) countCoincidence++;
                                if(countCoincidence == map.length) tmpRepairsList.add(element);
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
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: tmpRepairsList.length,
                  itemBuilder: (context, index) {
                    Repair repair = tmpRepairsList[index];
                    Color tileColor = getColorForList(repair);

                    return Container(
                      margin: const EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 8),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: tileColor,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.grey,
                              blurRadius: 4,
                              offset: Offset(2, 4), // Shadow position
                            ),
                          ]
                      ),
                      padding: const EdgeInsets.fromLTRB(3, 3, 3, 3),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => RepairViewAndChange(repair: tmpRepairsList[index]))).then((value) {
                            setState(() {
                              if (value != null) tmpRepairsList[index] = value;
                            });
                          });
                        },
                        title: _buildTextTitle(context, index),
                        subtitle: _buildTextSubtitle(context, index),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
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

  void getListFindRepairs(dynamic value){
    if(value != ''){
      int numberTechnic = int.parse(value);
      var repairs = Repair.repairList.where((element) => element.internalID == numberTechnic);
      if(repairs.isEmpty) {
        viewSnackBar('Ремонт не найден');
      } else {
        tmpRepairsList.clear();
        tmpRepairsList.addAll(repairs);
      }
    }
  }

  Text _buildTextTitle(BuildContext context, int index){
    String repairComplaint = 'Не внесли данные.';
    if(tmpRepairsList[index].complaint != '' && tmpRepairsList[index].complaint != null){
      repairComplaint = '${tmpRepairsList[index].complaint}.';
    }

    if(tmpRepairsList[index].internalID != -1){
      return Text.rich(TextSpan(children:
      [TextSpan(text: '№ ${tmpRepairsList[index].internalID}. ${tmpRepairsList[index].category}.\n',
          style: const TextStyle(fontWeight: FontWeight.bold)),
        TextSpan(text: 'Жалоба: $repairComplaint')
      ]
      ));
    } else{
      return Text.rich(TextSpan(children:
      [TextSpan(text: 'Без №. ${tmpRepairsList[index].category}.\n',
          style: const TextStyle(fontWeight: FontWeight.bold)),
        TextSpan(text: 'Жалоба: $repairComplaint')
      ]
      ));
    }
  }

  Text _buildTextSubtitle(BuildContext context, int index){
    String repairStatus = 'Отсутствует.';
    if(tmpRepairsList[index].status != '' && tmpRepairsList[index].status != null){
      if(tmpRepairsList[index].newStatus != '' && tmpRepairsList[index].newStatus != null){
        repairStatus = '${tmpRepairsList[index].newStatus}.';
      } else {
        repairStatus = '${tmpRepairsList[index].status}.';
      }
    }
    String repairDislocation = 'Отсутствует.';
    if(tmpRepairsList[index].dislocationOld != '' && tmpRepairsList[index].dislocationOld != null){
      if(tmpRepairsList[index].newDislocation != '' && tmpRepairsList[index].newDislocation != null){
        repairDislocation = '${tmpRepairsList[index].newDislocation}.';
      } else {
        repairDislocation = '${tmpRepairsList[index].dislocationOld}.';
      }
    }
    String repairLastDate = 'Даты отсутствуют.';
    if(tmpRepairsList[index].dateDeparture != '') {
      repairLastDate = 'Забрали с точки: ${getDateFormat(tmpRepairsList[index].dateDeparture)}.';
    }
    if(tmpRepairsList[index].dateTransferInService != ''){
      repairLastDate = 'Сдали в ремонт: ${getDateFormat(tmpRepairsList[index].dateTransferInService)}.';
    }
    if(tmpRepairsList[index].dateDepartureFromService != ''){
      repairLastDate = 'Забрали из ремонта: ${getDateFormat(tmpRepairsList[index].dateDepartureFromService)}.';
    }

    return Text(
        'Статус: $repairStatus\n'
            'Дислокация: $repairDislocation\n'
            '$repairLastDate'
    );
  }

  Color getColorForList(Repair repair){
    Color color = Colors.white;
    String resultColor = fieldsFilled(repair);
    switch(resultColor){
      case 'red':
        color = Colors.deepOrange.shade100;
        break;
      case 'yellow':
        color = Colors.yellow.shade100;
        break;
      case 'green':
        color = Colors.green.shade100;
        break;
    }
    return color;
  }

  String fieldsFilled(Repair repair){
    String result = 'yellow';
    if(repair.complaint != '' &&
        repair.dateDeparture != '' &&
        repair.dateTransferInService != '' &&
        repair.serviceDislocation != '' &&
        repair.dateDepartureFromService != '' &&
        repair.worksPerformed != '' &&
        repair.costService != 0 &&
        repair.diagnosisService != '' &&
        repair.dateReceipt != '' &&
        repair.newStatus != '' &&
        repair.newDislocation != ''){
      return 'green';
    }
    if(repair.dateTransferInService == '' ||
        repair.serviceDislocation == ''){
      return 'red';
    }
    return result;
  }

  String getDateFormat(String date) {
    return DateFormat("d MMMM yyyy", "ru_RU").format(DateTime.parse(date.replaceAll('.', '-')));
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
