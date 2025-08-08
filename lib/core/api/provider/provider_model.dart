import 'package:flutter/material.dart';
import 'package:technical_support_artphoto/core/api/data/models/location.dart';
import 'package:technical_support_artphoto/core/api/data/models/photosalon_location.dart';
import 'package:technical_support_artphoto/core/api/data/models/repair_location.dart';
import 'package:technical_support_artphoto/core/api/data/models/storage_location.dart';
import 'package:technical_support_artphoto/core/api/data/models/transportation_location.dart';
import 'package:technical_support_artphoto/core/api/data/models/trouble_account_mail_ru.dart';
import 'package:technical_support_artphoto/features/supplies/models/model_supplies.dart';
import 'package:technical_support_artphoto/features/technics/models/technic.dart';
import 'package:technical_support_artphoto/features/troubles/models/trouble.dart';
import '../../../features/repairs/models/repair.dart';
import '../data/models/user.dart';

class ProviderModel with ChangeNotifier {
  late final Map<String, PhotosalonLocation> _technicsInPhotosalons;
  late final Map<String, RepairLocation> _technicsInRepairs;
  late final Map<String, StorageLocation> _technicsInStorages;
  late final Map<String, TransportationLocation> _technicsInTransportation;

  late final List<Repair> _currentRepairs;
  bool _isChangeRedAndYellow = false;

  late final List<Trouble> _troubles;

  late ModelSupplies _suppliesGarage;
  late ModelSupplies _suppliesOffice;

  late final List<String> _namesEquipments;
  late final List<String> _namesDislocations;
  late final List<String> _services;
  late final List<String> _statusForEquipment;
  late final Map<String, int> _colorsForEquipment;

  late User _user = User('user', 'access');
  late final List<String> _users;

  late TroubleAccountMailRu _accountMailRu;

  int currentPageIndexMainBottomAppBar = 0;
  Size? _mainBottomSize;
  final Color colorPhotosalons = Colors.blue.shade200;
  final Color colorStorages = Colors.white70;
  final Color colorRepairs = Colors.yellow.shade200;
  final Color colorTransport = Colors.deepPurple.shade50;

  Map<String, PhotosalonLocation> get technicsInPhotosalons => _technicsInPhotosalons;

  Map<String, RepairLocation> get technicsInRepairs => _technicsInRepairs;

  Map<String, StorageLocation> get technicsInStorages => _technicsInStorages;

  Map<String, TransportationLocation> get technicsInTransportation => _technicsInTransportation;

  List<Repair> get getCurrentRepairs => _currentRepairs;

  bool get isChangeRedAndYellow => _isChangeRedAndYellow;

  List<Trouble> get getTroubles => _troubles;

  ModelSupplies get getSuppliesGarage => _suppliesGarage;

  ModelSupplies get getSuppliesOffice => _suppliesOffice;

  List<String> get namesDislocation => _namesDislocations;

  List<String> get services => _services;

  List<String> get statusForEquipment => _statusForEquipment;

  Map<String, int> get colorsForEquipment => _colorsForEquipment;

  List<String> get namesEquipments => _namesEquipments;

  User get user => _user;

  List<String> get users => _users;

  TroubleAccountMailRu get accountMailRu => _accountMailRu;

  Size? get mainBottomSize => _mainBottomSize;

  void downloadAllElements(Map<String, PhotosalonLocation> photosalons, Map<String, RepairLocation> repairs,
      Map<String, StorageLocation> storages, Map<String, TransportationLocation> transportation) {
    _technicsInPhotosalons = photosalons;
    _technicsInRepairs = repairs;
    _technicsInStorages = storages;
    _technicsInTransportation = transportation;
  }

  void initUser(User initUser) {
    _user = initUser;
  }

  void initUsers(List<String> users){
    _users = users;
  }

  void initAccountMailRu(TroubleAccountMailRu? troubleAccountMailRu) {
    if(troubleAccountMailRu != null){
      _accountMailRu = troubleAccountMailRu;
    }else{
      _accountMailRu = TroubleAccountMailRu(id: 0, name: 'name', account: 'account', password: 'password');
    }
  }

  void downloadCurrentRepairs(List<Repair> repairs) {
    _currentRepairs = [];
    sortListCurrentRepairs(repairs);
  }

  void downloadTroubles(List<Trouble> troubles) {
    _troubles = troubles;
  }

  void refreshTroubles(List<Trouble> troubles) {
    _troubles.clear();
    _troubles.addAll(troubles);
    notifyListeners();
  }

  void downloadSuppliesGarage(ModelSupplies model) {
    _suppliesGarage = model;
  }

  void downloadSuppliesOffice(ModelSupplies model) {
    _suppliesOffice = model;
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
      case const (TransportationLocation):
        _technicsInTransportation[technic.dislocation]!.technics.map((element) {
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

  void addRepairInCurrentRepairs(Repair repair) {
    _currentRepairs.add(repair);
    sortListCurrentRepairs(_currentRepairs);
    notifyListeners();
  }

  void removeRepairInCurrentRepairs(Repair repair) {
    _currentRepairs.remove(repair);
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

  void removeTroubleInTroubles(Trouble trouble) {
    _troubles.remove(trouble);
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
    Map<String, TransportationLocation> transport,
  ) {
    _technicsInPhotosalons.clear();
    _technicsInRepairs.clear();
    _technicsInStorages.clear();
    _technicsInTransportation.clear();
    _technicsInPhotosalons.addAll(photosalons);
    _technicsInRepairs.addAll(repairs);
    _technicsInStorages.addAll(storages);
    _technicsInTransportation.addAll(transport);
    notifyListeners();
  }

  void refreshCurrentRepairs(List<Repair> repairs) {
    sortListCurrentRepairs(repairs, _isChangeRedAndYellow);
    notifyListeners();
  }

  void sortListCurrentRepairs(List<Repair> repairs, [bool isChangeRedAndYellow = false]){
    List<Repair> filterRepairs = [];
    List<Repair> tmpRedList = [];
    List<Repair> tmpYellowList = [];
    for(int i = 0; i < repairs.length; i++){
      if(repairs[i].serviceDislocation == '' || repairs[i].serviceDislocation == null ||
          repairs[i].dateTransferInService.toString() == "-0001-11-30 00:00:00.000" ||
          repairs[i].dateTransferInService.toString() == "0001-11-30 00:00:00.000"){
        tmpRedList.add(repairs[i]);
      }else{
        tmpYellowList.add(repairs[i]);
      }
    }
    tmpYellowList.sort();
    tmpRedList.sort();
    if(!isChangeRedAndYellow){
      filterRepairs.addAll(tmpRedList);
      filterRepairs.addAll(tmpYellowList);
    }else{
      filterRepairs.addAll(tmpYellowList);
      filterRepairs.addAll(tmpRedList);
    }

    _currentRepairs.clear();
    _currentRepairs.addAll(filterRepairs);
  }

  void refreshSupplies(Map<String, ModelSupplies> supplies) {
    _suppliesGarage = supplies['garage']!;
    _suppliesOffice = supplies['office']!;
    notifyListeners();
  }

  bool setChangeRedAndYellow(){
    return _isChangeRedAndYellow = !_isChangeRedAndYellow;
  }

  void manualNotifyListeners(){
    notifyListeners();
  }

  void setSizeMainBottom(Size? size) {
    _mainBottomSize = size;
  }
}
