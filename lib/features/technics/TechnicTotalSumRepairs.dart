
// class TechnicTotalSumRepairs extends StatefulWidget{
//   final int internalId;
//   const TechnicTotalSumRepairs({super.key, required this.internalId});
//
//   @override
//   State<TechnicTotalSumRepairs> createState() => _TechnicTotalSumRepairsState();
// }
//
// class _TechnicTotalSumRepairsState extends State<TechnicTotalSumRepairs> {
//   int indexRepairList = -1;
//   int indexTotalSumRepairs = -1;
//
//   @override
//   Widget build(BuildContext context) {
//     List listTotalSumRepair = _getListTotalSumRepairs(widget.internalId);
//
//     return Scaffold(
//       appBar: app_bar(title: Text('Ремонты техники №${widget.internalId}')),
//       body: ListView.builder(
//           itemCount: listTotalSumRepair.length,
//           itemBuilder: (context, index){
//             Repair? repair = _getRepair(index);
//             _getTotalSumRepairsIndex(repair!.internalID!);
//             bool isDoneRepair = isAllFieldsFilled(repair);
//             return Container(
//               margin: const EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 8),
//               decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey, width: 0.5),
//                   borderRadius: BorderRadius.circular(10),
//                   color: isDoneRepair ? Colors.lightGreenAccent : Colors.white,
//                   boxShadow: const [
//                     BoxShadow(
//                       color: Colors.grey,
//                       blurRadius: 4,
//                       offset: Offset(2, 4), // Shadow position
//                     ),
//                   ]
//               ),
//               child: ListTile(
//                 title: _buildText(context, index),
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 20),
//                 onTap: (){
//                   Navigator.push(
//                       context, MaterialPageRoute(
//                       builder: (context) => RepairViewAndChange(repair: repair))).then((value) {
//                     setState(() {
//                       if (value != null) {
//                         Repair.repairList[indexRepairList] = value;
//                         Repair.totalSumRepairs[indexTotalSumRepairs] = TotalSumRepairs(value.id, value.internalID, value.costService);
//                         listTotalSumRepair[index] = value;
//                       }
//                     });
//                   });
//                 },
//               ),
//             );
//           }
//       ),
//     );
//   }
//
//   Text _buildText(BuildContext context, int index){
//     Repair? repair = _getRepair(index);
//     if(repair == null){
//       return Text('Ошибка загруки данных\n'
//           '\nПришел null из _getRepair в TechnicTotalSumRepair._buildText. '
//           'index = $index\n'
//           'Скриншот отправить Денису');
//     }
//     return Text.rich(
//         TextSpan(children: [
//           TextSpan(text: 'Ремонтировал: ${repair.serviceDislocation}\n', style: const TextStyle(fontSize: 20)),
//           TextSpan(text: 'Сумма ремонта: ${repair.costService}\n'),
//           TextSpan(text: 'Жалоба: ${repair.complaint}\n'),
//           TextSpan(text: 'Забрали с точки: ${getDateFormat(repair.dateDeparture)}\n')
//         ]
//         )
//     );
//   }
//
//   Repair? _getRepair(int indexRepair){
//     List listTotalSumRepair = _getListTotalSumRepairs(widget.internalId);
//     TotalSumRepairs totalSumRepair = listTotalSumRepair[indexRepair];
//     int idRepair = totalSumRepair.idRepair;
//     Repair? repair;
//     int index = 0;
//     Repair.repairList.forEach((element) {
//       if(element.id == idRepair) {
//         repair = element;
//         indexRepairList = index;
//       }
//       index++;
//     });
//     return repair;
//   }
//
//   List _getListTotalSumRepairs(int internalID){
//     List totalSumRepairs = [];
//     Repair.totalSumRepairs.forEach((element) {
//       if(element.idTechnic == internalID){
//         totalSumRepairs.add(element);
//       }
//     });
//     return totalSumRepairs;
//   }
//
//   void _getTotalSumRepairsIndex(int internalID){
//     int index = 0;
//     Repair.totalSumRepairs.forEach((element) {
//       if(element.idTechnic == internalID){
//         indexTotalSumRepairs = index;
//       }
//       index++;
//     });
//   }
//
//   bool isAllFieldsFilled(Repair repair){
//     bool result = false;
//     if(repair.complaint != '' &&
//         repair.dateDeparture != '' &&
//         repair.dateTransferInService != '' &&
//         repair.serviceDislocation != '' &&
//         repair.dateDepartureFromService != '' &&
//         repair.worksPerformed != '' &&
//         repair.costService != 0 &&
//         repair.diagnosisService != '' &&
//         repair.dateReceipt != '' &&
//         repair.newStatus != '' &&
//         repair.newDislocation != ''){
//       result = true;
//     }
//     return result;
//   }
//
//   String getDateFormat(String date) {
//     if(date == '') return 'Нет даты';
//     return DateFormat("d MMMM yyyy", "ru_RU").format(DateTime.parse(date.replaceAll('.', '-')));
//   }
// }