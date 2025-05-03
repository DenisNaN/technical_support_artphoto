import 'package:flutter/material.dart';
import 'package:technical_support_artphoto/core/api/data/models/location.dart';
import 'package:technical_support_artphoto/core/api/data/models/photosalon_location.dart';
import 'package:technical_support_artphoto/core/api/data/models/repair_location.dart';
import 'package:technical_support_artphoto/core/api/data/models/storage_location.dart';
import 'package:technical_support_artphoto/core/api/data/models/technic.dart';

class ProviderModel with ChangeNotifier {
  late final Map<String, PhotosalonLocation> _photosolons;
  late final Map<String, RepairLocation> _repairs;
  late final Map<String, StorageLocation> _storages;

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

  Map<String, PhotosalonLocation> get photosolons => _photosolons;

  Map<String, RepairLocation> get repairs => _repairs;

  Map<String, StorageLocation> get storages => _storages;

  List<String> get namesPhotosalons => _namesPhotosalons;

  List<String> get services => _services;

  List<String> get statusForEquipment => _statusForEquipment;

  Map<String, int> get colorsForEquipment => _colorsForEquipment;

  List<String> get namesEquipments => _namesEquipments;

  void downloadAllElements(Map<String, PhotosalonLocation> photosalons,
      Map<String, RepairLocation> repairs, Map<String, StorageLocation> storages) {
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

  void updateTechnicInProvider(dynamic location, Technic technic) {
    switch(Location){
      case const (PhotosalonLocation):
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
      case const (RepairLocation):
        _repairs[technic.dislocation]!.technics.map((element){
          if(technic.id == element.id){
            element.name = technic.name;
            element.dislocation = technic.dislocation;
            element.status = technic.status;
            element.comment = technic.comment;
            element.cost = technic.cost;
            element.dateBuyTechnic = technic.dateBuyTechnic;
          }
        });
      case const(StorageLocation):
        _storages[technic.dislocation]!.technics.map((element){
          if(technic.id == element.id){
            element.name = technic.name;
            element.dislocation = technic.dislocation;
            element.status = technic.status;
            element.comment = technic.comment;
            element.cost = technic.cost;
            element.dateBuyTechnic = technic.dateBuyTechnic;
          }
        });
    }
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
      Map<String, PhotosalonLocation> photosalons,
      Map<String, RepairLocation> repairs,
      Map<String, StorageLocation> storages,
      ) {
    _photosolons.clear();
    _repairs.clear();
    _storages.clear();
    _photosolons.addAll(photosalons);
    _repairs.addAll(repairs);
    _storages.addAll(storages);
    notifyListeners();
  }
}
