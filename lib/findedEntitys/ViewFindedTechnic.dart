import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    colorForTechnic.addAll(CategoryDropDownValueModel.colorForEquipment);
    tmpTechnicList.addAll(Technic.technicList);
  }

  @override
  Widget build(BuildContext context) {
    ColorAppBar colorAppBar = ColorAppBar();
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: colorAppBar.color(),
        title: Container(height: 40,
            padding: const EdgeInsets.only(left: 20, top: 5),
            child: TextField(
              decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _findController.text = '';
                        tmpTechnicList.clear();
                        tmpTechnicList.addAll(Technic.technicList);
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
                getListFindTechnic(value);
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
    );
  }

  void getListFindTechnic(dynamic value){
    print(value);
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