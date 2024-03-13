import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:technical_support_artphoto/findedEntitys/FiltersForTechnic.dart';
import '../repair/Repair.dart';
import '../utils/categoryDropDownValueModel.dart';
import '../technics/Technic.dart';
import '../technics/TechnicViewAndChange.dart';
import 'package:intl/intl.dart';
import '../utils/utils.dart';

class ViewFindedTechnic extends StatefulWidget {
  const ViewFindedTechnic({super.key});

  @override
  State<ViewFindedTechnic> createState() => _ViewFindedTechnicState();
}

class _ViewFindedTechnicState extends State<ViewFindedTechnic> {
  Map<String, int> colorForTechnic = {};
  List tmpTechnicList = [];
  final _findController = TextEditingController();
  late FocusNode myFocusNode;
  int regularize = -1;
  Map filtersMap = {};

  @override
  void initState() {
    super.initState();
    colorForTechnic.addAll(CategoryDropDownValueModel.colorForEquipment);
    tmpTechnicList.addAll(Technic.technicList);
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
    return Scaffold(
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
                    getListFindTechnic(value);
                    }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: TextButton(
                    onPressed: (){
                      setState(() {
                        _findController.text = '';
                        tmpTechnicList.clear();
                        tmpTechnicList.addAll(Technic.technicList);
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
                        tmpTechnicList.sort((a, b) => a.internalID.compareTo(b.internalID));
                        regularize = 0;
                      } else if(regularize == 0){
                        tmpTechnicList.sort((a, b) => b.internalID.compareTo(a.internalID));
                        regularize = 1;
                      }else{
                        tmpTechnicList.sort((a, b) => a.internalID.compareTo(b.internalID));
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
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FiltersForTechnic(filtMap: filtersMap))).then((map){
                      setState(() {
                        if(map != null){
                          tmpTechnicList.clear();
                          filtersMap.clear();
                          Technic.technicList.forEach((element) {
                            int countCoincidence = 0;
                            map.forEach((key, value) {
                              if(element.category == value) countCoincidence++;
                              if(element.status == value) countCoincidence++;
                              if(element.dislocation == value) countCoincidence++;
                              if(countCoincidence == map.length) tmpTechnicList.add(element);
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
                itemCount: tmpTechnicList.length,
                itemBuilder: (context, index) {
                  String dateStart = _dateStart(index);
                  Color color = _getTileColor(index);
                  String nameTechnic = _nameTechnic(index);
                  List testDriveList = _getListTestDrive(tmpTechnicList[index]);

                  return Material(
                      child: Column(
                        children: [
                          ListTile(
                            tileColor: color,
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => TechnicViewAndChange(technic: tmpTechnicList[index]))).then((value){
                                setState(() {
                                  if(value != null) {
                                    tmpTechnicList[index] = value;
                                  }
                                });
                              });
                            },
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                            title: Text.rich(TextSpan(children: [
                              TextSpan(text: '№ ${tmpTechnicList[index].internalID} '),
                              TextSpan(text: '${tmpTechnicList[index].category}. ', style: const TextStyle(fontWeight: FontWeight.bold), ),
                              TextSpan(text: nameTechnic)
                            ])),
                            subtitle: dateStart != '' ?
                            _buildTextWithTestDrive(context, index, testDriveList) :
                            _buildTextWithoutTestDrive(context, index, testDriveList),
                          ),
                        ],
                      ));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void getListFindTechnic(dynamic value){
    if(value != ''){
      int numberTechnic = int.parse(value);
      Technic? technic = Technic.technicList.firstWhere((element) => element.internalID == numberTechnic,
          orElse: () => null);
      if(technic == null) {
        viewSnackBar('Техника не найдена');
      } else {
        tmpTechnicList.clear();
        tmpTechnicList.add(technic);
      }
    }
  }

  Text _buildTextWithoutTestDrive(BuildContext context, int index, List testDriveList){
    Color color = const Color(0xff000000);
    return Text.rich(TextSpan(children: [
      TextSpan(text: '${tmpTechnicList[index].dislocation}.',
          style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      testDriveList.isEmpty ? TextSpan(text: ' Статус: ${tmpTechnicList[index].status}\n'
          'Тест-драйв не проводился') : TextSpan(text: ' Статус: ${tmpTechnicList[index].status}\n'
          'Кол-во тест-драйвов: ${testDriveList.length}'),
      getTotalSumRepairs(index)
    ])
    );
  }

  Text _buildTextWithTestDrive(BuildContext context, int index, List testDriveList){
    DateTime dateStart = DateTime.parse(tmpTechnicList[index].dateStartTestDrive.replaceAll('.', '-'));
    DateTime dateFinish;
    DateTime dateNow;
    String formatedStartDate = DateFormat("d MMMM yyyy", "ru_RU").format(dateStart);
    String formatedFinishDate = '';
    Duration duration = const Duration(days: 0);
    bool isHaveFinishDate = false;
    Color color = const Color(0xff000000);

    if(tmpTechnicList[index].dateFinishTestDrive != ''){
      dateFinish = DateTime.parse(tmpTechnicList[index].dateFinishTestDrive.replaceAll('.', '-'));
      formatedFinishDate = DateFormat("d MMMM yyyy", "ru_RU").format(dateFinish);
      dateNow = DateTime.now().add(const Duration(days: -1));
      duration = dateFinish.difference(dateNow);
      isHaveFinishDate = true;
    }
    return Text.rich(
        TextSpan(
            children:[
              TextSpan(
                  text: '${tmpTechnicList[index].dislocation}. ',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: color)),
              TextSpan(text:
              'Статус: ${tmpTechnicList[index].status}\n'),
              isHaveFinishDate ?
              TextSpan(children: [
                TextSpan(text:
                'Начало тест-драйва: $formatedStartDate.\n'
                    'Конец тест-драйва: $formatedFinishDate.\n'),
                duration.inDays > 0 && !tmpTechnicList[index].checkboxTestDrive ?
                TextSpan(
                    text: 'До конца тест-драйва: ${duration.inDays} ${getDayAddition(duration.inDays)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)
                ) : TextSpan(
                    text: !tmpTechnicList[index].checkboxTestDrive ?
                    'Период тест-драйва завершен' :
                    'Тест-драйв завершен',
                    style: TextStyle(fontWeight: FontWeight.bold, color: tmpTechnicList[index].checkboxTestDrive ? Colors.green : Colors.blue)
                )
              ]
              ) :
              TextSpan(children:[
                TextSpan(text: 'Дата тест-драйва: $formatedStartDate.\n'),
                TextSpan(text: tmpTechnicList[index].checkboxTestDrive ? 'Тест-драйв завершен' : 'Тест-драйв не завершен',
                    style: TextStyle(fontWeight: FontWeight.bold, color: tmpTechnicList[index].checkboxTestDrive ?
                    Colors.green : Colors.blue)),
              ]),
              getTotalSumRepairs(index)
            ]
        )
    );
  }

  TextSpan getTotalSumRepairs(int index){
    int totalSumRepairs = _getTotalSumRepairs(index);
    return TextSpan(text: totalSumRepairs != 0 ? '\nИтоговая сумма ремонта: $totalSumRepairs р.' :
    '\nРемонт не проводился');
  }

  int _getTotalSumRepairs(int index){
    int totalSumRepairs = 0;
    for(TotalSumRepairs element in Repair.totalSumRepairs){
      if(element.idTechnic == tmpTechnicList[index].internalID){
        int coastReapair = element.sumRepair;
        totalSumRepairs += coastReapair;
      }
    }
    return totalSumRepairs;
  }

  String getDayAddition(int num) {
    double preLastDigit = num % 100 / 10;
    if (preLastDigit.round() == 1) {
      return "дней";
    }
    switch (num % 10) {
      case 1:
        return "день";
      case 2:
      case 3:
      case 4:
        return "дня";
      default:
        return "дней";
    }
  }

  String _dateStart(int index){
    String dateStart = '';
    if(tmpTechnicList[index].dateStartTestDrive != ''){
      dateStart = tmpTechnicList[index].dateStartTestDrive;
    }
    return dateStart;
  }

  Color _getTileColor(int index){
    Color color = const Color(0xffFFFFFF);
    if(colorForTechnic.isNotEmpty) {
      String dislocation = tmpTechnicList[index].dislocation;
      color = Color(colorForTechnic[dislocation]!);
      // color = Color(CategoryDropDownValueModel.colorForEquipment[Technic.technicList[index].dislocation]!);
    }
    return color;
  }

  String _nameTechnic(int index){
    String nameTechnic = 'Модель не указана';
    if(tmpTechnicList[index].name == '') return nameTechnic;
    int lastSymbolNameTechnic = tmpTechnicList[index].name.length;
    nameTechnic = '${tmpTechnicList[index].name[0].toUpperCase()}${tmpTechnicList[index].name.substring(1, lastSymbolNameTechnic).trim()}.';
    return nameTechnic;
  }

  List _getListTestDrive(Technic technic){
    List list = [];
    for(var element in Technic.testDriveList){
      if(technic.id == element.internalID){
        list.add(element);
      }
    }
    return list;
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
