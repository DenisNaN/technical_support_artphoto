import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mysql_client_plus/exception.dart';
import 'package:mysql_client_plus/mysql_client_plus.dart';
import 'package:technical_support_artphoto/core/api/data/models/photosalon_location.dart';
import 'package:technical_support_artphoto/core/api/data/models/repair_location.dart';
import 'package:technical_support_artphoto/core/api/data/models/storage_location.dart';
import 'package:technical_support_artphoto/core/api/data/models/transportation_location.dart';
import 'package:technical_support_artphoto/core/api/data/models/trouble_account_mail_ru.dart';
import 'package:technical_support_artphoto/core/utils/extension.dart';
import 'package:technical_support_artphoto/features/repairs/models/repair.dart';
import 'package:technical_support_artphoto/features/repairs/models/summ_repair.dart';
import 'package:technical_support_artphoto/features/technics/data/models/history_technic.dart';
import 'package:technical_support_artphoto/features/technics/data/models/trouble_technic_on_period.dart';
import 'package:technical_support_artphoto/features/test_drive/models/test_drive.dart';
import 'package:technical_support_artphoto/features/troubles/models/trouble.dart';
import '../models/decommissioned.dart';
import '../../../../features/technics/models/technic.dart';

class ConnectDbMySQL {
  ConnectDbMySQL._();

  static final ConnectDbMySQL connDB = ConnectDbMySQL._();
  MySQLConnection? _connDB;
  static int countConnection = 0;

  Future connDatabase() async {
    _connDB ??= await _init();
    if(_connDB != null && !_connDB!.connected){
      try {
        await _connDB!.connect();
        debugPrint('New connection number - $countConnection');
        countConnection++;
      } on MySQLClientException catch(_){
        _connDB = await _init();
        await _connDB!.connect();
        debugPrint('New connection number - $countConnection');
        countConnection++;
      }
    }
  }

  Future<void> dispose() async {
    await _connDB?.close();
  }

  Future<MySQLConnection> _init() async {
    final conn = await MySQLConnection.createConnection(
      host: dotenv.env['HOST'] ?? '',
      port: int.tryParse(dotenv.env['PORT'] ?? '0') ?? 0,
      userName: dotenv.env['USER'] ?? '',
      password: dotenv.env['PASSWORD'] ?? '',
      databaseName: dotenv.env['DB'], // optional
    );
    return conn;
  }

  Future<IResultSet?> fetchAccessLevel(String password) async {
    return await _connDB!.execute('SELECT login, access FROM users WHERE password = :password', {'password': password});
  }

  Future<IResultSet?> fetchUsers() async {
    return await _connDB!.execute('SELECT login FROM users');
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
          'WHERE s.dislocation = :dislocation AND s.status <> "Списана" '
          'ORDER BY equipment.number ASC';
      var result = await _connDB!.execute(query, {'dislocation': namePhotosalon});
      if (result.isNotEmpty) {
        for (final row in result.rows) {
          Technic technic = technicFromMap(row);
          TestDrive? testDrive = await fetchTestDrive(technic.id.toString());
          if(testDrive != null) technic.testDrive = testDrive;
          photosalon.technics.add(technic);
        }
      }
      photosalons[namePhotosalon] = photosalon;
    }
    return photosalons;
  }

  Technic technicFromMap(ResultSetRow row) {
    return Technic(
      int.parse(row.colAt(0)),
      int.parse(row.colAt(1)),
      row.colAt(2),
      row.colAt(3),
      row.colAt(4),
      row.colAt(5),
      row.colAt(6).toString().dateFormattedFromSQL(),
      int.parse(row.colAt(7)),
      row.colAt(8));
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
          'WHERE s.dislocation = :dislocation '
          'ORDER BY equipment.number ASC';
      var result = await _connDB!.execute(query, {'dislocation': nameRepair});
      if (result.isNotEmpty) {
        for (final row in result.rows) {
          Technic technic = technicFromMap(row);
          TestDrive? testDrive = await fetchTestDrive(technic.id.toString());
          if(testDrive != null) technic.testDrive = testDrive;
          if(technic.status == 'В ремонте'){
            repair.technics.add(technic);
          }
        }
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
          'WHERE s.dislocation = :dislocation AND s.status <> "Списана" '
          'ORDER BY equipment.number ASC';
      var result = await _connDB!.execute(query, {'dislocation': nameStorage});
      if (result.isNotEmpty) {
        for (final row in result.rows) {
          Technic technic = technicFromMap(row);
          TestDrive? testDrive = await fetchTestDrive(technic.id.toString());
          if(testDrive != null) technic.testDrive = testDrive;
          storage.technics.add(technic);
        }
      }
      storages[nameStorage] = storage;
    }
    return storages;
  }

  Future<Map<String, TransportationLocation>> fetchTechnicsInTransportation() async {
    Map<String, TransportationLocation> transportations = {};
    List<String> namesTransportation = [];
    IResultSet? result = await ConnectDbMySQL.connDB.fetchUsers();
    if (result != null) {
      for (final row in result.rows) {
        namesTransportation.add(row.colAt(0));
      }
    }

    for (var nameTransportation in namesTransportation) {
      TransportationLocation transportationLocation = TransportationLocation(nameTransportation);
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
          'WHERE s.dislocation = :dislocation AND s.status <> "Списана" '
          'ORDER BY equipment.number ASC';
      var result = await _connDB!.execute(query, {'dislocation': nameTransportation});
      if (result.isNotEmpty) {
        for (final row in result.rows) {
          Technic technic = technicFromMap(row);
          TestDrive? testDrive = await fetchTestDrive(technic.id.toString());
          if(testDrive != null) technic.testDrive = testDrive;
          if(technic.status == 'Транспортировка'){
            transportationLocation.technics.add(technic);
          }
        }
      }
      transportations[nameTransportation] = transportationLocation;
    }
    return transportations;
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
    var result = await _connDB!.execute(query);
    if (result.isNotEmpty) {
      for (final row in result.rows) {
        Technic technic = technicFromMap(row);
        TestDrive? testDrive = await fetchTestDrive(technic.id.toString());
        if(testDrive != null) technic.testDrive = testDrive;
        decommissionedTechnics.technics.add(technic);
      }
    }
    return decommissionedTechnics;
  }

  Future<List<String>> fetchNamePhotosalons() async {
    var result = await _connDB!.execute('SELECT Фотосалон FROM Фотосалоны');

    List<String> photosalons = [];
    for (final row in result.rows) {
      if (row.colAt(0) != 'Склад' && row.colAt(0) != 'Офис') {
        photosalons.add(row.colAt(0));
      }
    }
    return photosalons;
  }

  Future<List<String>> fetchNameRepairs() async {
    var result = await _connDB!.execute('SELECT repairmen FROM service');

    List<String> repairs = [];
    for (final row in result.rows) {
      repairs.add(row.colAt(0));
    }
    return repairs;
  }

  Future<List<String>> fetchNameStorages() async {
    var result = await _connDB!.execute('SELECT storage FROM storages');

    List<String> storages = [];
    for (final row in result.rows) {
      storages.add(row.colAt(0));
    }
    return storages;
  }

  Future<bool> checkNumberTechnic(String number) async {
    var result = await _connDB!.execute('SELECT 1 FROM equipment WHERE number = :number', {'number': number});
    return result.isEmpty;
  }

  Future<int> insertTechnicInDB(Technic technic, String nameUser) async {
    var result = await _connDB!.execute(
        'INSERT INTO equipment (number, category, name, dateBuy, cost, comment, user) '
            'VALUES (:number, :category , :name, :dateBuy, :cost, :comment, :user)', {
          'number': technic.number,
          'category': technic.category,
          'name': technic.name,
          'dateBuy': technic.dateBuyTechnic.dateFormattedForSQL(),
          'cost': technic.cost,
          'comment': technic.comment,
          'user': nameUser
        });

    int id = int.parse(result.rows.first.colAt(0));
    await insertStatusInDB(id, technic.status, technic.dislocation, nameUser);
    return id;
  }

  Future insertStatusInDB(int id, String status, String dislocation, String nameUser) async {
    await _connDB!.execute(
        'INSERT INTO statusEquipment (idEquipment, status, dislocation, date, user) VALUES '
            '(:idEquipment, :status, :dislocation, :date, :user)',
        {'idEquipment': id, 'status': status, 'dislocation': dislocation,
          'date': DateTime.now().dateFormattedForSQL(), 'user': nameUser});
  }

  Future<int> insertTestDriveInDB(TestDrive testDrive) async {
    int closeTestDrive = 0;
    if(testDrive.isCloseTestDrive) closeTestDrive = 1;
    var result = await _connDB!.execute(
        'INSERT INTO test_drive (idEquipment, category, testDriveDislocation, dateStart, dateFinish, result, '
        'checkEquipment, user) VALUES '
            '(:idEquipment, :category, :testDriveDislocation, :dateStart, :dateFinish, '
            ':result, :checkEquipment, :user)',
        {
          'idEquipment': testDrive.idTechnic.toString(),
          'category': testDrive.categoryTechnic,
          'testDriveDislocation': testDrive.dislocationTechnic,
          'dateStart': testDrive.dateStart.dateFormattedForSQL(),
          'dateFinish': testDrive.dateFinish.dateFormattedForSQL(),
          'result': testDrive.result,
          'checkEquipment': closeTestDrive.toString(),
          'user': testDrive.user
        });
    int id = int.parse(result.rows.first.colAt(0));
    return id;
  }

  Future updateTestDriveInDB(TestDrive testDrive) async{
    int checkBox = 0;
    if(testDrive.isCloseTestDrive) checkBox = 1;

    await _connDB!.execute(
      'UPDATE test_drive SET testDriveDislocation = :testDriveDislocation, '
          'dateStart = :dateStart, dateFinish = :dateFinish, '
          'result = :result, checkEquipment = :checkEquipment WHERE id = :id',
        {
          'testDriveDislocation': testDrive.dislocationTechnic,
          'dateStart': testDrive.dateStart.dateFormattedForSQL(),
          'dateFinish': testDrive.dateFinish.dateFormattedForSQL(),
          'result': testDrive.result,
          'checkEquipment': checkBox.toString(),
          'id': testDrive.id.toString()
        });
  }

  Future<TestDrive?> fetchTestDrive(String id) async {
    TestDrive? testDrive;
    var result =
        await _connDB!.execute('SELECT * FROM test_drive WHERE idEquipment = :idEquipment '
            'ORDER BY id DESC LIMIT 1', {'idEquipment': id});
    if (result.isNotEmpty) {
      testDrive = testDriveFromMap(result);
    }
    return testDrive;
  }

  TestDrive? testDriveFromMap(IResultSet result) {
    TestDrive? testDrive;
    for (final row in result.rows) {
      bool isCloseTestDrive = int.parse(row.colAt(7)) == 0 ? false : true;
      testDrive = TestDrive(
          idTechnic: int.parse(row.colAt(1)),
          categoryTechnic: row.colAt(2),
          dislocationTechnic: row.colAt(3),
          dateStart: row.colAt(4).toString().dateFormattedFromSQL(),
          dateFinish: row.colAt(5).toString().dateFormattedFromSQL(),
          result: row.colAt(6),
          isCloseTestDrive: isCloseTestDrive,
          user: row.colAt(8));
      testDrive.id = int.parse(row.colAt(0));
    }
    return testDrive;
  }

  Future<List<String>> fetchStatusForEquipment() async {
    var result = await _connDB!.execute('SELECT '
        'statusForEquipment.id, '
        'statusForEquipment.status '
        'FROM statusForEquipment');

    List<String> list = [];
    for (final row in result.rows) {
      list.add(row.colAt(1).toString());
    }
    return list;
  }

  Future<List<String>> fetchServices() async {
    var result = await _connDB!.execute('SELECT '
        'service.id, '
        'service.repairmen '
        'FROM service');

    List<String> list = [];
    for (final row in result.rows) {
      list.add(row.colAt(1).toString());
    }
    return list;
  }

  Future<List<String>> fetchNameEquipment() async {
    var result = await _connDB!.execute('SELECT '
        'nameEquipment.id, '
        'nameEquipment.name '
        'FROM nameEquipment');

    List<String> list = [];
    for (final row in result.rows) {
      list.add(row.colAt(1).toString());
    }
    return list;
  }

  Future<Map<String, int>> fetchColorsForEquipment() async {
    var result = await _connDB!.execute('SELECT * FROM colorsForPhotosalons');

    Map<String, int> map = {};
    for (final row in result.rows) {
      map[row.colAt(1)] = int.parse(row.colAt(2));
    }
    return map;
  }

  Future<TroubleAccountMailRu?> fetchAccountMailRu() async {
    TroubleAccountMailRu? accountMailRu;
    var result = await _connDB!.execute('SELECT * FROM tmp_account');
    for (final row in result.rows) {
      accountMailRu = TroubleAccountMailRu(
          id: int.parse(row.colAt(0)),
          name: row.colAt(1),
          account: row.colAt(2),
          password: row.colAt(3));
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
      'WHERE equipment.number = :number '
      'ORDER BY equipment.number ASC';
  var result = await _connDB!.execute(query, {'number': number});
  if (result.isNotEmpty) {
    for (final row in result.rows) {
        technic = technicFromMap(row);
      }
  }
  return technic;
}

  Future<List<Repair>> fetchCurrentRepairs() async {
    var result = await _connDB!.execute('SELECT * FROM repairEquipment '
        'WHERE repairEquipment.dateReceipt = "0000-00-00" OR repairEquipment.dateReceipt = "0001-11-30"');
    final List<Repair> list = repairListFromMap(result);
    return list;
  }

  Future<List<Repair>> fetchFinishedRepairs() async {
    var result = await _connDB!.execute('SELECT * FROM repairEquipment '
        'WHERE repairEquipment.dateReceipt <> "0000-00-00" AND repairEquipment.dateReceipt <> "0001-11-30"');
    final List<Repair> list = repairListFromMap(result);
    return list;
  }

  Future<Repair?> fetchRepair(int id) async {
    Repair? repair;
    var result = await _connDB!.execute('SELECT * FROM repairEquipment WHERE id = :id',
        {'id': id});
    if (result.isNotEmpty) {
      for (final row in result.rows) {
        // id-row[0], number-row[1],  number-row[1], category-row[2], dislocationOld-row[3], status-row[4],
        // complaint-row[5], dateDeparture-row[6],j whoTook-row[7], idTrouble-row[8], serviceDislocation-row[9],
        // dateTransferInService-row[10], dateDepartureFromService-row[11],  worksPerformed-row[12],
        // costService-row[13], diagnosisService-row[14], recommendationsNotes-row[15], newStatus-row[16],
        // newDislocation-row[17], dateReceipt-row[18], idTestDrive-row[19]
        repair = repairFullFromMap(row);
      }
    }
    return repair;
  }

  Repair repairFullFromMap(ResultSetRow row) {
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
    return Repair.fullRepair(
        int.parse(row.colAt(0)),
        int.parse(row.colAt(1)),
        row.colAt(2),
        row.colAt(3),
        row.colAt(4),
        row.colAt(5),
        row.colAt(6).toString().dateFormattedFromSQL(),
        row.colAt(7),
        int.parse(row.colAt(8)),
        row.colAt(9),
        row.colAt(10).toString().dateFormattedFromSQL(),
        row.colAt(11).toString().dateFormattedFromSQL(),
        row.colAt(12),
        int.parse(row.colAt(13)),
        row.colAt(14),
        row.colAt(15),
        row.colAt(16),
        row.colAt(17),
        row.colAt(18).toString().dateFormattedFromSQL(),
        int.parse(row.colAt(19)));
  }

  List<Repair> repairListFromMap(IResultSet result) {
    List<Repair> list = [];
    if (result.isNotEmpty) {
      for (final row in result.rows) {
            Repair repair = repairFullFromMap(row);
            list.add(repair);
          }
    }
    return list;
  }

  Future<Map<int, List<SumRepair>>> getSumsRepairs(String numberTechnic) async {
    var result = await _connDB!.execute(
        'SELECT '
        'id, serviceDislocation, costService, complaint, worksPerformed, dateTransferInService, dateReceipt '
        'FROM repairEquipment WHERE number = :number',
        {'number': numberTechnic});
    List<SumRepair> listSumsRepairs = [];
    int totalSum = 0;
    for (final row in result.rows) {
      SumRepair sumRepair = SumRepair(
          idRepair: int.parse(row.colAt(0)),
          repairmen: row.colAt(1),
          sumRepair: int.parse(row.colAt(2)),
          complaint: row.colAt(3),
          worksPerformed: row.colAt(4),
          dateTransferInService: row.colAt(5).toString().dateFormattedFromSQL(),
          dateReceipt: row.colAt(6).toString().dateFormattedFromSQL());
      listSumsRepairs.add(sumRepair);
      totalSum += sumRepair.sumRepair;
    }
    List<SumRepair> reversedList = List.from(listSumsRepairs.reversed);
    Map<int, List<SumRepair>> mapResult = {};
    mapResult[totalSum] = reversedList;
    return mapResult;
  }

  Future<List<HistoryTechnic>> fetchHistoryTechnic(String idTechnic) async {
    List<HistoryTechnic> historyTechnics = [];
    String query1 = 'SELECT id, date, dislocation FROM statusEquipment '
        'WHERE idEquipment = (SELECT id FROM equipment WHERE number = :number)';
    var result1 = await _connDB!.execute(query1, {'number': idTechnic});
    for (final row in result1.rows) {
      HistoryTechnic historyTechnic = HistoryTechnic(id: int.parse(row.colAt(0)),
          date: row.colAt(1).toString().dateFormattedFromSQL(),
          location: PhotosalonLocation(row.colAt(2)));
      historyTechnics.add(historyTechnic);
    }
    historyTechnics.sort();

    String query3 = 'SELECT id, ДатаНеисправности, Фотосалон, Сотрудник, Неисправность FROM Неисправности '
        'WHERE НомерТехники = :НомерТехники';
    var result3 = await _connDB!.execute(query3, {'НомерТехники': idTechnic});
    for (final row in result3.rows) {
      TroubleTechnicOnPeriod troubleTechnicOnPeriod =
          TroubleTechnicOnPeriod(id: int.parse(row.colAt(0)),
              date: row.colAt(1).toString().dateFormattedFromSQL(),
              location: PhotosalonLocation(row.colAt(2)));
      troubleTechnicOnPeriod.employee = row.colAt(3);
      troubleTechnicOnPeriod.trouble = row.colAt(4).toString();
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
        'WHERE number = :number';
    var result2 = await _connDB!.execute(query2, {'number': idTechnic});
    for (final row in result2.rows) {
      HistoryTechnic historyTechnic = HistoryTechnic(id: int.parse(row.colAt(0)),
          date: row.colAt(1).toString().dateFormattedFromSQL(),
          location: RepairLocation(row.colAt(2)));
      historyTechnic.dateDepartureFromService = row.colAt(3).toString().dateFormattedFromSQL();
      historyTechnic.worksPerformed = row.colAt(4);
      historyTechnic.costService = int.parse(row.colAt(5));
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

  Future<void> updateTechnicInDB(Technic technic) async {
    await _connDB!
        .execute('UPDATE equipment SET name = :name, dateBuy = :dateBuy, cost = :cost, '
        'comment = :comment WHERE id = :id', {
          'name': technic.name,
          'dateBuy': technic.dateBuyTechnic.dateFormattedForSQL(),
          'cost': technic.cost,
          'comment': technic.comment,
          'id': technic.id
        });
  }

Future<int> insertRepairInDB(Repair repair) async{
    String str = 'INSERT INTO repairEquipment '
        '(number, '
        'category, '
        'dislocationOld, '
        'status, '
        'complaint, '
        'dateDeparture, '
        'whoTook, '
        'idTrouble) '
        'VALUES (:number, :category, :dislocationOld, :status, :complaint, :dateDeparture, '
        ':whoTook, :idTrouble)';
  var result = await _connDB!.execute(str, {
      'number': repair.numberTechnic,
      'category': repair.category,
      'dislocationOld': repair.dislocationOld,
      'status': repair.status,
      'complaint': repair.complaint,
      'dateDeparture': repair.dateDeparture.dateFormattedForSQL(),
      'whoTook': repair.whoTook,
      'idTrouble': repair.idTrouble.toString()
    });

  int id = int.parse(result.rows.first.colAt(0));
  return id;
}

Future updateRepairInDBStepsTwoAndThree(Repair repair) async{
  await _connDB!.execute(
      'UPDATE repairEquipment SET '
          'serviceDislocation = :serviceDislocation, '
          'dateTransferInService = :dateTransferInService, '
          'dateDepartureFromService = :dateDepartureFromService, '
          'worksPerformed = :worksPerformed, '
          'costService = :costService, '
          'diagnosisService = :diagnosisService, '
          'recommendationsNotes = :recommendationsNotes, '
          'newStatus = :newStatus, '
          'newDislocation = :newDislocation, '
          'dateReceipt = :dateReceipt '
          'WHERE id = :id',
      {
          'serviceDislocation': repair.serviceDislocation,
          'dateTransferInService': repair.dateTransferInService?.dateFormattedForSQL() ?? '',
          'dateDepartureFromService': repair.dateDepartureFromService?.dateFormattedForSQL() ?? '',
          'worksPerformed': repair.worksPerformed,
          'costService': repair.costService,
          'diagnosisService': repair.diagnosisService,
          'recommendationsNotes': repair.recommendationsNotes,
          'newStatus': repair.newStatus,
          'newDislocation': repair.newDislocation,
          'dateReceipt': repair.dateReceipt?.dateFormattedForSQL() ?? '',
          'id': repair.id
        });
}

  Future updateRepairInDBStepOne(Repair repair) async{
    await _connDB!.execute(
        'UPDATE repairEquipment SET '
            'category = :category, '
            'dislocationOld = :dislocationOld, '
            'status = :status, '
            'complaint = :complaint, '
            'dateDeparture = :dateDeparture, '
            'whoTook = :whoTook '
            'WHERE id = :id',
        {
          'category': repair.category,
          'dislocationOld': repair.dislocationOld,
          'status': repair.status,
          'complaint': repair.complaint,
          'dateDeparture': repair.dateDeparture.dateFormattedForSQL(),
          'whoTook': repair.whoTook,
          'id': repair.id
        });
  }

  Future deleteRepairInDB(String id) async{
    await _connDB!.execute('DELETE FROM repairEquipment WHERE id = :id', {'id': id});
  }

  Future<List<Trouble>> fetchTroubles() async{
    var result = await _connDB!.execute('SELECT * FROM Неисправности WHERE СотрПодтверУстр = "" OR ИнженерПодтверУстр = ""');

    var list = troubleListFromMap(result);
    List<Trouble> reversedList = List.from(list.reversed);
    return reversedList;
  }

  Future<List<Trouble>> fetchFinishedTroubles() async {
    var result = await _connDB!.execute('SELECT * FROM Неисправности '
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
        'VALUES (:Фотосалон, :ДатаНеисправности, :Сотрудник, :НомерТехники, '
        ':Неисправность, :Фотография)';
    await _connDB!.execute(str, {
      'Фотосалон': trouble.photosalon,
      'ДатаНеисправности': trouble.dateTrouble.dateFormattedForSQL(),
      'Сотрудник': trouble.employee,
      'НомерТехники': trouble.numberTechnic.toString(),
      'Неисправность': trouble.trouble,
      'Фотография': trouble.photoTrouble ?? ''
    });
  }

  Future updateTrouble(Trouble trouble) async{
    await _connDB!.execute(
        'UPDATE Неисправности SET '
            'Фотосалон = :Фотосалон, '
            'ДатаНеисправности = :ДатаНеисправности, '
            'Сотрудник = :Сотрудник, '
            'НомерТехники = :НомерТехники, '
            'Неисправность = :Неисправность, '
            'ДатаУстрСотр = :ДатаУстрСотр, '
            'СотрПодтверУстр = :СотрПодтверУстр, '
            'ДатаУстрИнженер = :ДатаУстрИнженер, '
            'ИнженерПодтверУстр = :ИнженерПодтверУстр, '
            'Фотография = :Фотография '
            'WHERE id = :id',
        {
          'Фотосалон': trouble.photosalon,
          'ДатаНеисправности': trouble.dateTrouble.dateFormattedForSQL(),
          'Сотрудник': trouble.employee,
          'НомерТехники': trouble.numberTechnic.toString(),
          'Неисправность': trouble.trouble,
          'ДатаУстрСотр': trouble.dateFixTroubleEmployee?.dateFormattedForSQL() ?? '',
          'СотрПодтверУстр': trouble.fixTroubleEmployee ?? '',
          'ДатаУстрИнженер': trouble.dateFixTroubleEngineer?.dateFormattedForSQL() ?? '',
          'ИнженерПодтверУстр': trouble.fixTroubleEngineer ?? '',
          'Фотография': trouble.photoTrouble ?? '',
          'id': trouble.id
        });
  }

  Future deleteTroubleInDB(String id) async{
    await _connDB!.execute('DELETE FROM Неисправности WHERE id = :id', {'id': id});
  }

  Future<Trouble?> fetchTrouble(String id) async {
    var result = await _connDB!.execute('SELECT * FROM Неисправности WHERE id = :id', {'id': id});
    Trouble? trouble = troubleListFromMap(result).first;
    return trouble;
  }

  List<Trouble> troubleListFromMap(IResultSet result) {
    List<Trouble> list = [];
    if (result.isNotEmpty) {
      for (final row in result.rows) {
            // id-row[0], photosalon-row[1],  dateTrouble-row[2],  employee-row[3], internalID-row[4], trouble-row[5],
            // dateCheckFixTroubleEmployee-row[6], employeeCheckFixTrouble-row[7],  dateCheckFixTroubleEngineer-row[8],
            // engineerCheckFixTrouble-row[9], photoTrouble-row[10]
            // Blob blobImage = row.colAt(10);
            // Uint8List image = Uint8List.fromList(blobImage.toBytes());
            Uint8List image = row.colAt(10);
            Trouble trouble = Trouble(
                id: int.parse(row.colAt(0)),
                photosalon: row.colAt(1),
                dateTrouble: row.colAt(2).toString().dateFormattedFromSQL(),
                employee: row.colAt(3),
                numberTechnic: int.parse(row.colAt(4)),
                trouble: row.colAt(5));
                trouble.dateFixTroubleEmployee = row.colAt(6).toString().dateFormattedFromSQL();
                trouble.fixTroubleEmployee = row.colAt(7);
                trouble.dateFixTroubleEngineer = row.colAt(8).toString().dateFormattedFromSQL();
                trouble.fixTroubleEngineer = row.colAt(9);
                trouble.photoTrouble = image;
            list.add(trouble);
          }
    }
    return list;
  }
}
