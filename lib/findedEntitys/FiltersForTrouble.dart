import 'package:flutter/material.dart';
import '../utils/categoryDropDownValueModel.dart';
import '../utils/utils.dart';

class FiltersForTrouble extends StatefulWidget {
  final Map filtMap;
  const FiltersForTrouble({super.key, required this.filtMap});

  @override
  State<FiltersForTrouble> createState() => _FiltersForTroubleState();
}

class _FiltersForTroubleState extends State<FiltersForTrouble> {
  String? _selectedDropdownDislocation;
  Map filtersMap = {};

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if(widget.filtMap.isNotEmpty){
      widget.filtMap.forEach((key, value) {
        if(key == 'dislocation') _selectedDropdownDislocation = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ColorAppBar colorAppBar = ColorAppBar();
    return Scaffold(
        appBar: AppBar(
          flexibleSpace: colorAppBar.color(),
          title: const Text('Фильтры'),
        ),
        bottomNavigationBar: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              child:Row(
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Отмена")),
                  const Spacer(),
                  TextButton(
                      onPressed: () {
                        filtersMap.clear();
                        if(_selectedDropdownDislocation != null) filtersMap['dislocation'] = _selectedDropdownDislocation;

                        if(filtersMap.isEmpty){
                          viewSnackBar('Фильтры не выбраны');
                        }else{
                          Navigator.pop(context, filtersMap);
                        }
                      },
                      child: const Text("Применить фильтры"))
                ],
              ),
            )
        ),
        body: Form(
            key: _formKey,
            child:
            ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDislocation()
              ],
            )
        )
    );
  }

  ListTile _buildDislocation() {
    return ListTile(
      leading: const Icon(Icons.airport_shuttle),
      title: DropdownButton<String>(
        borderRadius: BorderRadius.circular(10.0),
        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
        isExpanded: true,
        hint: const Text('Дислокация техники'),
        icon: _selectedDropdownDislocation != null ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            onPressed: (){
              setState(() {
                _selectedDropdownDislocation = null;
              });}) : null,
        value: _selectedDropdownDislocation,
        items: CategoryDropDownValueModel.photosalons.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? value){
          setState(() {
            _selectedDropdownDislocation = value!;
          });
        },
      ),
    );
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
