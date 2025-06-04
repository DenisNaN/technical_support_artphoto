import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mysql1/mysql1.dart';
import 'package:technical_support_artphoto/core/api/data/models/photosalon_location.dart';
import 'package:technical_support_artphoto/core/api/data/models/repair_location.dart';
import 'package:technical_support_artphoto/core/api/data/models/storage_location.dart';
import 'package:technical_support_artphoto/core/utils/extension.dart';
import 'package:technical_support_artphoto/features/history/history.dart';
import 'package:technical_support_artphoto/features/repairs/models/repair.dart';
import 'package:technical_support_artphoto/features/repairs/models/summ_repair.dart';
import 'package:technical_support_artphoto/features/technics/data/models/history_technic.dart';
import 'package:technical_support_artphoto/features/technics/data/models/trouble_technic_on_period.dart';
import '../models/decommissioned.dart';
import '../models/technic.dart';
import 'package:intl/intl.dart';

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
    return result.isNotEmpty;
  }

  String getDateFormatted(String date) {
    return DateFormat('yyyy.MM.dd').format(DateTime.parse(date));
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
        [id, status, dislocation, DateFormat('yyyy.MM.dd').format(DateTime.now()), nameUser]);
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

  // Future<int> findLastRepair(Technic technic) async {
  //   await ConnectDbMySQL.connDB.connDatabase();
  //   var result = await _connDB!
  //       .query('SELECT id FROM repairEquipment WHERE number = ? ORDER BY id DESC LIMIT 1', [technic.internalID]);
  //   int id = lastTectDriveListFromMap(result);
  //   return id;
  // }

  Future insertHistory(History history) async {
    await ConnectDbMySQL.connDB.connDatabase();
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

  Future<List<Repair>> fetchAllRepairs() async {
    var result = await _connDB!.query('SELECT '
        'repairEquipment.id, '
        'repairEquipment.number, '
        'repairEquipment.category, '
        'repairEquipment.dislocationOld, '
        'repairEquipment.status, '
        'repairEquipment.complaint, '
        'repairEquipment.dateDeparture, '
        'repairEquipment.whoTook, '
        'repairEquipment.serviceDislocation, '
        'repairEquipment.dateTransferInService, '
        'repairEquipment.dateDepartureFromService, '
        'repairEquipment.worksPerformed, '
        'repairEquipment.costService, '
        'repairEquipment.diagnosisService, '
        'repairEquipment.recommendationsNotes, '
        'repairEquipment.newStatus, '
        'repairEquipment.newDislocation, '
        'repairEquipment.dateReceipt, '
        'repairEquipment.idTestDrive '
        'FROM repairEquipment '
        'WHERE repairEquipment.dateReceipt = "0000-00-00"');

    final List<Repair> list = repairListFromMap(result);
    final List<Repair> reversedList = List.from(list.reversed);
    return list;
  }

//
// Future<Repair?> getRepair(int id) async {
//   Repair? repair = null;
//   var result = await _connDB!.query('SELECT * FROM repairEquipment WHERE id = ?', [id]);
//   if(result.isNotEmpty) {
//     repair = repairListFromMap(result).first;
//   }
//   return repair;
// }

  List<Repair> repairListFromMap(var result) {
    List<Repair> list = [];
    for (var row in result) {
      // id-row[0], number-row[1],  category-row[2],  dislocationOld-row[3], status-row[4], complaint-row[5], dateDeparture-row[6], serviceDislocation-row[7],
      // dateTransferInService-row[8], dateDepartureFromService-row[9],  worksPerformed-row[10],  costService-row[11], diagnosisService-row[12],
      // recommendationsNotes-row[13], newStatus-row[14],  newDislocation-row[15], dateReceipt-row[16], idTestDrive-row[17]

      Repair repair = Repair.fullRepair(
          row[0],
          row[1],
          row[2],
          row[3],
          row[4],
          row[5],
          row[6],
          row[7],
          row[8],
          row[9],
          row[10],
          row[11],
          row[12],
          row[13],
          row[14],
          row[15],
          row[16],
          row[17]);
      repair.idTestDrive = row[18];
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
          idRepar: row[0],
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

// Future<List> getAllTrouble() async{
//   var result = await _connDB!.query('SELECT '
//       'id, Фотосалон, ДатаНеисправности, Сотрудник, НомерТехники, Неисправность, '
//       'ДатаУстрСотр, СотрПодтверУстр, '
//       'ДатаУстрИнженер, ИнженерПодтверУстр, Фотография '
//       'FROM Неисправности');
//
//   var list = troubleListFromMap(result);
//   var reversedList = List.from(list.reversed);
//   return reversedList;
// }
//

//
// Future<Trouble?> getTrouble(int id) async {
//   var result = await _connDB!.query('SELECT * FROM Неисправности WHERE id = ?', [id]);
//   Trouble? trouble = troubleListFromMap(result).first;
//   return trouble;
// }
//
// List troubleListFromMap(var result) {
//   List list = [];
//   for (var row in result) {
//     // id-row[0], photosalon-row[1],  dateTrouble-row[2],  employee-row[3], internalID-row[4], trouble-row[5],
//     // dateCheckFixTroubleEmployee-row[6], employeeCheckFixTrouble-row[7],  dateCheckFixTroubleEngineer-row[8],
//     // engineerCheckFixTrouble-row[9], photoTrouble-row[10]
//     String dateTrouble = row[2].toString() == "-0001-11-30 00:00:00.000Z" ? "" : getDateFormatted(row[2].toString());
//     String dateCheckFixTroubleEmployee = row[6].toString() == "-0001-11-30 00:00:00.000Z" ? "" : getDateFormatted(row[6].toString());
//     String dateCheckFixTroubleEngineer = row[8].toString() == "-0001-11-30 00:00:00.000Z" ? "" : getDateFormatted(row[8].toString());
//
//     Blob blobImage = row[10];
//     Uint8List image = Uint8List.fromList(blobImage.toBytes());
//
//     Trouble trouble = Trouble(row[0], row[1].toString(),  dateTrouble,  row[3].toString(), row[4], row[5].toString(), dateCheckFixTroubleEmployee,
//         row[7].toString(), dateCheckFixTroubleEngineer, row[9].toString(), image);
//     list.add(trouble);
//   }
//   return list;
// }
//
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
      DateFormat('yyyy.MM.dd').format(technic.dateBuyTechnic),
      technic.cost,
      technic.comment,
      technic.id
    ]);
  }

Future<int> insertRepairInDB(Repair repair) async{
  await ConnectDbMySQL.connDB.connDatabase();
  var result = await _connDB!.query('INSERT INTO repairEquipment ('
      'number, '
      'category, '
      'dislocationOld, '
      'status, '
      'complaint, '
      'dateDeparture, '
      'whoTook '
      ') VALUES (?, ?, ?, ?, ?, ?, ?)', [
    repair.numberTechnic,
    repair.category,
    repair.dislocationOld,
    repair.status,
    repair.complaint,
    repair.dateDeparture,
    repair.whoTook
  ]);

  int id = result.insertId!;
  return id;
}

Future updateRepairInDBStepsTwoAndThree(Repair repair) async{
  await ConnectDbMySQL.connDB.connDatabase();
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
        repair.dateTransferInService,
        repair.dateDepartureFromService,
        repair.worksPerformed,
        repair.costService,
        repair.diagnosisService,
        repair.recommendationsNotes,
        repair.newStatus,
        repair.newDislocation,
        repair.dateReceipt,
        repair.id
      ]);
}

  Future updateRepairInDBStepOne(Repair repair) async{
    await ConnectDbMySQL.connDB.connDatabase();
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
          repair.dateDeparture,
          repair.whoTook,
          repair.id
        ]);
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
