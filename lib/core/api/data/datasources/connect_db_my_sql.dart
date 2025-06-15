import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mysql1/mysql1.dart';
import 'package:technical_support_artphoto/core/api/data/models/photosalon_location.dart';
import 'package:technical_support_artphoto/core/api/data/models/repair_location.dart';
import 'package:technical_support_artphoto/core/api/data/models/storage_location.dart';
import 'package:technical_support_artphoto/core/api/data/models/trouble_account_mail_ru.dart';
import 'package:technical_support_artphoto/core/utils/extension.dart';
import 'package:technical_support_artphoto/features/history/history.dart';
import 'package:technical_support_artphoto/features/repairs/models/repair.dart';
import 'package:technical_support_artphoto/features/repairs/models/summ_repair.dart';
import 'package:technical_support_artphoto/features/technics/data/models/history_technic.dart';
import 'package:technical_support_artphoto/features/technics/data/models/trouble_technic_on_period.dart';
import 'package:technical_support_artphoto/features/troubles/models/trouble.dart';
import '../models/decommissioned.dart';
import '../../../../features/technics/models/technic.dart';

class ConnectDbMySQL {
  ConnectDbMySQL._();

  static final ConnectDbMySQL connDB = ConnectDbMySQL._();
  MySqlConnection? _connDB;

  Future connDatabase() async {
    _connDB = await _init();
  }

  Future<void> dispose() async {
    await _connDB?.close();
  }

  Future<MySqlConnection> _init() async {
    MySqlConnection connDB = await MySqlConnection.connect(ConnectionSettings(
        host: dotenv.env['HOST'] ?? '',
        port: int.tryParse(dotenv.env['PORT'] ?? '0') ?? 0,
        user: dotenv.env['USER'],
        password: dotenv.env['PASSWORD'],
        db: dotenv.env['DB']));
    return connDB;
  }

  Future<Results?> fetchAccessLevel(String password) async {
    return await _connDB!.query('SELECT login, access FROM loginPassword WHERE password = $password');
  }

  Future<Map<String, PhotosalonLocation>> fetchTechnicsInPhotosalons() async {
    Map<String, PhotosalonLocation> photosalons = {};
    List<String> namesPhotosalons = await fetchNamePhotosalons();

    for (var namePhotosalon in namesPhotosalons) {
      PhotosalonLocation photosalon = PhotosalonLocation(namePhotosalon);
      String query = 'SELECT '
          'equipment.id, '
          'equipment.number, '
          'equipment.category, '
          'equipment.name, '
          's.status, '
          's.dislocation, '
          'equipment.dateBuy, '
          'equipment.cost, '
          'equipment.comment '
          'FROM equipment '
          'LEFT JOIN (SELECT * FROM statusEquipment s1 WHERE NOT EXISTS (SELECT 1 FROM statusEquipment s2 WHERE s2.id > s1.id AND s2.idEquipment = s1.idEquipment)) s ON s.idEquipment = equipment.id '
          'WHERE s.dislocation = "$namePhotosalon" AND s.status <> "Списана" '
          'ORDER BY equipment.number ASC';
      var result = await _connDB!.query(query);
      for (var row in result) {
        Technic technic = Technic(row[0], row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8]);
        photosalon.technics.add(technic);
      }
      photosalons[namePhotosalon] = photosalon;
    }
    return photosalons;
  }

  Future<Map<String, RepairLocation>> fetchTechnicsInRepairs() async {
    Map<String, RepairLocation> repairs = {};
    List<String> namesRepairs = await fetchNameRepairs();

    for (var nameRepair in namesRepairs) {
      RepairLocation repair = RepairLocation(nameRepair);
      String query = 'SELECT equipment.id, '
          'equipment.number, '
          'equipment.category, '
          'equipment.name, '
          's.status, '
          's.dislocation, '
          'equipment.dateBuy, '
          'equipment.cost, '
          'equipment.comment '
          'FROM equipment '
          'LEFT JOIN (SELECT * FROM statusEquipment s1 WHERE NOT EXISTS (SELECT 1 FROM statusEquipment s2 WHERE s2.id > s1.id AND s2.idEquipment = s1.idEquipment)) s ON s.idEquipment = equipment.id '
          'WHERE s.dislocation = "$nameRepair" '
          'ORDER BY equipment.number ASC';
      var result = await _connDB!.query(query);
      for (var row in result) {
        Technic technic = Technic(row[0], row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8]);
        repair.technics.add(technic);
      }
      repairs[nameRepair] = repair;
    }
    return repairs;
  }

  Future<Map<String, StorageLocation>> fetchTechnicsInStorages() async {
    Map<String, StorageLocation> storages = {};
    List<String> namesStorages = await fetchNameStorages();

    for (var nameStorage in namesStorages) {
      StorageLocation storage = StorageLocation(nameStorage);
      String query = 'SELECT equipment.id, '
          'equipment.number, '
          'equipment.category, '
          'equipment.name, '
          's.status, '
          's.dislocation, '
          'equipment.dateBuy, '
          'equipment.cost, '
          'equipment.comment '
          'FROM equipment '
          'LEFT JOIN (SELECT * FROM statusEquipment s1 WHERE NOT EXISTS (SELECT 1 FROM statusEquipment s2 WHERE s2.id > s1.id AND s2.idEquipment = s1.idEquipment)) s ON s.idEquipment = equipment.id '
          'WHERE s.dislocation = "$nameStorage" AND s.status <> "Списана" '
          'ORDER BY equipment.number ASC';
      var result = await _connDB!.query(query);
      for (var row in result) {
        Technic technic = Technic(row[0], row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8]);
        storage.technics.add(technic);
      }
      storages[nameStorage] = storage;
    }
    return storages;
  }

  Future<DecommissionedLocation> fetchTechnicsDecommissioned () async {
    DecommissionedLocation decommissionedTechnics = DecommissionedLocation('Списанная техника');
    String query = 'SELECT equipment.id, '
        'equipment.number, '
        'equipment.category, '
        'equipment.name, '
        's.status, '
        's.dislocation, '
        'equipment.dateBuy, '
        'equipment.cost, '
        'equipment.comment '
        'FROM equipment '
        'LEFT JOIN (SELECT * FROM statusEquipment s1 WHERE NOT EXISTS (SELECT 1 FROM statusEquipment s2 WHERE s2.id > s1.id AND s2.idEquipment = s1.idEquipment)) s ON s.idEquipment = equipment.id '
        'WHERE s.status = "Списана" '
        'ORDER BY equipment.number ASC';
    var result = await _connDB!.query(query);
    for (var row in result) {
      Technic technic = Technic(row[0], row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8]);
      decommissionedTechnics.technics.add(technic);
    }
    return decommissionedTechnics;
  }

  Future<List<String>> fetchNamePhotosalons() async {
    var result = await _connDB!.query('SELECT Фотосалон FROM Фотосалоны');

    List<String> photosalons = [];
    for (var row in result) {
      if (row[0] != 'Склад' && row[0] != 'Офис') {
        photosalons.add(row[0]);
      }
    }
    return photosalons;
  }

  Future<List<String>> fetchNameRepairs() async {
    var result = await _connDB!.query('SELECT repairmen FROM service');

    List<String> repairs = [];
    for (var row in result) {
      repairs.add(row[0]);
    }
    return repairs;
  }

  Future<List<String>> fetchNameStorages() async {
    var result = await _connDB!.query('SELECT storage FROM storages');

    List<String> storages = [];
    for (var row in result) {
      storages.add(row[0]);
    }
    return storages;
  }

  Future<bool> checkNumberTechnic(String number) async {
    var result = await _connDB!.query('SELECT 1 FROM equipment WHERE number = $number');
    return result.isEmpty;
  }

  Future<int> insertTechnicInDB(Technic technic, String nameUser) async {
    var result = await _connDB!.query(
        'INSERT INTO equipment (number, category, name, dateBuy, cost, comment, user) VALUES (?, ?, ?, ?, ?, ?, ?)', [
      technic.number,
      technic.category,
      technic.name,
      technic.dateBuyTechnic.dateFormattedForSQL(),
      technic.cost,
      technic.comment,
      nameUser
    ]);

    int id = result.insertId!;
    await insertStatusInDB(id, technic.status, technic.dislocation, nameUser);
    return result.insertId!;
  }

  Future insertStatusInDB(int id, String status, String dislocation, String nameUser) async {
    await _connDB!.query(
        'INSERT INTO statusEquipment (idEquipment, status, dislocation, date, user) VALUES (?, ?, ?, ?, ?)',
        [id, status, dislocation, DateTime.now().dateFormattedForSQL(), nameUser]);
  }

  // Future insertTestDriveInDB(Technic technic, String nameUser) async {
  //   await ConnectDbMySQL.connDB.connDatabase();
  //   await _connDB!.query(
  //       'INSERT INTO testDrive (idEquipment, category, testDriveDislocation, dateStart, dateFinish, result, '
  //       'checkEquipment, user) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
  //       [
  //         technic.id,
  //         technic.category,
  //         technic.testDriveDislocation,
  //         technic.dateStartTestDrive,
  //         technic.dateFinishTestDrive,
  //         technic.resultTestDrive,
  //         technic.checkboxTestDrive,
  //         nameUser
  //       ]);
  //
  //   int idLastTestDrive = await findIDLastTestDriveTechnic(technic);
  //   int idLastRepair = await findLastRepair(technic);
  //   await _connDB!.query('UPDATE repairEquipment SET idTestDrive = ? WHERE id = ?', [idLastTestDrive, idLastRepair]);
  // }

  // Future<int> findIDLastTestDriveTechnic(TechnicModel technic) async {
  //   await ConnectDbMySQL.connDB.connDatabase();
  //   var result =
  //       await _connDB!.query('SELECT id FROM testDrive WHERE idEquipment = ? ORDER BY id DESC LIMIT 1', [technic.id]);
  //   int id = lastTectDriveListFromMap(result);
  //   return id;
  // }

  // int lastTectDriveListFromMap(var result) {
  //   int id = -1;
  //   for (var row in result) {
  //     id = row[0];
  //   }
  //   return id;
  // }

  Future insertHistory(History history) async {
    await _connDB!.query(
        'INSERT INTO history ('
        'section, idSection, typeOperation, description, login, date) '
        'VALUES (?, ?, ?, ?, ?, ?)',
        [
          history.section,
          history.idSection,
          history.typeOperation,
          history.description,
          history.login,
          history.date,
        ]);
  }

  Future<List<String>> fetchStatusForEquipment() async {
    var result = await _connDB!.query('SELECT '
        'statusForEquipment.id, '
        'statusForEquipment.status '
        'FROM statusForEquipment');

    List<String> list = [];
    for (var row in result) {
      list.add(row[1].toString());
    }
    return list;
  }

  Future<List<String>> fetchServices() async {
    var result = await _connDB!.query('SELECT '
        'service.id, '
        'service.repairmen '
        'FROM service');

    List<String> list = [];
    for (var row in result) {
      list.add(row[1].toString());
    }
    return list;
  }

  Future<List<String>> fetchNameEquipment() async {
    var result = await _connDB!.query('SELECT '
        'nameEquipment.id, '
        'nameEquipment.name '
        'FROM nameEquipment');

    List<String> list = [];
    for (var row in result) {
      list.add(row[1].toString());
    }
    return list;
  }

  Future<Map<String, int>> fetchColorsForEquipment() async {
    var result = await _connDB!.query('SELECT * FROM colorsForPhotosalons');

    Map<String, int> map = {};
    for (var row in result) {
      map[row[1]] = int.parse(row[2]);
    }
    return map;
  }

  Future<TroubleAccountMailRu?> fetchAccountMailRu() async {
    TroubleAccountMailRu? accountMailRu;
    var result = await _connDB!.query('SELECT * FROM tmp_account');
    for (var row in result) {
      accountMailRu = TroubleAccountMailRu(id: row[0], name: row[1], account: row[2], password: row[3]);
    }
    return accountMailRu;
  }

Future<Technic?> getTechnic(int number) async {
  Technic? technic;
  String query = 'SELECT '
      'equipment.id, '
      'equipment.number, '
      'equipment.category, '
      'equipment.name, '
      's.status, '
      's.dislocation, '
      'equipment.dateBuy, '
      'equipment.cost, '
      'equipment.comment '
      'FROM equipment '
      'LEFT JOIN (SELECT * FROM statusEquipment s1 WHERE NOT EXISTS (SELECT 1 FROM statusEquipment s2 WHERE s2.id > s1.id AND s2.idEquipment = s1.idEquipment)) s ON s.idEquipment = equipment.id '
      'WHERE equipment.number = ? '
      'ORDER BY equipment.number ASC';
  var result = await _connDB!.query(query, [number]);
  for (var row in result) {
    technic = Technic(row[0], row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8]);
  }
  return technic;
}

// Future<List> getAllTestDrive() async {
//   List list = [];
//   var result = await _connDB!.query('SELECT * FROM testDrive');
//   // id-row[0], idEquipment-row[1],  category-row[2],  testDriveDislocation-row[3],
//   // dateStart-row[4], dateFinish-row[5], result-row[6], checkEquipment-row[7], user-row[8]
//
//   for(var row in result){
//     String dateStartTestDrive = '';
//     if(row[4] != null && row[4].toString() != "-0001-11-30 00:00:00.000Z") dateStartTestDrive = getDateFormatted(row[4].toString());
//     String dateFinishTestDrive = '';
//     if(row[5] != null && row[5].toString() != "-0001-11-30 00:00:00.000Z") dateFinishTestDrive = getDateFormatted(row[5].toString());
//     bool checkTestDrive = false;
//     if(row[7] != null && row[7] == 1) checkTestDrive = true;
//
//     Technic testDriveTechnic = Technic.testDrive(
//         row[1], row[2], row[3], dateStartTestDrive, dateFinishTestDrive,
//         row[6], checkTestDrive, row[8]);
//     list.add(testDriveTechnic);
//   }
//   return list;
// }

  Future<List<Repair>> fetchCurrentRepairs() async {
    var result = await _connDB!.query('SELECT * FROM repairEquipment '
        'WHERE repairEquipment.dateReceipt = "0000-00-00" OR repairEquipment.dateReceipt = "0001-11-30"');
    final List<Repair> list = repairListFromMap(result);
    return list;
  }

  Future<List<Repair>> fetchFinishedRepairs() async {
    var result = await _connDB!.query('SELECT * FROM repairEquipment '
        'WHERE repairEquipment.dateReceipt <> "0000-00-00" AND repairEquipment.dateReceipt <> "0001-11-30"');
    final List<Repair> list = repairListFromMap(result);
    return list;
  }

  Future<Repair?> fetchRepair(int id) async {
    Repair? repair;
    var result = await _connDB!.query('SELECT * FROM repairEquipment WHERE id = ?', [id]);
      for (var row in result) {
        // id-row[0], number-row[1],  number-row[1], category-row[2], dislocationOld-row[3], status-row[4],
        // complaint-row[5], dateDeparture-row[6],j whoTook-row[7], idTrouble-row[8], serviceDislocation-row[9],
        // dateTransferInService-row[10], dateDepartureFromService-row[11],  worksPerformed-row[12],
        // costService-row[13], diagnosisService-row[14], recommendationsNotes-row[15], newStatus-row[16],
        // newDislocation-row[17], dateReceipt-row[18], idTestDrive-row[19]

        repair = Repair.fullRepair(row[0], row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8], row[9],
            row[10], row[11], row[12], row[13], row[14], row[15], row[16], row[17], row[18], row[19]
        );
      }
    return repair;
  }

  List<Repair> repairListFromMap(var result) {
    List<Repair> list = [];
    for (var row in result) {

      // print('id-row[0] ${row[0]}');
      // print('number-row[1] ${row[1]}');
      // print('category-row[2] ${row[2]}');
      // print('dislocationOld-row[3] ${row[3]}');
      // print('status-row[4] ${row[4]}');
      // print('complaint-row[5] ${row[5]}');
      // print('dateDeparture-row[6] ${row[6]}');
      // print('whoTook-row[7] ${row[7]}');
      // print('idTrouble-row[8] ${row[8]}');
      // print('serviceDislocation-row[9] ${row[9]}');
      // print('dateTransferInService-row[10] ${row[10]}');
      // print('dateDepartureFromService-row[11] ${row[11]}');
      // print('worksPerformed-row[12] ${row[12]}');
      // print('costService-row[13] ${row[13]}');
      // print('diagnosisService-row[14] ${row[14]}');
      // print('recommendationsNotes-row[15] ${row[15]}');
      // print('newStatus-row[16] ${row[16]}');
      // print('newDislocation-row[17] ${row[17]}');
      // print('dateReceipt-row[18] ${row[18]}');
      // print('idTestDrive-row[19] ${row[19]}');

      Repair repair = Repair.fullRepair(row[0], row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8], row[9],
          row[10], row[11], row[12], row[13], row[14], row[15], row[16], row[17], row[18], row[19]
      );
      list.add(repair);
    }
    return list;
  }

  Future<Map<int, List<SummRepair>>> getSummsRepairs(String numberTechnic) async {
    var result = await _connDB!.query(
        'SELECT '
        'id, serviceDislocation, costService, complaint, worksPerformed, dateTransferInService, dateReceipt '
        'FROM repairEquipment WHERE number = ?',
        [numberTechnic]);
    List<SummRepair> listSummsRepairs = [];
    int totalSumm = 0;
    for (var row in result) {
      SummRepair summRepair = SummRepair(
          idRepair: row[0],
          repairmen: row[1],
          summRepair: row[2],
          complaint: row[3],
          worksPerformed: row[4],
          dateTransferInService: row[5],
          dateReceipt: row[6]);
      listSummsRepairs.add(summRepair);
      totalSumm += summRepair.summRepair;
    }
    List<SummRepair> reversedList = List.from(listSummsRepairs.reversed);
    Map<int, List<SummRepair>> mapResult = {};
    mapResult[totalSumm] = reversedList;
    return mapResult;
  }

  Future<List<HistoryTechnic>> fetchHistoryTechnic(String idTechnic) async {
    List<HistoryTechnic> historyTechnics = [];
    String query1 = 'SELECT id, date, dislocation FROM statusEquipment '
        'WHERE idEquipment = (SELECT id FROM equipment WHERE number = $idTechnic)';
    var result1 = await _connDB!.query(query1);
    for (var row in result1) {
      HistoryTechnic historyTechnic = HistoryTechnic(id: row[0], date: row[1], location: PhotosalonLocation(row[2]));
      historyTechnics.add(historyTechnic);
    }
    historyTechnics.sort();

    String query3 = 'SELECT id, ДатаНеисправности, Фотосалон, Сотрудник, Неисправность FROM Неисправности '
        'WHERE НомерТехники = $idTechnic ';
    var result3 = await _connDB!.query(query3);
    for (var row in result3) {
      TroubleTechnicOnPeriod troubleTechnicOnPeriod =
          TroubleTechnicOnPeriod(id: row[0], date: row[1], location: PhotosalonLocation(row[2]));
      troubleTechnicOnPeriod.employee = row[3];
      troubleTechnicOnPeriod.trouble = row[4].toString();
      for (int i = 1; i < historyTechnics.length; i++) {
        if (i == 1) {
          if (troubleTechnicOnPeriod.date.isAfter(historyTechnics[i - 1].date)) {
            historyTechnics[i - 1].listTrouble.add(troubleTechnicOnPeriod);
          }
        }
        if (troubleTechnicOnPeriod.date.isAfter(historyTechnics[i].date) &&
            troubleTechnicOnPeriod.date.isBefore(historyTechnics[i - 1].date)) {
          historyTechnics[i].listTrouble.add(troubleTechnicOnPeriod);
          continue;
        }
        historyTechnics[i].listTrouble.sort();
      }
    }

    String query2 = 'SELECT id, dateTransferInService, serviceDislocation, '
        'dateDepartureFromService, worksPerformed, '
        'costService FROM repairEquipment '
        'WHERE number = $idTechnic';
    var result2 = await _connDB!.query(query2);
    for (var row in result2) {
      HistoryTechnic historyTechnic = HistoryTechnic(id: row[0], date: row[1], location: RepairLocation(row[2]));
      historyTechnic.dateDepartureFromService = row[3];
      historyTechnic.worksPerformed = row[4];
      historyTechnic.costService = row[5];
      historyTechnics.add(historyTechnic);
    }
    historyTechnics.sort();
    return historyTechnics;
  }

// Future<List> getAllHistory() async{
//   var result = await _connDB!.query('SELECT * FROM history');
//   var list = historyListFromMap(result);
//   var reversedList = List.from(list.reversed);
//   return reversedList;
// }
//

//
// List historyListFromMap(var result) {
//   List list = [];
//   for (var row in result) {
//     // id-row[0], section-row[1],  idSection-row[2],  typeOperation-row[3], description-row[4], login-row[5],
//     // date-row[6]
//     String dateHystory = row[6].toString() == "-0001-11-30 00:00:00.000Z" ? "" : getDateFormatted(row[6].toString());
//     History history = History(row[0], row[1],  row[2],  row[3], row[4].toString(), row[5].toString(), dateHystory);
//     list.add(history);
//   }
//   return list;
// }
//

// Future updateTestDriveInDB(Technic technic) async{
//   int checkBox = 0;
//   if(technic.checkboxTestDrive) checkBox = 1;
//
//   await ConnectDbMySQL.connDB.connDatabase();
//   int id = await findIDLastTestDriveTechnic(technic);
//   await _connDB!.query(
//       'UPDATE testDrive SET testDriveDislocation = ?, dateStart = ?, dateFinish = ?, '
//           'result = ?, checkEquipment = ? WHERE id = ?',
//       [
//         technic.testDriveDislocation,
//         technic.dateStartTestDrive,
//         technic.dateFinishTestDrive,
//         technic.resultTestDrive,
//         checkBox,
//         id
//       ]);
// }

  Future<void> updateTechnicInDB(Technic technic) async {
    await _connDB!
        .query('UPDATE equipment SET name = ?, dateBuy = ?, cost = ?, comment = ? WHERE id = ?', [
      technic.name,
      technic.dateBuyTechnic.dateFormattedForSQL(),
      technic.cost,
      technic.comment,
      technic.id
    ]);
  }

Future<int> insertRepairInDB(Repair repair) async{
    String str = 'INSERT INTO repairEquipment '
        '(number, '
        'category, '
        'dislocationOld, '
        'status, '
        'complaint, '
        'dateDeparture, '
        'whoTook) '
        'VALUES (?, ?, ?, ?, ?, ?, ?)';
  var result = await _connDB!.query(str, [
    repair.numberTechnic,
    repair.category,
    repair.dislocationOld,
    repair.status,
    repair.complaint,
    repair.dateDeparture.dateFormattedForSQL(),
    repair.whoTook
  ]);

  int id = result.insertId!;
  return id;
}

Future updateRepairInDBStepsTwoAndThree(Repair repair) async{
  await _connDB!.query(
      'UPDATE repairEquipment SET '
          'serviceDislocation = ?, '
          'dateTransferInService = ?, '
          'dateDepartureFromService = ?, '
          'worksPerformed = ?, '
          'costService = ?, '
          'diagnosisService = ?, '
          'recommendationsNotes = ?, '
          'newStatus = ?, '
          'newDislocation = ?, '
          'dateReceipt = ? '
          'WHERE id = ?',
      [
        repair.serviceDislocation,
        repair.dateTransferInService?.dateFormattedForSQL() ?? '',
        repair.dateDepartureFromService?.dateFormattedForSQL() ?? '',
        repair.worksPerformed,
        repair.costService,
        repair.diagnosisService,
        repair.recommendationsNotes,
        repair.newStatus,
        repair.newDislocation,
        repair.dateReceipt?.dateFormattedForSQL() ?? '',
        repair.id
      ]);
}

  Future updateRepairInDBStepOne(Repair repair) async{
    await _connDB!.query(
        'UPDATE repairEquipment SET '
            'category = ?, '
            'dislocationOld = ?, '
            'status = ?, '
            'complaint = ?, '
            'dateDeparture = ?, '
            'whoTook = ? '
            'WHERE id = ?',
        [
          repair.category,
          repair.dislocationOld,
          repair.status,
          repair.complaint,
          repair.dateDeparture.dateFormattedForSQL(),
          repair.whoTook,
          repair.id
        ]);
  }

  Future deleteRepairInDB(String id) async{
    await _connDB!.query('DELETE FROM repairEquipment WHERE id = ?', [id]);
  }

  Future<List<Trouble>> fetchTroubles() async{
    var result = await _connDB!.query('SELECT * FROM Неисправности WHERE СотрПодтверУстр = "" OR ИнженерПодтверУстр = ""');

    var list = troubleListFromMap(result);
    List<Trouble> reversedList = List.from(list.reversed);
    return reversedList;
  }

  Future<List<Trouble>> fetchFinishedTroubles() async {
    var result = await _connDB!.query('SELECT * FROM Неисправности '
        'WHERE Неисправности.СотрПодтверУстр <> "" AND Неисправности.ИнженерПодтверУстр <> ""');
    final List<Trouble> list = troubleListFromMap(result);
    return list;
  }

  Future<void> insertTroubleInDB(Trouble trouble) async{
    String str = 'INSERT INTO Неисправности '
        '(Фотосалон, '
        'ДатаНеисправности, '
        'Сотрудник, '
        'НомерТехники, '
        'Неисправность, '
        'Фотография) '
        'VALUES (?, ?, ?, ?, ?, ?)';
    await _connDB!.query(str, [
      trouble.photosalon,
      trouble.dateTrouble.dateFormattedForSQL(),
      trouble.employee,
      trouble.numberTechnic.toString(),
      trouble.trouble,
      trouble.photoTrouble ?? ''
    ]);
  }

  Future updateTrouble(Trouble trouble) async{
    await _connDB!.query(
        'UPDATE Неисправности SET '
            'Фотосалон = ?, '
            'ДатаНеисправности = ?, '
            'Сотрудник = ?, '
            'НомерТехники = ?, '
            'Неисправность = ?, '
            'ДатаУстрСотр = ?, '
            'СотрПодтверУстр = ?, '
            'ДатаУстрИнженер = ?, '
            'ИнженерПодтверУстр = ?, '
            'Фотография = ? '
            'WHERE id = ?',
        [
          trouble.photosalon,
          trouble.dateTrouble.dateFormattedForSQL(),
          trouble.employee,
          trouble.numberTechnic.toString(),
          trouble.trouble,
          trouble.dateFixTroubleEmployee?.dateFormattedForSQL() ?? '',
          trouble.fixTroubleEmployee ?? '',
          trouble.dateFixTroubleEngineer?.dateFormattedForSQL() ?? '',
          trouble.fixTroubleEngineer ?? '',
          trouble.photoTrouble ?? '',
          trouble.id
        ]);
  }

  Future deleteTroubleInDB(String id) async{
    await _connDB!.query('DELETE FROM Неисправности WHERE id = ?', [id]);
  }

//
// Future<Trouble?> getTrouble(int id) async {
//   var result = await _connDB!.query('SELECT * FROM Неисправности WHERE id = ?', [id]);
//   Trouble? trouble = troubleListFromMap(result).first;
//   return trouble;
// }

List<Trouble> troubleListFromMap(var result) {
  List<Trouble> list = [];
  for (var row in result) {
    // id-row[0], photosalon-row[1],  dateTrouble-row[2],  employee-row[3], internalID-row[4], trouble-row[5],
    // dateCheckFixTroubleEmployee-row[6], employeeCheckFixTrouble-row[7],  dateCheckFixTroubleEngineer-row[8],
    // engineerCheckFixTrouble-row[9], photoTrouble-row[10]

    Blob blobImage = row[10];
    Uint8List image = Uint8List.fromList(blobImage.toBytes());
    Trouble trouble = Trouble(
        id: row[0],
        photosalon: row[1].toString(),
        dateTrouble: row[2],
        employee: row[3].toString(),
        numberTechnic: row[4],
        trouble: row[5].toString(),);
        trouble.dateFixTroubleEmployee = row[6];
        trouble.fixTroubleEmployee = row[7];
        trouble.dateFixTroubleEngineer = row[8];
        trouble.fixTroubleEngineer = row[9];
        trouble.photoTrouble = image;
    list.add(trouble);
  }
  return list;
}

// Future<int> insertTroubleInDB(Trouble trouble) async{
//   await ConnectDbMySQL.connDB.connDatabase();
//   var result = await _connDB!.query('INSERT INTO Неисправности ('
//       'Фотосалон, ДатаНеисправности, Сотрудник, НомерТехники, Неисправность, '
//       'ДатаУстрСотр, СотрПодтверУстр, '
//       'ДатаУстрИнженер, ИнженерПодтверУстр, Фотография) '
//       'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
//     trouble.photosalon,
//     trouble.dateTrouble,
//     trouble.employee,
//     trouble.internalID,
//     trouble.trouble,
//     trouble.dateCheckFixTroubleEmployee,
//     trouble.employeeCheckFixTrouble,
//     trouble.dateCheckFixTroubleEngineer,
//     trouble.engineerCheckFixTrouble,
//     trouble.photoTrouble ?? ''
//   ]);
//   return result.insertId!;
// }
//
// Future updateTroubleInDB(Trouble trouble) async{
//   await ConnectDbMySQL.connDB.connDatabase();
//   await _connDB!.query(
//       'UPDATE Неисправности SET '
//           'ДатаУстрСотр = ?, '
//           'СотрПодтверУстр = ?, '
//           'ДатаУстрИнженер = ?, '
//           'ИнженерПодтверУстр = ? '
//           'WHERE id = ?',
//       [
//         trouble.dateCheckFixTroubleEmployee,
//         trouble.employeeCheckFixTrouble,
//         trouble.dateCheckFixTroubleEngineer,
//         trouble.engineerCheckFixTrouble,
//         trouble.id
//       ]);
// }
}
