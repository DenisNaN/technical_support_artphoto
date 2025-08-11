import 'package:flutter/material.dart';
import 'package:mysql_client_plus/mysql_client_plus.dart';
import 'package:technical_support_artphoto/core/api/data/datasources/connect_db_my_sql.dart';
import 'package:technical_support_artphoto/core/api/data/models/decommissioned.dart';
import 'package:technical_support_artphoto/core/api/data/models/free_number_for_technic.dart';
import 'package:technical_support_artphoto/core/api/data/models/photosalon_location.dart';
import 'package:technical_support_artphoto/core/api/data/models/repair_location.dart';
import 'package:technical_support_artphoto/core/api/data/models/storage_location.dart';
import 'package:technical_support_artphoto/core/api/data/models/transportation_location.dart';
import 'package:technical_support_artphoto/core/api/data/models/trouble_account_mail_ru.dart';
import 'package:technical_support_artphoto/core/api/data/models/user.dart';
import 'package:technical_support_artphoto/core/api/domain/repositories/technical_support_repo.dart';
import 'package:technical_support_artphoto/features/repairs/models/summ_repair.dart';
import 'package:technical_support_artphoto/features/supplies/models/model_supplies.dart';
import 'package:technical_support_artphoto/features/supplies/presentation/pages/supplies.dart';
import 'package:technical_support_artphoto/features/technics/data/models/history_technic.dart';
import 'package:technical_support_artphoto/features/test_drive/models/test_drive.dart';
import 'package:technical_support_artphoto/features/troubles/models/trouble.dart';

import '../../../../features/repairs/models/repair.dart';
import '../../../../features/technics/models/technic.dart';

class TechnicalSupportRepoImpl implements TechnicalSupportRepo{
  TechnicalSupportRepoImpl._();

  static final TechnicalSupportRepoImpl downloadData = TechnicalSupportRepoImpl._();

  @override
  Future<Map<String, dynamic>> getStartData() async {
    Map<String, dynamic> result = {};

    Map<String, PhotosalonLocation> technicsInPhotosalons = {};
    Map<String, RepairLocation> technicsInRepairs = {};
    Map<String, StorageLocation> technicsInStorages = {};
    Map<String, TransportationLocation> technicsInTransportation = {};

    List<Repair> repairs = [];
    List<Trouble> troubles = [];
    ModelSupplies? suppliesGarage;
    ModelSupplies? suppliesOffice;

    /// CategoryDropDown
    List<String> namePhotosalons;
    List<String> nameEquipment;
    List<String> services;
    List<String> statusForEquipment;
    Map<String, int> colorsForEquipment;

    TroubleAccountMailRu? accountMailRu;
    List<String> users;

    await ConnectDbMySQL.connDB.connDatabase();

    technicsInPhotosalons = await ConnectDbMySQL.connDB.fetchTechnicsInPhotosalons();
    technicsInRepairs = await ConnectDbMySQL.connDB.fetchTechnicsInRepairs();
    technicsInStorages = await ConnectDbMySQL.connDB.fetchTechnicsInStorages();
    technicsInTransportation = await ConnectDbMySQL.connDB.fetchTechnicsInTransportation();

    repairs = await ConnectDbMySQL.connDB.fetchCurrentRepairs();
    troubles = await ConnectDbMySQL.connDB.fetchTroubles();
    suppliesGarage = await ConnectDbMySQL.connDB.fetchSuppliesGarage();
    suppliesOffice = await ConnectDbMySQL.connDB.fetchSuppliesOffice();

    namePhotosalons = await ConnectDbMySQL.connDB.fetchNamePhotosalons();
    namePhotosalons.addAll(await ConnectDbMySQL.connDB.fetchNameStorages());
    nameEquipment = await ConnectDbMySQL.connDB.fetchNameEquipment();
    services = await ConnectDbMySQL.connDB.fetchServices();
    statusForEquipment = await ConnectDbMySQL.connDB.fetchStatusForEquipment();
    colorsForEquipment = await ConnectDbMySQL.connDB.fetchColorsForEquipment();

    accountMailRu = await ConnectDbMySQL.connDB.fetchAccountMailRu();
    users = await TechnicalSupportRepoImpl.downloadData.getUsers();

    result['Photosalons'] = technicsInPhotosalons;
    result['Repairs'] = technicsInRepairs;
    result['Storages'] = technicsInStorages;
    result['Transportation'] = technicsInTransportation;

    result['AllRepairs'] = repairs;
    result['AllTroubles'] = troubles;

    result['suppliesGarage'] = suppliesGarage;
    result['suppliesOffice'] = suppliesOffice;

    result['namePhotosalons'] = namePhotosalons;
    result['nameEquipment'] = nameEquipment;
    result['services'] = services;
    result['statusForEquipment'] = statusForEquipment;
    result['colorsForEquipment'] = colorsForEquipment;

    result['accountMailRu'] = accountMailRu;
    result['users'] = users;

    // await ConnectDbMySQL.connDB.dispose();
    return result;
  }

  @override
  Future<Map<String, dynamic>> refreshTechnicsData() async {
    Map<String, dynamic> result = {};

    await ConnectDbMySQL.connDB.connDatabase();

    Map<String, PhotosalonLocation> photosalons = await ConnectDbMySQL.connDB.fetchTechnicsInPhotosalons();
    Map<String, RepairLocation> repairs = await ConnectDbMySQL.connDB.fetchTechnicsInRepairs();
    Map<String, StorageLocation> storages = await ConnectDbMySQL.connDB.fetchTechnicsInStorages();
    Map<String, TransportationLocation> transportation = await ConnectDbMySQL.connDB.fetchTechnicsInTransportation();

    result['Photosalons'] = photosalons;
    result['Repairs'] = repairs;
    result['Storages'] = storages;
    result['Transportation'] = transportation;

    // await ConnectDbMySQL.connDB.dispose();

    return result;
  }

  @override
  Future<List<Repair>> refreshCurrentRepairsData() async{
    List<Repair> repairs = [];
    await ConnectDbMySQL.connDB.connDatabase();
    var result = await ConnectDbMySQL.connDB.fetchCurrentRepairs();
    // await ConnectDbMySQL.connDB.dispose();
    repairs.addAll(result);
    return repairs;
  }

  @override
  Future<User?> getUser(String password) async{
    User? user;
    await ConnectDbMySQL.connDB.connDatabase();
    IResultSet? result = await ConnectDbMySQL.connDB.fetchAccessLevel(password);
    // await ConnectDbMySQL.connDB.dispose();
    if (result != null) {
      for (final row in result.rows) {
        user = User(row.colAt(0), row.colAt(1));
      }
    }
    return user;
  }

  @override
  Future<List<String>> getUsers() async{
    List<String> users = [];
    IResultSet? result = await ConnectDbMySQL.connDB.fetchUsers();
    if (result != null) {
      for (final row in result.rows) {
        users.add(row.colAt(0));
      }
    }
    return users;
  }

  @override
  Future<TroubleAccountMailRu?> getAccountMailRu() async{
    try {
      await ConnectDbMySQL.connDB.connDatabase();
      TroubleAccountMailRu? result = await ConnectDbMySQL.connDB.fetchAccountMailRu();
      // await ConnectDbMySQL.connDB.dispose();
      return result;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<FreeNumbersForTechnic> checkNumberTechnic(String number) async{
    List<int> listFreeNumbers = [];

    await ConnectDbMySQL.connDB.connDatabase();
    bool isFeeNumber = await ConnectDbMySQL.connDB.checkNumberTechnic(number);
    if(isFeeNumber){
      return FreeNumbersForTechnic(isFreeNumber: isFeeNumber, freeNumbers: listFreeNumbers);
    }else{
      int i = 0;
      int numberTechnic = int.parse(number);
      numberTechnic++;
      do{
        bool result = await ConnectDbMySQL.connDB.checkNumberTechnic(numberTechnic.toString());
        if(result){
          listFreeNumbers.add(numberTechnic);
          i++;
        }
        numberTechnic++;
      } while (i < 3);
      // await ConnectDbMySQL.connDB.dispose();
      return FreeNumbersForTechnic(isFreeNumber: isFeeNumber, freeNumbers: listFreeNumbers);
    }
  }

  @override
  Future<Technic?> getTechnic(String number) async{
    await ConnectDbMySQL.connDB.connDatabase();
    Technic? technic = await ConnectDbMySQL.connDB.getTechnic(int.parse(number));
    if (technic != null) {
      TestDrive? testDrive = await ConnectDbMySQL.connDB.fetchTestDrive(technic.id.toString());
      technic.testDrive = testDrive;
    }
    // await ConnectDbMySQL.connDB.dispose();
    return technic;
  }

  @override
  Future<int?> saveTechnic(Technic technic, String nameUser) async{
    int? id;
    try {
      await ConnectDbMySQL.connDB.connDatabase();
      int id = await ConnectDbMySQL.connDB.insertTechnicInDB(technic, nameUser);
      // await ConnectDbMySQL.connDB.dispose();
      return id;
    } catch (e) {
      return id;
    }
  }

  @override
  Future<bool> updateTechnic(Technic technic) async {
    try {
      await ConnectDbMySQL.connDB.connDatabase();
      await ConnectDbMySQL.connDB.updateTechnicInDB(technic);
      // await ConnectDbMySQL.connDB.dispose();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> updateStatusAndDislocationTechnic(Technic technic, String userName) async {
    try {
      await ConnectDbMySQL.connDB.connDatabase();
      await ConnectDbMySQL.connDB.insertStatusInDB(technic.id, technic.status, technic.dislocation, userName);
      // await ConnectDbMySQL.connDB.dispose();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Map<int, List<SumRepair>>> getSumRepairs(String numberTechnic) async{
    await ConnectDbMySQL.connDB.connDatabase();
    Map<int, List<SumRepair>> sumsRepairs = await ConnectDbMySQL.connDB.getSumsRepairs(numberTechnic);
    // await ConnectDbMySQL.connDB.dispose();
    return sumsRepairs;
  }

  Future<List<HistoryTechnic>> fetchHistoryTechnic(String? numberTechnic) async{
    if(numberTechnic != null){
      await ConnectDbMySQL.connDB.connDatabase();
      List<HistoryTechnic> historyList =  await ConnectDbMySQL.connDB.fetchHistoryTechnic(numberTechnic);
      // await ConnectDbMySQL.connDB.dispose();
      return historyList;
    }else{
      return [];
    }
  }

  @override
  Future<DecommissionedLocation> getTechnicsDecommissioned() async{
    DecommissionedLocation decommissioned;
    await ConnectDbMySQL.connDB.connDatabase();
    decommissioned =  await ConnectDbMySQL.connDB.fetchTechnicsDecommissioned();
    // await ConnectDbMySQL.connDB.dispose();
    // Future.delayed(Duration(seconds: 1));
    return decommissioned;
  }

  @override
  Future<List<Repair>> getFinishedRepairs() async{
    List<Repair> repairs = [];
    try{
      await ConnectDbMySQL.connDB.connDatabase();
      repairs.addAll(await ConnectDbMySQL.connDB.fetchFinishedRepairs());
      // await ConnectDbMySQL.connDB.dispose();
    } catch (e) {
      debugPrint(e.toString());
      return repairs;
    }
    return repairs;
  }

  @override
  Future<Repair?> getRepair(int id) async{
    Repair? repair;
    try {
      await ConnectDbMySQL.connDB.connDatabase();
      repair = await ConnectDbMySQL.connDB.fetchRepair(id);
      // await ConnectDbMySQL.connDB.dispose();
      return repair;
    } catch (e) {
      return repair;
    }
  }

  @override
  Future<List<Repair>?> saveRepair(Repair repair) async{
    List<Repair>? repairs;
    try {
      await ConnectDbMySQL.connDB.connDatabase();
      await ConnectDbMySQL.connDB.insertRepairInDB(repair);
      var result = await ConnectDbMySQL.connDB.fetchCurrentRepairs();
      repairs = result;
      return repairs;
        } catch (e) {
      return repairs;
    }
  }

  @override
  Future<List<Repair>?> updateRepair(Repair repair, bool isStepOne) async{
    List<Repair>? repairs;
    try {
      await ConnectDbMySQL.connDB.connDatabase();
      if(isStepOne){
        await ConnectDbMySQL.connDB.updateRepairInDBStepOne(repair);
      }else{
        await ConnectDbMySQL.connDB.updateRepairInDBStepsTwoAndThree(repair);
      }
      var result = await ConnectDbMySQL.connDB.fetchCurrentRepairs();
      // await ConnectDbMySQL.connDB.dispose();
      repairs = result;
      return repairs;
    } catch (e) {
      return repairs;
    }
  }

  @override
  Future<bool> deleteRepair(String id) async{
    try {
      await ConnectDbMySQL.connDB.connDatabase();
      await ConnectDbMySQL.connDB.deleteRepairInDB(id);
      // await ConnectDbMySQL.connDB.dispose();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<Trouble>> getTroubles() async{
    List<Trouble> troubles = [];
    try {
      await ConnectDbMySQL.connDB.connDatabase();
      var result = await ConnectDbMySQL.connDB.fetchTroubles();
      // await ConnectDbMySQL.connDB.dispose();
      troubles = result;
      return troubles;
    } catch (e) {
      return troubles;
    }
  }

  @override
  Future<Trouble?> getTrouble(String id) async{
    Trouble? trouble;
    try {
      await ConnectDbMySQL.connDB.connDatabase();
      var result = await ConnectDbMySQL.connDB.fetchTrouble(id);
      // await ConnectDbMySQL.connDB.dispose();
      trouble = result;
      return trouble;
    } catch (e) {
      return trouble;
    }
  }

  @override
  Future<List<Trouble>?> saveTrouble(Trouble trouble) async{
    List<Trouble>? troubles;
    try {
      await ConnectDbMySQL.connDB.connDatabase();
      await ConnectDbMySQL.connDB.insertTroubleInDB(trouble);
      var result = await ConnectDbMySQL.connDB.fetchTroubles();
      // await ConnectDbMySQL.connDB.dispose();
      troubles = result;
      return troubles;
    } catch (e) {
      return troubles;
    }
  }

  @override
  Future<List<Trouble>?> updateTrouble(Trouble trouble) async{
    List<Trouble>? troubles;
    try {
      await ConnectDbMySQL.connDB.connDatabase();
      await ConnectDbMySQL.connDB.updateTrouble(trouble);
      var result = await ConnectDbMySQL.connDB.fetchTroubles();
      // await ConnectDbMySQL.connDB.dispose();
      troubles = result;
      return troubles;
    } catch (e) {
      return troubles;
    }
  }

  @override
  Future<bool> deleteTrouble(String id) async{
    try {
      await ConnectDbMySQL.connDB.connDatabase();
      await ConnectDbMySQL.connDB.deleteTroubleInDB(id);
      // await ConnectDbMySQL.connDB.dispose();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<Trouble>> getFinishedTroubles() async{
    List<Trouble> troubles = [];
    try{
      await ConnectDbMySQL.connDB.connDatabase();
      troubles.addAll(await ConnectDbMySQL.connDB.fetchFinishedTroubles());
      // await ConnectDbMySQL.connDB.dispose();
    } catch (e) {
      debugPrint(e.toString());
      return troubles;
    }
    return troubles;
  }

  @override
  Future<bool> saveTestDrive(TestDrive testDrive) async{
    try {
      await ConnectDbMySQL.connDB.connDatabase();
      await ConnectDbMySQL.connDB.insertTestDriveInDB(testDrive);
      // await ConnectDbMySQL.connDB.dispose();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> updateTestDrive(TestDrive testDrive) async{
    try {
      await ConnectDbMySQL.connDB.connDatabase();
      await ConnectDbMySQL.connDB.updateTestDriveInDB(testDrive);
      // await ConnectDbMySQL.connDB.dispose();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Map<String, ModelSupplies>> refreshSuppliesData() async{
    Map<String, ModelSupplies> supplies = {};
    await ConnectDbMySQL.connDB.connDatabase();
    var result1 = await ConnectDbMySQL.connDB.fetchSuppliesGarage();
    if (result1 != null) {
      supplies['garage'] = result1;
    }
    var result2 = await ConnectDbMySQL.connDB.fetchSuppliesOffice();
    if (result2 != null) {
      supplies['office'] = result2;
    }
    return supplies;
  }

  @override
  Future<bool> saveSuppliesData() async{
    try {
      await ConnectDbMySQL.connDB.connDatabase();
      int id = await ConnectDbMySQL.connDB.insertTechnicInDB(technic, nameUser);
      // await ConnectDbMySQL.connDB.dispose();
      return id;
    } catch (e) {
      return id;
    }
  }

//   List getNotifications() {
//     List notifications = [];
//     notifications.addAll(getListNotificationsDontTestDriveAfterRepairBetter1Day());
//     notifications.addAll(getListNotificationsTechnicInRepairBetter21Days());
//     notifications.addAll(getListNotificationsTechnicTestDriveNotComplatedBetter14Days());
//     notifications.addAll(getListNotificationsTechnicBadAndNotInRepairBetter7Days());
//
//     return notifications;
//   }
//
//   List getListNotificationsDontTestDriveAfterRepairBetter1Day(){
//     List notifications = [];
//     // тест-драйв не сделан больше одного дня после ремонта для Копиров и Фотоаппаратов
//     Technic.technicList.forEach((technic) {
//         if (technic.category == 'Копир' || technic.category == 'Фотоаппарат'){
//           if(technic.status != 'Донор' && technic.status != 'Списана' && technic.status != 'Неисправна' && technic.status != 'В ремонте') {
//             Repair? repair = Repair.repairList.firstWhere((repair) => repair.internalID == technic.internalID, orElse: () => null);
//
//             bool isDateTransferInServiceAfterDateStartTestDriveTechnic = false;
//             if (repair != null && repair.dateDepartureFromService != '' && technic.dateStartTestDrive != '') {
//               isDateTransferInServiceAfterDateStartTestDriveTechnic = getDate(repair.dateDepartureFromService)!.
//               isBefore(getDate(technic.dateStartTestDrive)!);
//             }
//
//             if (repair != null && repair.dateDepartureFromService != '' &&
//                 repair.idTestDrive == 0 && !isDateTransferInServiceAfterDateStartTestDriveTechnic) {
//               Duration? duration = DateTime.now().difference(getDate(repair.dateDepartureFromService)!);
//               if (duration.inDays > 1) {
//                 notifications.add(Notifications(
//                   'Не сделан тест-драйв ${repair.category.trim()}а №${repair.internalID}. После ремонта прошло: ${duration.inDays} ${getDayAddition(
//                       duration.inDays)}',
//                   technic.id, 'Technic'));
//               }
//             }
//         }
//       }
//     });
//     return notifications;
//   }
//
//   List getListNotificationsTechnicInRepairBetter21Days() {
//     List notifications = [];
//     // техника в ремонте больше 21 дня
//     Technic.technicList.forEach((technic) {
//         Repair? repair = Repair.repairList.firstWhere((repair) =>
//         repair.internalID == technic.internalID, orElse: () => null);
//         if (repair != null && repair.dateDepartureFromService == '' && repair.dateTransferInService != '') {
//           Duration? duration = DateTime.now().difference(getDate(repair.dateTransferInService)!);
//           if (duration.inDays > 21) {
//             notifications.add(Notifications(
//                 'Техника ${repair.category.trim()} №${repair.internalID} в ремонте: ${duration
//                     .inDays} ${getDayAddition(duration.inDays)}', repair.id, 'Repair'));
//           }
//         }
//     });
//     return notifications;
//   }
//
//   List getListNotificationsTechnicTestDriveNotComplatedBetter14Days() {
//     List notifications = [];
//     // тест-драйв не завершен больше 14 дней
//     Technic.technicList.forEach((technic) {
//       if (technic.dateStartTestDrive != '' && technic.checkboxTestDrive == false) {
//         Duration? duration = DateTime.now().difference(getDate(technic.dateStartTestDrive)!);
//         if (duration.inDays > 14) {
//           notifications.add(Notifications(
//               'У техники ${technic.category.trim()} №${technic.internalID} тест-драйв не завершен: '
//                   '${duration.inDays} ${getDayAddition(duration.inDays)}', technic.id, 'Technic'));
//         }
//       }
//     });
//     return notifications;
//   }
//
//   List getListNotificationsTechnicBadAndNotInRepairBetter7Days() {
//     List notifications = [];
//     // техника неисправна и не в ремонте больше 7 дней
//     Technic.technicList.forEach((technic) {
//       if (technic.status == 'Неисправна' && technic.dateChangeStatus != '') {
//         Duration? duration = DateTime.now().difference(getDate(technic.dateChangeStatus)!);
//         if (duration.inDays > 7) {
//           notifications.add(Notifications(
//               'Техника ${technic.category.trim()} №${technic.internalID} неисправна и не в ремонте: '
//                   '${duration.inDays} ${getDayAddition(duration.inDays)}', technic.id, 'Technic'));
//         }
//       }
//     });
//     return notifications;
//   }
}
