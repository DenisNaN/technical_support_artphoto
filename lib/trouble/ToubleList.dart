import 'package:flutter/material.dart';
import 'package:technical_support_artphoto/trouble/TroubleAdd.dart';
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
          itemCount: Trouble.troubleList.length,
          itemBuilder: (context, index) {
            bool isDoneTrouble = isAllFieldsFilled(Trouble.troubleList[index]);
            return ListTile(
              // onTap: (){
              //   Navigator.push(context, MaterialPageRoute(builder: (context) => TechnicViewAndChange(technic: Technic.technicList[index]))).then((value){
              //     setState(() {
              //       if(value != null) Technic.technicList[index] = value;
              //     });
              //   });
              // },
              tileColor: isDoneTrouble ? Colors.lightGreenAccent : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              title: _buildTitleListTile(context, index)
            );
          },
        )
    );
  }

  Row _buildTitleListTile(BuildContext context, int index){
    bool checkboxValueEngineer;
    bool checkboxValueEmployee;
    Trouble.troubleList[index].dateCheckFixTroubleEngineer != '' ? checkboxValueEngineer = true :
      checkboxValueEngineer = false;
    Trouble.troubleList[index].dateCheckFixTroubleEmployee != '' ? checkboxValueEmployee = true :
    checkboxValueEmployee = false;

    return Row(
      children: [
        Expanded(child:
          Text.rich(
              TextSpan(children: [
                TextSpan(
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    text: '№ ${Trouble.troubleList[index].internalID}  ${Trouble.troubleList[index].photosalon} ${Trouble.troubleList[index].employee}\n'),
                TextSpan(text: 'Проблема: ${Trouble.troubleList[index].trouble}\n'
                    '${DateFormat('d MMMM yyyy', "ru_RU").format(DateTime.parse(Trouble.troubleList[index].dateTrouble.replaceAll('.', '-')))}')
              ],
          ))),
        Column(
          children: [
              Row(children: [Checkbox(value: checkboxValueEngineer, onChanged: (value){}), const Text('И')]),
              Row(children: [Checkbox(value: checkboxValueEmployee, onChanged: (value){}), const Text('Ф')])
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
