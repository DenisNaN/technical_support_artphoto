import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:technical_support_artphoto/core/api/data/datasources/connect_db_my_sql.dart';
import 'package:technical_support_artphoto/core/api/data/models/decommissioned.dart';
import 'package:technical_support_artphoto/core/api/data/models/free_number_for_technic.dart';
import 'package:technical_support_artphoto/core/api/data/models/photosalon_location.dart';
import 'package:technical_support_artphoto/core/api/data/models/repair_location.dart';
import 'package:technical_support_artphoto/core/api/data/models/storage_location.dart';
import 'package:technical_support_artphoto/core/api/data/models/trouble_account_mail_ru.dart';
import 'package:technical_support_artphoto/core/api/data/models/user.dart';
import 'package:technical_support_artphoto/core/api/domain/repositories/technical_support_repo.dart';
import 'package:technical_support_artphoto/features/repairs/models/summ_repair.dart';
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

    List<Repair> repairs = [];
    List<Trouble> troubles = [];

    /// CategoryDropDown
    List<String> namePhotosalons;
    List<String> nameEquipment;
    List<String> services;
    List<String> statusForEquipment;
    Map<String, int> colorsForEquipment;

    TroubleAccountMailRu? accountMailRu;

    await ConnectDbMySQL.connDB.connDatabase();

    technicsInPhotosalons = await ConnectDbMySQL.connDB.fetchTechnicsInPhotosalons();
    technicsInRepairs = await ConnectDbMySQL.connDB.fetchTechnicsInRepairs();
    technicsInStorages = await ConnectDbMySQL.connDB.fetchTechnicsInStorages();

    repairs = await ConnectDbMySQL.connDB.fetchCurrentRepairs();
    troubles = await ConnectDbMySQL.connDB.fetchTroubles();

    namePhotosalons = await ConnectDbMySQL.connDB.fetchNamePhotosalons();
    namePhotosalons.addAll(await ConnectDbMySQL.connDB.fetchNameStorages());
    nameEquipment = await ConnectDbMySQL.connDB.fetchNameEquipment();
    services = await ConnectDbMySQL.connDB.fetchServices();
    statusForEquipment = await ConnectDbMySQL.connDB.fetchStatusForEquipment();
    colorsForEquipment = await ConnectDbMySQL.connDB.fetchColorsForEquipment();

    accountMailRu = await ConnectDbMySQL.connDB.fetchAccountMailRu();

    result['Photosalons'] = technicsInPhotosalons;
    result['Repairs'] = technicsInRepairs;
    result['Storages'] = technicsInStorages;

    result['AllRepairs'] = repairs;
    result['AllTroubles'] = troubles;

    result['namePhotosalons'] = namePhotosalons;
    result['nameEquipment'] = nameEquipment;
    result['services'] = services;
    result['statusForEquipment'] = statusForEquipment;
    result['colorsForEquipment'] = colorsForEquipment;

    result['accountMailRu'] = accountMailRu;

    return result;
  }

  @override
  Future<Map<String, dynamic>> refreshTechnicsData() async {
    Map<String, dynamic> result = {};

    Map<String, PhotosalonLocation> photosalons = await ConnectDbMySQL.connDB.fetchTechnicsInPhotosalons();
    Map<String, RepairLocation> repairs = await ConnectDbMySQL.connDB.fetchTechnicsInRepairs();
    Map<String, StorageLocation> storages = await ConnectDbMySQL.connDB.fetchTechnicsInStorages();

    result['Photosalons'] = photosalons;
    result['Repairs'] = repairs;
    result['Storages'] = storages;

    return result;
  }

  @override
  Future<List<Repair>> refreshCurrentRepairsData() async{
    List<Repair> repairs = [];
    var result = await ConnectDbMySQL.connDB.fetchCurrentRepairs();
    repairs.addAll(result);
    return repairs;
  }

  @override
  Future<User?> getUser(String password) async{
    User? user;
    Results? result = await ConnectDbMySQL.connDB.fetchAccessLevel(password);
    if (result != null) {
      for (var row in result) {
        user = User(row[0], row[1]);
      }
    }
    return user;
  }

  @override
  Future<TroubleAccountMailRu?> getAccountMailRu() async{
    try {
      TroubleAccountMailRu? result = await ConnectDbMySQL.connDB.fetchAccountMailRu();
      return result;
    } catch (e) {
      return null;
    }

    // if (result != null) {
    //   for (var row in result) {
    //     user = User(row[0], row[1]);
    //   }
    // }
    // await ConnectDbMySQL.connDB.dispose();
    // return user;
  }

  @override
  Future<FreeNumbersForTechnic> checkNumberTechnic(String number) async{
    List<int> listFreeNumbers = [];

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
      }
      while (i < 3);
      return FreeNumbersForTechnic(isFreeNumber: isFeeNumber, freeNumbers: listFreeNumbers);
    }
  }

  @override
  Future<Technic?> getTechnic(String number) async{
    Technic? technic = await ConnectDbMySQL.connDB.getTechnic(int.parse(number));
    if (technic != null) {
      TestDrive? testDrive = await ConnectDbMySQL.connDB.fetchTestDrive(technic.id.toString());
      technic.testDrive = testDrive;
    }
    return technic;
  }

  @override
  Future<int?> saveTechnic(Technic technic, String nameUser) async{
    int? id;
    try {
      int id = await ConnectDbMySQL.connDB.insertTechnicInDB(technic, nameUser);
      return id;
    } catch (e) {
      return id;
    }
  }

  @override
  Future<bool> updateTechnic(Technic technic) async {
    try {
      await ConnectDbMySQL.connDB.updateTechnicInDB(technic);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> updateStatusAndDislocationTechnic(Technic technic, String userName) async {
    try {
      await ConnectDbMySQL.connDB.insertStatusInDB(technic.id, technic.status, technic.dislocation, userName);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Map<int, List<SumRepair>>> getSumRepairs(String numberTechnic) async{
    Map<int, List<SumRepair>> sumsRepairs = await ConnectDbMySQL.connDB.getSummsRepairs(numberTechnic);
    return sumsRepairs;
  }

  Future<List<HistoryTechnic>> fetchHistoryTechnic(String? numberTechnic) async{
    if(numberTechnic != null){
      List<HistoryTechnic> historyList =  await ConnectDbMySQL.connDB.fetchHistoryTechnic(numberTechnic);
      return historyList;
    }else{
      return [];
    }
  }

  @override
  Future<DecommissionedLocation> getTechnicsDecommissioned() async{
    DecommissionedLocation decommissioned;
    decommissioned =  await ConnectDbMySQL.connDB.fetchTechnicsDecommissioned();
    return decommissioned;
  }

  @override
  Future<List<Repair>> getFinishedRepairs() async{
    List<Repair> repairs = [];
    try{
      repairs.addAll(await ConnectDbMySQL.connDB.fetchFinishedRepairs());
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
      repair = await ConnectDbMySQL.connDB.fetchRepair(id);
      return repair;
    } catch (e) {
      return repair;
    }
  }

  @override
  Future<List<Repair>?> saveRepair(Repair repair) async{
    List<Repair>? repairs;
    try {
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
      if(isStepOne){
        await ConnectDbMySQL.connDB.updateRepairInDBStepOne(repair);
      }else{
        await ConnectDbMySQL.connDB.updateRepairInDBStepsTwoAndThree(repair);
      }
      var result = await ConnectDbMySQL.connDB.fetchCurrentRepairs();
      repairs = result;
      return repairs;
    } catch (e) {
      return repairs;
    }
  }

  @override
  Future<bool> deleteRepair(String id) async{
    try {
      await ConnectDbMySQL.connDB.deleteRepairInDB(id);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<Trouble>> getTroubles() async{
    List<Trouble> troubles = [];
    try {
      var result = await ConnectDbMySQL.connDB.fetchTroubles();
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
      var result = await ConnectDbMySQL.connDB.fetchTrouble(id);
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
      await ConnectDbMySQL.connDB.insertTroubleInDB(trouble);
      var result = await ConnectDbMySQL.connDB.fetchTroubles();
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
      await ConnectDbMySQL.connDB.updateTrouble(trouble);
      var result = await ConnectDbMySQL.connDB.fetchTroubles();
      troubles = result;
      return troubles;
    } catch (e) {
      return troubles;
    }
  }

  @override
  Future<bool> deleteTrouble(String id) async{
    try {
      await ConnectDbMySQL.connDB.deleteTroubleInDB(id);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<Trouble>> getFinishedTroubles() async{
    List<Trouble> troubles = [];
    try{
      troubles.addAll(await ConnectDbMySQL.connDB.fetchFinishedTroubles());
    } catch (e) {
      debugPrint(e.toString());
      return troubles;
    }
    return troubles;
  }

  @override
  Future<bool> saveTestDrive(TestDrive testDrive) async{
    try {
      await ConnectDbMySQL.connDB.insertTestDriveInDB(testDrive);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> updateTestDrive(TestDrive testDrive) async{
    try {
      await ConnectDbMySQL.connDB.updateTestDriveInDB(testDrive);
      return true;
    } catch (e) {
      return false;
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
