import 'package:flutter/material.dart';
import 'package:technical_support_artphoto/core/domain/models/photosalon.dart';
import 'package:technical_support_artphoto/core/domain/models/repair.dart';
import 'package:technical_support_artphoto/core/domain/models/storage.dart';
import 'package:technical_support_artphoto/core/domain/models/technic.dart';

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

  void downloadAllElements(
      Map<String, Photosalon> photosalons, Map<String, Repair> repairs, Map<String, Storage> storages) {
    _photosolons = photosalons;
    _repairs = repairs;
    _storages = storages;
  }

  void downloadAllCategoryDropDown(List<String> namesEquipments, List<String> namePhotosalons, List<String> services,
      List<String> statusForEquipment, Map<String, int> colorsForEquipment) {
    _namesEquipments = namesEquipments;
    _namesPhotosalons = namePhotosalons;
    _services = services;
    _statusForEquipment = statusForEquipment;
    _colorsForEquipment = colorsForEquipment;
  }

  void addTechnicInPhotosalon(String name, Technic technic) {
    _photosolons[name]!.technicals.add(technic);
    notifyListeners();
  }

  void addTechnicInRepair(String name, Technic technic) {
    _repairs[name]!.technicals.add(technic);
    notifyListeners();
  }

  void addTechnicInStorage(String name, Technic technic) {
    _storages[name]!.technicals.add(technic);
    notifyListeners();
  }

  void removeTechnicInPhotosalon(String name, Technic technic) {
    _photosolons[name]!.technicals.remove(technic);
    notifyListeners();
  }

  void removeTechnicInRepair(String name, Technic technic) {
    _repairs[name]!.technicals.remove(technic);
    notifyListeners();
  }

  void removeTechnicInStorage(String name, Technic technic) {
    _storages[name]!.technicals.remove(technic);
    notifyListeners();
  }

  void changeCurrentPageMainBottomAppBar(int index){
    currentPageIndexMainBottomAppBar = index;
    notifyListeners();
  }
}
