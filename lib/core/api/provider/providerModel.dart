import 'package:flutter/material.dart';
import 'package:technical_support_artphoto/core/api/data/models/photosalon.dart';
import 'package:technical_support_artphoto/core/api/data/models/repair.dart';
import 'package:technical_support_artphoto/core/api/data/models/storage.dart';
import 'package:technical_support_artphoto/core/api/data/models/technic.dart';

class ProviderModel with ChangeNotifier {
  late final Map<String, Photosalon> _photosolons;
  late final Map<String, Repair> _repairs;
  late final Map<String, Storage> _storages;

  late final List<String> _namesEquipments;
  late final List<String> _namesPhotosalons;
  late final List<String> _services;
  late final List<String> _statusForEquipment;
  late final Map<String, int> _colorsForEquipment;

  final Map<String, String> user = {'user': 'not access'};
  int currentPageIndexMainBottomAppBar = 0;
  final Color colorPhotosalons = Colors.blue.shade200;
  final Color colorStorages = Colors.white70;
  final Color colorRepairs = Colors.yellow.shade200;

  Map<String, Photosalon> get photosolons => _photosolons;

  Map<String, Repair> get repairs => _repairs;

  Map<String, Storage> get storages => _storages;

  List<String> get namesPhotosalons => _namesPhotosalons;

  List<String> get services => _services;

  List<String> get statusForEquipment => _statusForEquipment;

  Map<String, int> get colorsForEquipment => _colorsForEquipment;

  List<String> get namesEquipments => _namesEquipments;

  void downloadAllElements(Map<String, Photosalon> photosalons,
      Map<String, Repair> repairs, Map<String, Storage> storages) {
    _photosolons = photosalons;
    _repairs = repairs;
    _storages = storages;
  }

  void downloadAllCategoryDropDown(
      List<String> namesEquipments,
      List<String> namePhotosalons,
      List<String> services,
      List<String> statusForEquipment,
      Map<String, int> colorsForEquipment) {
    _namesEquipments = namesEquipments;
    _namesPhotosalons = namePhotosalons;
    _services = services;
    _statusForEquipment = statusForEquipment;
    _colorsForEquipment = colorsForEquipment;
  }

  void addTechnicInPhotosalon(String name, Technic technic) {
    _photosolons[name]!.technics.add(technic);
    notifyListeners();
  }

  void updateTechnicInPhotosalon(Technic technic) {
    print(technic.dislocation);
    _photosolons[technic.dislocation]!.technics.map((element){
      if(technic.id == element.id){
        element.name = technic.name;
        element.dislocation = technic.dislocation;
        element.status = technic.status;
        element.comment = technic.comment;
        element.cost = technic.cost;
        element.dateBuyTechnic = technic.dateBuyTechnic;
      }
    });
    notifyListeners();
  }

  void addTechnicInRepair(String name, Technic technic) {
    _repairs[name]!.technics.add(technic);
    notifyListeners();
  }

  void addTechnicInStorage(String name, Technic technic) {
    _storages[name]!.technics.add(technic);
    notifyListeners();
  }

  void removeTechnicInPhotosalon(String name, Technic technic) {
    _photosolons[name]!.technics.remove(technic);
    notifyListeners();
  }

  void removeTechnicInRepair(String name, Technic technic) {
    _repairs[name]!.technics.remove(technic);
    notifyListeners();
  }

  void removeTechnicInStorage(String name, Technic technic) {
    _storages[name]!.technics.remove(technic);
    notifyListeners();
  }

  void changeCurrentPageMainBottomAppBar(int index) {
    currentPageIndexMainBottomAppBar = index;
    notifyListeners();
  }

  void refreshAllElement(
      Map<String, Photosalon> photosalons,
      Map<String, Repair> repairs,
      Map<String, Storage> storages,
      ) {
    _photosolons.clear();
    _repairs.clear();
    _storages.clear();
    _photosolons.addAll(photosalons);
    _repairs.addAll(repairs);
    _storages.addAll(storages);
  }
}
