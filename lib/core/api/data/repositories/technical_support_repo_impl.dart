import 'package:mysql1/mysql1.dart';
import 'package:technical_support_artphoto/core/api/data/datasources/connect_db_my_sql.dart';
import 'package:technical_support_artphoto/core/api/data/models/photosalon_location.dart';
import 'package:technical_support_artphoto/core/api/data/models/repair_location.dart';
import 'package:technical_support_artphoto/core/api/data/models/storage_location.dart';
import 'package:technical_support_artphoto/core/api/data/models/user.dart';
import 'package:technical_support_artphoto/core/api/domain/repositories/technical_support_repo.dart';
import 'package:technical_support_artphoto/features/repairs/models/summ_repair.dart';
import 'package:technical_support_artphoto/features/technics/data/models/history_technic.dart';

import '../models/technic.dart';

class TechnicalSupportRepoImpl implements TechnicalSupportRepo{
  TechnicalSupportRepoImpl._();

  static final TechnicalSupportRepoImpl downloadData = TechnicalSupportRepoImpl._();

  @override
  Future<Map<String, dynamic>> getStartData() async {
    Map<String, dynamic> result = {};

    Map<String, PhotosalonLocation> photosalons = {};
    Map<String, RepairLocation> repairs = {};
    Map<String, StorageLocation> storages = {};

    /// CategoryDropDown
    List<String> namePhotosalons;
    List<String> nameEquipment;
    List<String> services;
    List<String> statusForEquipment;
    Map<String, int> colorsForEquipment;

    await ConnectDbMySQL.connDB.connDatabase();

    photosalons = await ConnectDbMySQL.connDB.fetchPhotosalons();
    repairs = await ConnectDbMySQL.connDB.fetchRepairsNow();
    storages = await ConnectDbMySQL.connDB.fetchStorages();

    namePhotosalons = await ConnectDbMySQL.connDB.fetchNamePhotosalons();
    namePhotosalons.addAll(await ConnectDbMySQL.connDB.fetchNameStorages());
    nameEquipment = await ConnectDbMySQL.connDB.fetchNameEquipment();
    services = await ConnectDbMySQL.connDB.fetchServices();
    statusForEquipment = await ConnectDbMySQL.connDB.fetchStatusForEquipment();
    colorsForEquipment = await ConnectDbMySQL.connDB.fetchColorsForEquipment();

    result['Photosalons'] = photosalons;
    result['Repairs'] = repairs;
    result['Storages'] = storages;

    result['namePhotosalons'] = namePhotosalons;
    result['nameEquipment'] = nameEquipment;
    result['services'] = services;
    result['statusForEquipment'] = statusForEquipment;
    result['colorsForEquipment'] = colorsForEquipment;

    await ConnectDbMySQL.connDB.dispose();
    return result;
  }

  @override
  Future<Map<String, dynamic>> refreshData() async {
    Map<String, dynamic> result = {};

    await ConnectDbMySQL.connDB.connDatabase();

    Map<String, PhotosalonLocation> photosalons = await ConnectDbMySQL.connDB.fetchPhotosalons();
    Map<String, RepairLocation> repairs = await ConnectDbMySQL.connDB.fetchRepairsNow();
    Map<String, StorageLocation> storages = await ConnectDbMySQL.connDB.fetchStorages();

    result['Photosalons'] = photosalons;
    result['Repairs'] = repairs;
    result['Storages'] = storages;

    await ConnectDbMySQL.connDB.dispose();
    return result;
  }

  @override
  Future<User?> getUser(String password) async{
    await ConnectDbMySQL.connDB.connDatabase();
    User? user;
    Results? result = await ConnectDbMySQL.connDB.fetchAccessLevel(password);
    if (result != null) {
      for (var row in result) {
        user = User(row[0], row[1]);
      }
    }
    await ConnectDbMySQL.connDB.dispose();
    return user;
  }

  @override
  Future<bool> checkNumberTechnic(String number) async{
    await ConnectDbMySQL.connDB.connDatabase();
    bool result = await ConnectDbMySQL.connDB.checkNumberTechnic(number);
    await ConnectDbMySQL.connDB.dispose();
    return result;
  }

  @override
  Future<bool> updateTechnic(Technic technic) async {
    try {
      await ConnectDbMySQL.connDB.connDatabase();
      await ConnectDbMySQL.connDB.updateTechnicInDB(technic);
      await ConnectDbMySQL.connDB.dispose();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Map<int, List<SummRepair>>> getSummsRepairs(String numberTechnic) async{
    await ConnectDbMySQL.connDB.connDatabase();
    Map<int, List<SummRepair>> summsRepairs = await ConnectDbMySQL.connDB.getSummsRepairs(numberTechnic);
    await ConnectDbMySQL.connDB.dispose();
    return summsRepairs;
  }

  Future<List<HistoryTechnic>> fetchHistoryTechnic(String? numberTechnic) async{
    if(numberTechnic != null){
      await ConnectDbMySQL.connDB.connDatabase();
      List<HistoryTechnic> historyList =  await ConnectDbMySQL.connDB.fetchHistoryTechnic(numberTechnic);
      await ConnectDbMySQL.connDB.dispose();
      return historyList;
    }else{
      return [];
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
//
//   DateTime? getDate(String date) {
//     if(date != '') {
//       return DateTime.parse(date.replaceAll('.', '-'));
//     }
//     return null;
//   }
//
//   String getDayAddition(int num) {
//     double preLastDigit = num % 100 / 10;
//     if (preLastDigit.round() == 1) {
//       return "дней";
//     }
//     switch (num % 10) {
//       case 1:
//         return "день";
//       case 2:
//       case 3:
//       case 4:
//         return "дня";
//       default:
//         return "дней";
//     }
//   }
}
