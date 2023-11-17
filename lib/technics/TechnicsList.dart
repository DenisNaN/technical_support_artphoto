import 'package:flutter/material.dart';
import 'Technic.dart';
import 'TechnicAdd.dart';
import 'TechnicViewAndChange.dart';

class TechnicsList extends StatefulWidget {
  const TechnicsList({super.key});

  @override
  State<TechnicsList> createState() => _TechnicsListState();
}

class _TechnicsListState extends State<TechnicsList> {

  @override
  Widget build(BuildContext context) {
    return Scaffold (
        floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add, color: Colors.white),
            onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => TechnicAdd())).then((value) {
              setState(() {
                if(value != null) Technic.technicList.insert(0, value);
              });
            });
            }),
        body: ListView.builder(
          // separatorBuilder: (BuildContext context, int index) => const Divider(),
          itemCount: Technic.technicList.length,
          itemBuilder: (context, index) {
            // return Text(Technic.entityList[index].toString());
            return ListTile(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => TechnicViewAndChange(technic: Technic.technicList[index])));
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              title: Text('№ ${Technic.technicList[index].internalID}  ${Technic.technicList[index].name}  ${Technic.technicList[index].category}'),
              subtitle: Text('${Technic.technicList[index].dislocation}.  Статус: ${Technic.technicList[index].status}'),
            );
          },
        )
    );
  }
}



