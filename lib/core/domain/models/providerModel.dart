import 'package:flutter/material.dart';
import 'package:technical_support_artphoto/core/domain/models/photosalon.dart';
import 'package:technical_support_artphoto/core/domain/models/repair.dart';
import 'package:technical_support_artphoto/core/domain/models/storage.dart';
import 'package:technical_support_artphoto/core/domain/models/technic.dart';

class ProviderModel with ChangeNotifier {
  late final Map<String, Photosalon> _photosolons;
  late final Map<String, Repair> _repairs;
  late final Map<String, Storage> _storages;
  final Map<String, String> user = {'user': 'not access'};

  Map<String, Photosalon> get photosolons => _photosolons;

  Map<String, Repair> get repairs => _repairs;

  Map<String, Storage> get storages => _storages;

  void downloadAllElements(
      Map<String, Photosalon> photosalons, Map<String, Repair> repairs, Map<String, Storage> storages) {
    _photosolons = photosalons;
    _repairs = repairs;
    _storages = storages;
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
}
