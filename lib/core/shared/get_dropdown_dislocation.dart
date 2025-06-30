import 'package:flutter/material.dart';
import 'package:technical_support_artphoto/core/api/provider/provider_model.dart';

List<DropdownMenuItem<String>>? getDropdownDislocation(String? status, ProviderModel providerModel){
  if(status == 'В ремонте'){
    return providerModel.services.map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();
  }
  if(status == 'Транспортировка'){
    return providerModel.users.map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();
  }
  return providerModel.namesDislocation.map<DropdownMenuItem<String>>((String value) {
    return DropdownMenuItem<String>(
      value: value,
      child: Text(value),
    );
  }).toList();
}