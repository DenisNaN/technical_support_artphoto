import 'package:flutter/material.dart';
import 'technic_entity.dart';
import 'technic_add.dart';
import 'TechnicViewAndChange.dart';
import 'package:intl/intl.dart';

class Technicslist extends StatelessWidget {
  const Technicslist({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Bla'),);
  }
}


// class TechnicsList extends StatefulWidget {
//   const TechnicsList({super.key});
//
//   @override
//   State<TechnicsList> createState() => _TechnicsListState();
// }
//
// class _TechnicsListState extends State<TechnicsList> {
//   Map<String, int> colorForTechnic = {};
//   Map<String, int> headerGroup = {};
//
//   @override
//   void initState() {
//     super.initState();
//     // colorForTechnic.addAll(CategoryDropDownValueModel.colorForEquipment);
//     //
//     // CategoryDropDownValueModel.photosalons.sort();
//     // for(String photosalon in CategoryDropDownValueModel.photosalons){
//     //   headerGroup[photosalon] = -1;
//     // }
//     int index = TechnicEntity.technicList.length - 1;
//     for(int i = TechnicEntity.technicList.length - 1; i >= 0; i--){
//       headerGroup[TechnicEntity.technicList[i].dislocation] = index--;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold (
//         floatingActionButton: FloatingActionButton(
//             backgroundColor: Colors.blue,
//             onPressed: HasNetwork.isConnecting ? () {Navigator.push(context, MaterialPageRoute(builder: (context) => const TechnicAdd())).then((value) {
//               setState(() {
//                 if(value != null) {
//                   TechnicEntity.technicList.insert(0, value);
//                   TechnicEntity.technicList.sort();
//                 }}
//               );
//             });
//             } : null,
//             child: const Icon(Icons.add, color: Colors.white)
//             ),
//         body: ListView.builder(
//           itemCount: TechnicEntity.technicList.length,
//           itemBuilder: (context, index) {
//             String dateStart = _dateStart(index);
//             Color color = _getTileColor(index);
//             String nameTechnic = _nameTechnic(index);
//             List testDriveList = _getListTestDrive(TechnicEntity.technicList[index]);
//
//             return Material(
//                 child: Column(
//                   children: [
//                     index == headerGroup[TechnicEntity.technicList[index].dislocation] ?
//                           _getTextHeader(index) : const SizedBox.shrink(),
//                     ListTile(
//                       tileColor: color,
//                       onTap: (){
//                         Navigator.push(context, MaterialPageRoute(builder: (context) => TechnicViewAndChange(technic: TechnicEntity.technicList[index]))).then((value){
//                             setState(() {
//                               if(value != null) {
//                                 TechnicEntity.technicList[index] = value;
//                               }
//                             });
//                           });
//                       },
//                       contentPadding: const EdgeInsets.symmetric(horizontal: 20),
//                       title: Text.rich(TextSpan(children: [
//                         TextSpan(text: '№ ${TechnicEntity.technicList[index].internalID} '),
//                         TextSpan(text: '${TechnicEntity.technicList[index].category}. ', style: const TextStyle(fontWeight: FontWeight.bold), ),
//                         TextSpan(text: nameTechnic)
//                       ])),
//                       subtitle: dateStart != '' ?
//                         _buildTextWithTestDrive(context, index, testDriveList) :
//                         _buildTextWithoutTestDrive(context, index, testDriveList),
//                     ),
//                   ],
//                 ));
//           },
//         )
//     );
//   }
//
//   Text _buildTextWithoutTestDrive(BuildContext context, int index, List testDriveList){
//     Color color = const Color(0xff000000);
//     return Text.rich(TextSpan(children: [
//       TextSpan(text: '${TechnicEntity.technicList[index].dislocation}.',
//         style: TextStyle(fontWeight: FontWeight.bold, color: color)),
//       testDriveList.isEmpty ? TextSpan(text: ' Статус: ${TechnicEntity.technicList[index].status}\n'
//           'Тест-драйв не проводился') : TextSpan(text: ' Статус: ${TechnicEntity.technicList[index].status}\n'
//           'Кол-во тест-драйвов: ${testDriveList.length}'),
//       getTotalSumRepairs(index)
//       ])
//     );
//   }
//
//   Text _buildTextWithTestDrive(BuildContext context, int index, List testDriveList){
//     DateTime dateStart = DateTime.parse(TechnicEntity.technicList[index].dateStartTestDrive.replaceAll('.', '-'));
//     DateTime dateFinish;
//     DateTime dateNow;
//     String formatedStartDate = DateFormat("d MMMM yyyy", "ru_RU").format(dateStart);
//     String formatedFinishDate = '';
//     Duration duration = const Duration(days: 0);
//     bool isHaveFinishDate = false;
//     Color color = const Color(0xff000000);
//
//     if(TechnicEntity.technicList[index].dateFinishTestDrive != ''){
//       dateFinish = DateTime.parse(TechnicEntity.technicList[index].dateFinishTestDrive.replaceAll('.', '-'));
//       formatedFinishDate = DateFormat("d MMMM yyyy", "ru_RU").format(dateFinish);
//       dateNow = DateTime.now().add(const Duration(days: -1));
//       duration = dateFinish.difference(dateNow);
//       isHaveFinishDate = true;
//     }
//     return Text.rich(
//         TextSpan(
//             children:[
//               TextSpan(
//                 text: '${TechnicEntity.technicList[index].dislocation}. ',
//                 style: TextStyle(
//                     fontWeight: FontWeight.bold, color: color)),
//               TextSpan(text:
//                   'Статус: ${TechnicEntity.technicList[index].status}\n'),
//               isHaveFinishDate ?
//               TextSpan(children: [
//                 TextSpan(text:
//                   'Начало тест-драйва: $formatedStartDate.\n'
//                   'Конец тест-драйва: $formatedFinishDate.\n'),
//                 duration.inDays > 0 && !TechnicEntity.technicList[index].checkboxTestDrive ?
//                     TextSpan(
//                     text: 'До конца тест-драйва: ${duration.inDays} ${getDayAddition(duration.inDays)}',
//                     style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)
//                 ) : TextSpan(
//                     text: !TechnicEntity.technicList[index].checkboxTestDrive ?
//                     'Период тест-драйва завершен' :
//                     'Тест-драйв завершен',
//                     style: TextStyle(fontWeight: FontWeight.bold, color: TechnicEntity.technicList[index].checkboxTestDrive ? Colors.green : Colors.blue)
//                 )
//                   ]
//               ) :
//               TextSpan(children:[
//                 TextSpan(text: 'Дата тест-драйва: $formatedStartDate.\n'),
//                 TextSpan(text: TechnicEntity.technicList[index].checkboxTestDrive ? 'Тест-драйв завершен' : 'Тест-драйв не завершен',
//                         style: TextStyle(fontWeight: FontWeight.bold, color: TechnicEntity.technicList[index].checkboxTestDrive ?
//                           Colors.green : Colors.blue)),
//               ]),
//               getTotalSumRepairs(index)
//             ]
//         )
//     );
//   }
//
//   TextSpan getTotalSumRepairs(int index){
//     int totalSumRepairs = _getTotalSumRepairs(index);
//     return TextSpan(text: totalSumRepairs != 0 ? '\nИтоговая сумма ремонта: $totalSumRepairs р.' :
//     '\nРемонт не проводился');
//   }
//
//   String getDayAddition(int num) {
//     double preLastDigit = num % 100 / 10;
//     if (preLastDigit.round() == 1) {
//       return "дней";
//     }
//     switch (num % 10) {
//       case 1:
//         return "день";
//       case 2:
//       case 3:
//       case 4:
//         return "дня";
//       default:
//         return "дней";
//     }
//   }
//
//   String _dateStart(int index){
//     String dateStart = '';
//     if(TechnicEntity.technicList[index].dateStartTestDrive != ''){
//       dateStart = TechnicEntity.technicList[index].dateStartTestDrive;
//     }
//     return dateStart;
//   }
//
//   Color _getTileColor(int index){
//     Color color = const Color(0xffFFFFFF);
//     if(colorForTechnic.isNotEmpty) {
//       String dislocation = TechnicEntity.technicList[index].dislocation;
//       color = Color(colorForTechnic[dislocation]!);
//       // color = Color(CategoryDropDownValueModel.colorForEquipment[Technic.technicList[index].dislocation]!);
//     }
//     return color;
//   }
//
//   Container _getTextHeader(int index){
//     return Container(width: double.maxFinite, height: 30, alignment: Alignment.center,
//       decoration: const BoxDecoration(
//           gradient: LinearGradient(
//           begin: Alignment.bottomLeft,
//           end: Alignment.topRight,
//           colors: [Colors.indigoAccent, Colors.blue]),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey,
//               blurRadius: 4,
//               offset: Offset(2, 4), // Shadow position
//             ),
//           ]),
//       child: Text('${TechnicEntity.technicList[index].dislocation}',
//         style: const TextStyle(
//           fontWeight: FontWeight.bold,
//           fontStyle: FontStyle.italic,
//           fontSize: 20,
//           color: Colors.white)),
//     );
//   }
//
//   String _nameTechnic(int index){
//     String nameTechnic = 'Модель не указана';
//     if(TechnicEntity.technicList[index].name == '') return nameTechnic;
//     int lastSymbolNameTechnic = TechnicEntity.technicList[index].name.length;
//     nameTechnic = '${TechnicEntity.technicList[index].name[0].toUpperCase()}${TechnicEntity.technicList[index].name.substring(1, lastSymbolNameTechnic).trim()}.';
//     return nameTechnic;
//   }
//
//   int _getTotalSumRepairs(int index){
//     int totalSumRepairs = 0;
//     for(TotalSumRepairs element in Repair.totalSumRepairs){
//       if(element.idTechnic == TechnicEntity.technicList[index].internalID){
//         int coastReapair = element.sumRepair;
//         totalSumRepairs += coastReapair;
//       }
//     }
//     return totalSumRepairs;
//   }
//
//   List _getListTestDrive(TechnicEntity technic){
//     List list = [];
//     for(var element in TechnicEntity.testDriveList){
//       if(technic.id == element.internalID){
//         list.add(element);
//       }
//     }
//     return list;
//   }
// }



