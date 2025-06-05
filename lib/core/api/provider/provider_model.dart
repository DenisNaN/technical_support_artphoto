import 'package:flutter/material.dart';
import 'package:technical_support_artphoto/core/api/data/models/location.dart';
import 'package:technical_support_artphoto/core/api/data/models/photosalon_location.dart';
import 'package:technical_support_artphoto/core/api/data/models/repair_location.dart';
import 'package:technical_support_artphoto/core/api/data/models/storage_location.dart';
import 'package:technical_support_artphoto/core/api/data/models/technic.dart';
import '../../../features/repairs/models/repair.dart';
import '../data/models/user.dart';

class ProviderModel with ChangeNotifier {
  late final Map<String, PhotosalonLocation> _technicsInPhotosalons;
  late final Map<String, RepairLocation> _technicsInRepairs;
  late final Map<String, StorageLocation> _technicsInStorages;

  late final List<Repair> _repairs;

  late final List<String> _namesEquipments;
  late final List<String> _namesDislocations;
  late final List<String> _services;
  late final List<String> _statusForEquipment;
  late final Map<String, int> _colorsForEquipment;

  late User _user = User('user', 'access');

  int currentPageIndexMainBottomAppBar = 0;
  Size? _mainBottomSize;
  final Color colorPhotosalons = Colors.blue.shade200;
  final Color colorStorages = Colors.white70;
  final Color colorRepairs = Colors.yellow.shade200;

  Map<String, PhotosalonLocation> get technicsInPhotosalons => _technicsInPhotosalons;

  Map<String, RepairLocation> get technicsInRepairs => _technicsInRepairs;

  Map<String, StorageLocation> get technicsInStorages => _technicsInStorages;

  List<Repair> get getAllRepairs => _repairs;

  List<String> get namesDislocation => _namesDislocations;

  List<String> get services => _services;

  List<String> get statusForEquipment => _statusForEquipment;

  Map<String, int> get colorsForEquipment => _colorsForEquipment;

  List<String> get namesEquipments => _namesEquipments;

  User get user => _user;

  Size? get mainBottomSize => _mainBottomSize;

  void downloadAllElements(Map<String, PhotosalonLocation> photosalons, Map<String, RepairLocation> repairs,
      Map<String, StorageLocation> storages) {
    _technicsInPhotosalons = photosalons;
    _technicsInRepairs = repairs;
    _technicsInStorages = storages;
  }

  void initUser(User initUser) {
    _user = initUser;
  }

  void downloadRepairs(List<Repair> repairs) {
    _repairs = [];
    sortListRepairs(repairs);
  }

  void downloadAllCategoryDropDown(List<String> namesEquipments, List<String> namePhotosalons, List<String> services,
      List<String> statusForEquipment, Map<String, int> colorsForEquipment) {
    _namesEquipments = namesEquipments;
    _namesDislocations = namePhotosalons;
    _services = services;
    _statusForEquipment = statusForEquipment;
    _colorsForEquipment = colorsForEquipment;
  }

  void addTechnicInPhotosalon(String name, Technic technic) {
    _technicsInPhotosalons[name]!.technics.add(technic);
    notifyListeners();
  }

  void updateTechnicInProvider(dynamic location, Technic technic) {
    switch (Location) {
      case const (PhotosalonLocation):
        _technicsInPhotosalons[technic.dislocation]!.technics.map((element) {
          if (technic.id == element.id) {
            element.name = technic.name;
            element.dislocation = technic.dislocation;
            element.status = technic.status;
            element.comment = technic.comment;
            element.cost = technic.cost;
            element.dateBuyTechnic = technic.dateBuyTechnic;
          }
        });
      case const (RepairLocation):
        _technicsInRepairs[technic.dislocation]!.technics.map((element) {
          if (technic.id == element.id) {
            element.name = technic.name;
            element.dislocation = technic.dislocation;
            element.status = technic.status;
            element.comment = technic.comment;
            element.cost = technic.cost;
            element.dateBuyTechnic = technic.dateBuyTechnic;
          }
        });
      case const (StorageLocation):
        _technicsInStorages[technic.dislocation]!.technics.map((element) {
          if (technic.id == element.id) {
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

  void updateRepairInProvider(Repair repair) {
    _repairs.map((element) {
      if (element.id == repair.id) {
        element.numberTechnic == repair.numberTechnic;
        element.costService == repair.costService;
        element.worksPerformed == repair.worksPerformed;
        element.dateDepartureFromService == repair.dateDepartureFromService;
        element.dateTransferInService == repair.dateTransferInService;
        element.dateReceipt == repair.dateReceipt;
        element.category == repair.category;
        element.complaint == repair.complaint;
        element.diagnosisService == repair.diagnosisService;
        element.dislocationOld == repair.dislocationOld;
        element.idTestDrive == repair.idTestDrive;
        element.dateDeparture == repair.dateDeparture;
        element.newDislocation == repair.newDislocation;
        element.newStatus == repair.newStatus;
        element.recommendationsNotes == repair.recommendationsNotes;
        element.serviceDislocation == repair.serviceDislocation;
        element.status == repair.status;
      }
    });
  }

  void updateUser(User newUser) {
    _user = newUser;
    notifyListeners();
  }

  void addTechnicInRepair(String name, Technic technic) {
    _technicsInRepairs[name]!.technics.add(technic);
    notifyListeners();
  }

  void addTechnicInStorage(String name, Technic technic) {
    _technicsInStorages[name]!.technics.add(technic);
    notifyListeners();
  }

  void addRepairInRepairs(Repair repair) {
    _repairs.add(repair);
    sortListRepairs(_repairs);
    notifyListeners();
  }

  void removeRepairInRepairs(Repair repair) {
    _repairs.remove(repair);
    notifyListeners();
  }

  void removeTechnicInPhotosalon(String name, Technic technic) {
    _technicsInPhotosalons[name]!.technics.remove(technic);
    notifyListeners();
  }

  void removeTechnicInRepair(String name, Technic technic) {
    _technicsInRepairs[name]!.technics.remove(technic);
    notifyListeners();
  }

  void removeTechnicInStorage(String name, Technic technic) {
    _technicsInStorages[name]!.technics.remove(technic);
    notifyListeners();
  }

  void changeCurrentPageMainBottomAppBar(int index) {
    currentPageIndexMainBottomAppBar = index;
    notifyListeners();
  }

  void refreshTechnics(
    Map<String, PhotosalonLocation> photosalons,
    Map<String, RepairLocation> repairs,
    Map<String, StorageLocation> storages,
  ) {
    _technicsInPhotosalons.clear();
    _technicsInRepairs.clear();
    _technicsInStorages.clear();
    _technicsInPhotosalons.addAll(photosalons);
    _technicsInRepairs.addAll(repairs);
    _technicsInStorages.addAll(storages);
    notifyListeners();
  }

  void refreshRepairs(List<Repair> repairs) {
    sortListRepairs(repairs);
    notifyListeners();
  }

  void sortListRepairs(List<Repair> repairs){
    List<Repair> filterRepairs = [];
    List<Repair> tmpRedList = [];
    List<Repair> tmpYellowList = [];

    for(int i = 0; i < repairs.length; i++){
      if(repairs[i].serviceDislocation == ''){
        tmpRedList.add(repairs[i]);
      }else{
        tmpYellowList.add(repairs[i]);
      }
    }
    tmpYellowList.sort();
    tmpRedList.sort();
    filterRepairs.addAll(tmpRedList);
    filterRepairs.addAll(tmpYellowList);

    _repairs.clear();
    _repairs.addAll(filterRepairs);
  }

  void setSizeMainBottom(Size? size) {
    _mainBottomSize = size;
  }
}
