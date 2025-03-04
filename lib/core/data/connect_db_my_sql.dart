import 'package:mysql1/mysql1.dart';
import 'package:technical_support_artphoto/core/domain/api_constants.dart';
import 'package:technical_support_artphoto/core/domain/models/photosalon.dart';
import 'package:technical_support_artphoto/core/domain/models/repair.dart';
import 'package:technical_support_artphoto/core/domain/models/storage.dart';
import 'package:technical_support_artphoto/core/domain/models/user.dart';
import 'package:technical_support_artphoto/core/domain/technical_support_repository.dart';
import 'package:technical_support_artphoto/features/history/history.dart';
import 'package:technical_support_artphoto/features/technics_entity/technic_entity.dart';
import '../domain/models/technic.dart';
import 'package:intl/intl.dart';

class ConnectDbMySQL implements TechnicalSupportRepository {
  ConnectDbMySQL._();

  static final ConnectDbMySQL connDB = ConnectDbMySQL._();
  MySqlConnection? _connDB;

  Future connDatabase() async {
    _connDB ??= await _init();
  }

  void dispose() {
    dispose();
  }

  Future<MySqlConnection> _init() async {
    MySqlConnection connDB = await MySqlConnection.connect(ConnectionSettings(
        host: ApiConstants.host,
        port: ApiConstants.port,
        user: ApiConstants.user,
        password: ApiConstants.password,
        db: ApiConstants.db));
    return connDB;
  }

  @override
  Future<User> fetchAccessLevel(String password) async {
    var result = await _connDB!.query('SELECT login, access FROM loginPassword WHERE password = $password');

    User user = User('user', 'no access');

    if (result.isNotEmpty) {
      for (var row in result) {
        user = User(row[0], row[1]);
      }
    }
    return user;
  }

  @override
  Future<Map<String, Photosalon>> fetchPhotosalons() async {
    Map<String, Photosalon> photosalons = {};
    List<String> namesPhotosalons = await fetchNamePhotosalons();

    for (var namePhotosalon in namesPhotosalons) {
      Photosalon photosalon = Photosalon(namePhotosalon);
      String query = 'SELECT equipment.id, '
          'equipment.number, '
          'equipment.category, '
          'equipment.name, '
          's.status, '
          's.dislocation '
          'FROM equipment '
          'LEFT JOIN (SELECT * FROM statusEquipment s1 WHERE NOT EXISTS (SELECT 1 FROM statusEquipment s2 WHERE s2.id > s1.id AND s2.idEquipment = s1.idEquipment)) s ON s.idEquipment = equipment.id '
          'WHERE s.dislocation = "$namePhotosalon" '
          'ORDER BY equipment.number ASC';
      var result = await _connDB!.query(query);
      for (var row in result) {
        Technic technic = Technic(row[0], row[1], row[2], row[3], row[4], row[5]);
        photosalon.technics.add(technic);
      }
      photosalons[namePhotosalon] = photosalon;
    }
    return photosalons;
  }

  @override
  Future<Map<String, Repair>> fetchRepairs() async {
    Map<String, Repair> repairs = {};
    List<String> namesRepairs = await fetchNameRepairs();

    for (var nameRepair in namesRepairs) {
      Repair repair = Repair(nameRepair);
      String query = 'SELECT equipment.id, '
          'equipment.number, '
          'equipment.category, '
          'equipment.name, '
          's.status, '
          's.dislocation '
          'FROM equipment '
          'LEFT JOIN (SELECT * FROM statusEquipment s1 WHERE NOT EXISTS (SELECT 1 FROM statusEquipment s2 WHERE s2.id > s1.id AND s2.idEquipment = s1.idEquipment)) s ON s.idEquipment = equipment.id '
          'WHERE s.dislocation = "$nameRepair" '
          'ORDER BY equipment.number ASC';
      var result = await _connDB!.query(query);
      for (var row in result) {
        Technic technic = Technic(row[0], row[1], row[2], row[3], row[4], row[5]);
        repair.technics.add(technic);
      }
      repairs[nameRepair] = repair;
    }
    return repairs;
  }

  @override
  Future<Map<String, Storage>> fetchStorages() async {
    Map<String, Storage> storages = {};
    List<String> namesStorages = await fetchNameStorages();

    for (var nameStorage in namesStorages) {
      Storage storage = Storage(nameStorage);
      String query = 'SELECT equipment.id, '
          'equipment.number, '
          'equipment.category, '
          'equipment.name, '
          's.status, '
          's.dislocation '
          'FROM equipment '
          'LEFT JOIN (SELECT * FROM statusEquipment s1 WHERE NOT EXISTS (SELECT 1 FROM statusEquipment s2 WHERE s2.id > s1.id AND s2.idEquipment = s1.idEquipment)) s ON s.idEquipment = equipment.id '
          'WHERE s.dislocation = "$nameStorage" '
          'ORDER BY equipment.number ASC';
      var result = await _connDB!.query(query);
      for (var row in result) {
        Technic technic = Technic(row[0], row[1], row[2], row[3], row[4], row[5]);
        storage.technics.add(technic);
      }
      storages[nameStorage] = storage;
    }
    return storages;
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

  @override
  Future<bool> checkNumberTechnic(String number) async{
    var result = await _connDB!.query('SELECT 1 FROM equipment WHERE number = $number');
    return result.isNotEmpty;
  }

  // Future<List> getAllTechnics() async{
  //   var result = await _connDB!.query('SELECT '
  //       'equipment.id, '
  //       'equipment.number, '
  //       'equipment.name, '
  //       'equipment.category, '
  //       'equipment.cost, '
  //       'equipment.dateBuy, '
  //       's.status, '
  //       's.dislocation, '
  //       's.date, '
  //       'equipment.comment, '
  //       't.testDriveDislocation, '
  //       't.dateStart, '
  //       't.dateFinish, '
  //       't.result, '
  //       't.checkEquipment '
  //       'FROM equipment '
  //       'LEFT JOIN (SELECT * FROM statusEquipment s1 WHERE NOT EXISTS (SELECT 1 FROM statusEquipment s2 WHERE s2.id > s1.id AND s2.idEquipment = s1.idEquipment)) s ON s.idEquipment = equipment.id '
  //       'LEFT JOIN (SELECT * FROM testDrive t1 WHERE NOT EXISTS (SELECT 1 FROM testDrive t2 WHERE t2.id > t1.id AND t2.idEquipment = t1.idEquipment)) t ON t.idEquipment = equipment.id '
  //       'ORDER BY equipment.id');

  // var list = technicListFromMap(result);
  // var reversedList = List.from(list.reversed);
  // return reversedList;
  //   return [];
  // }
  //

  //
  // Future<Technic?> getTechnic(int id) async {
  //   Technic? technic = null;
  //   var result = await _connDB!.query('SELECT '
  //       'equipment.id, '
  //       'equipment.number, '
  //       'equipment.name, '
  //       'equipment.category, '
  //       'equipment.cost, '
  //       'equipment.dateBuy, '
  //       's.status, '
  //       's.dislocation, '
  //       's.date, '
  //       'equipment.comment, '
  //       't.testDriveDislocation, '
  //       't.dateStart, '
  //       't.dateFinish, '
  //       't.result, '
  //       't.checkEquipment '
  //       'FROM equipment '
  //       'LEFT JOIN (SELECT * FROM statusEquipment s1 WHERE NOT EXISTS (SELECT 1 FROM statusEquipment s2 WHERE s2.id > s1.id AND s2.idEquipment = s1.idEquipment)) s ON s.idEquipment = equipment.id '
  //       'LEFT JOIN (SELECT * FROM testDrive t1 WHERE NOT EXISTS (SELECT 1 FROM testDrive t2 WHERE t2.id > t1.id AND t2.idEquipment = t1.idEquipment)) t ON t.idEquipment = equipment.id '
  //       'WHERE equipment.id = ?', [id]);
  //   if(result.isNotEmpty) {
  //     technic = technicListFromMap(result).first;
  //   }
  //   return technic;
  // }
  //
  // List technicListFromMap(var result){
  //   List list = [];
  //   for (var row in result) {
  //     // id-row[0], number-row[1],  name-row[2],  category-row[3], cost-row[4],
  //     // dateBuy-row[5], status-row[6], dislocation-row[7], dateChangeStatus-row[8], comment-row[9], testDriveDislocation-row[10],
  //     // dateStart-row[11], dateFinish-row[12], resultTestDrive-row[13], checkTestDrive-row[14]
  //
  //     String dateChangeStatus = '';
  //     if(row[8] != null && row[8].toString() != "-0001-11-30 00:00:00.000Z") dateChangeStatus = getDateFormatted(row[8].toString());
  //     String dateStartTestDrive = '';
  //     if(row[11] != null && row[11].toString() != "-0001-11-30 00:00:00.000Z") dateStartTestDrive = getDateFormatted(row[11].toString());
  //     String dateFinishTestDrive = '';
  //     if(row[12] != null && row[12].toString() != "-0001-11-30 00:00:00.000Z") dateFinishTestDrive = getDateFormatted(row[12].toString());
  //     bool checkTestDrive = false;
  //     if(row[14] != null && row[14] == 1) checkTestDrive = true;
  //
  //     Technic technic = Technic(row[0], row[1],  row[2],  row[3], row[4],
  //         getDateFormatted(row[5].toString()), row[6] ?? '', row[7] ?? '', dateChangeStatus,
  //         row[9] ?? '', row[10] ?? '', dateStartTestDrive, dateFinishTestDrive, row[13] ?? '', checkTestDrive);
  //     list.add(technic);
  //   }
  //   return list;
  // }
  //
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
  //
  // Future<List> getAllRepair() async{
  //   var result = await _connDB!.query('SELECT '
  //       'repairEquipment.id, '
  //       'repairEquipment.number, '
  //       'repairEquipment.category, '
  //       'repairEquipment.dislocationOld, '
  //       'repairEquipment.status, '
  //       'repairEquipment.complaint, '
  //       'repairEquipment.dateDeparture, '
  //       'repairEquipment.serviceDislocation, '
  //       'repairEquipment.dateTransferInService, '
  //       'repairEquipment.dateDepartureFromService, '
  //       'repairEquipment.worksPerformed, '
  //       'repairEquipment.costService, '
  //       'repairEquipment.diagnosisService, '
  //       'repairEquipment.recommendationsNotes, '
  //       'repairEquipment.newStatus, '
  //       'repairEquipment.newDislocation, '
  //       'repairEquipment.dateReceipt, '
  //       'repairEquipment.idTestDrive '
  //       'FROM repairEquipment');
  //
  //   var list = repairListFromMap(result);
  //   var reversedList = List.from(list.reversed);
  //   return reversedList;
  // }
  //

  //
  // Future<Repair?> getRepair(int id) async {
  //   Repair? repair = null;
  //   var result = await _connDB!.query('SELECT * FROM repairEquipment WHERE id = ?', [id]);
  //   if(result.isNotEmpty) {
  //     repair = repairListFromMap(result).first;
  //   }
  //   return repair;
  // }
  //
  // List repairListFromMap(var result){
  //   List list = [];
  //   for (var row in result) {
  //     // id-row[0], number-row[1],  category-row[2],  dislocationOld-row[3], status-row[4], complaint-row[5], dateDeparture-row[6], serviceDislocation-row[7],
  //     // dateTransferInService-row[8], dateDepartureFromService-row[9],  worksPerformed-row[10],  costService-row[11], diagnosisService-row[12],
  //     // recommendationsNotes-row[13], newStatus-row[14],  newDislocation-row[15], dateReceipt-row[16], idTestDrive-row[17]
  //     String dateDeparture = row[6].toString() == "-0001-11-30 00:00:00.000Z" ? "" : getDateFormatted(row[6].toString());
  //     String dateTransferInService = row[8].toString() == "-0001-11-30 00:00:00.000Z" ? "" : getDateFormatted(row[8].toString());
  //     String dateDepartureFromService = row[9].toString() == "-0001-11-30 00:00:00.000Z" ? "" : getDateFormatted(row[9].toString());
  //     String dateReceipt = row[16].toString() == "-0001-11-30 00:00:00.000Z" ? "" : getDateFormatted(row[16].toString());
  //
  //     Repair repair = Repair(row[0], row[1],  row[2],  row[3], row[4], row[5], dateDeparture, row[7], dateTransferInService,
  //         dateDepartureFromService, row[10],  row[11],  row[12], row[13], row[14], row[15], dateReceipt, row[17]);
  //     list.add(repair);
  //   }
  //   return list;
  // }
  //
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
  String getDateFormatted(String date) {
    return DateFormat('yyyy.MM.dd').format(DateTime.parse(date));
  }

  Future<int> insertTechnicInDB(TechnicEntity technic, String nameUser) async {
    var result = await _connDB!.query(
        'INSERT INTO equipment (number, category, name, dateBuy, cost, comment, user) VALUES (?, ?, ?, ?, ?, ?, ?)', [
      technic.internalID,
      technic.category,
      technic.name,
      technic.dateBuyTechnic,
      technic.cost,
      technic.comment,
      nameUser
    ]);

    int id = result.insertId!;
    await insertStatusInDB(id, technic.status, technic.dislocation, nameUser);

    // if (technic.dateStartTestDrive != '') {
    //   await insertTestDriveInDB(technic, nameUser);
    // }
    return result.insertId!;
  }

  Future insertStatusInDB(int id, String status, String dislocation, String nameUser) async {
    await ConnectDbMySQL.connDB.connDatabase();
    await _connDB!.query(
        'INSERT INTO statusEquipment (idEquipment, status, dislocation, date, user) VALUES (?, ?, ?, ?, ?)',
        [id, status, dislocation, DateFormat('yyyy.MM.dd').format(DateTime.now()), nameUser]);
  }

  Future insertTestDriveInDB(TechnicEntity technic, String nameUser) async {
    await ConnectDbMySQL.connDB.connDatabase();
    await _connDB!.query(
        'INSERT INTO testDrive (idEquipment, category, testDriveDislocation, dateStart, dateFinish, result, '
        'checkEquipment, user) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        [
          technic.id,
          technic.category,
          technic.testDriveDislocation,
          technic.dateStartTestDrive,
          technic.dateFinishTestDrive,
          technic.resultTestDrive,
          technic.checkboxTestDrive,
          nameUser
        ]);

    int idLastTestDrive = await findIDLastTestDriveTechnic(technic);
    int idLastRepair = await findLastRepair(technic);
    await _connDB!.query('UPDATE repairEquipment SET idTestDrive = ? WHERE id = ?', [idLastTestDrive, idLastRepair]);
  }

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

  Future<int> findIDLastTestDriveTechnic(TechnicEntity technic) async {
    await ConnectDbMySQL.connDB.connDatabase();
    var result = await _connDB!.query(
        'SELECT id FROM testDrive WHERE idEquipment = ? ORDER BY id DESC LIMIT 1',
        [
          technic.id
        ]);
    int id = lastTectDriveListFromMap(result);
    return id;
  }

  int lastTectDriveListFromMap(var result) {
    int id = -1;
    for (var row in result) {
      id = row[0];
    }
    return id;
  }

  Future<int> findLastRepair(TechnicEntity technic) async {
    await ConnectDbMySQL.connDB.connDatabase();
    var result = await _connDB!.query(
        'SELECT id FROM repairEquipment WHERE number = ? ORDER BY id DESC LIMIT 1',
        [
          technic.internalID
        ]);
    int id = lastTectDriveListFromMap(result);
    return id;
  }

  // Future updateTechnicInDB(Technic technic) async{
  //   await ConnectDbMySQL.connDB.connDatabase();
  //   await _connDB!.query(
  //       'UPDATE equipment SET category = ?, name = ?, dateBuy = ?, cost = ?, comment = ? WHERE id = ?',
  //       [
  //         technic.category,
  //         technic.name,
  //         technic.dateBuyTechnic,
  //         technic.cost,
  //         technic.comment,
  //         technic.id
  //       ]);
  // }
  //
  // Future insertRepairInDB(Repair repair) async{
  //   await ConnectDbMySQL.connDB.connDatabase();
  //   await _connDB!.query('INSERT INTO repairEquipment ('
  //       'number, '
  //       'category, '
  //       'dislocationOld, '
  //       'status, '
  //       'complaint, '
  //       'dateDeparture, '
  //       'serviceDislocation, '
  //       'dateTransferInService, '
  //       'dateDepartureFromService, '
  //       'worksPerformed, '
  //       'costService, '
  //       'diagnosisService, '
  //       'recommendationsNotes, '
  //       'newStatus, '
  //       'newDislocation, '
  //       'dateReceipt '
  //       ') VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
  //     repair.internalID,
  //     repair.category,
  //     repair.dislocationOld,
  //     repair.status,
  //     repair.complaint,
  //     repair.dateDeparture,
  //     repair.serviceDislocation,
  //     repair.dateTransferInService,
  //     repair.dateDepartureFromService,
  //     repair.worksPerformed,
  //     repair.costService,
  //     repair.diagnosisService,
  //     repair.recommendationsNotes,
  //     repair.newStatus,
  //     repair.newDislocation,
  //     repair.dateReceipt
  //   ]);
  // }
  //
  // Future updateRepairInDB(Repair repair) async{
  //   await ConnectDbMySQL.connDB.connDatabase();
  //   await _connDB!.query(
  //       'UPDATE repairEquipment SET '
  //           'complaint = ?, '
  //           'dateDeparture = ?, '
  //           'serviceDislocation = ?, '
  //           'dateTransferInService = ?, '
  //           'dateDepartureFromService = ?, '
  //           'worksPerformed = ?, '
  //           'costService = ?, '
  //           'diagnosisService = ?, '
  //           'recommendationsNotes = ?, '
  //           'newStatus = ?, '
  //           'newDislocation = ?, '
  //           'dateReceipt = ? '
  //           'WHERE id = ?',
  //       [
  //         repair.complaint,
  //         repair.dateDeparture,
  //         repair.serviceDislocation,
  //         repair.dateTransferInService,
  //         repair.dateDepartureFromService,
  //         repair.worksPerformed,
  //         repair.costService,
  //         repair.diagnosisService,
  //         repair.recommendationsNotes,
  //         repair.newStatus,
  //         repair.newDislocation,
  //         repair.dateReceipt,
  //         repair.id
  //       ]);
  // }
  //
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

  Future insertHistory(History history) async{
    await ConnectDbMySQL.connDB.connDatabase();
    await _connDB!.query('INSERT INTO history ('
        'section, idSection, typeOperation, description, login, date) '
        'VALUES (?, ?, ?, ?, ?, ?)', [
        history.section,
        history.idSection,
        history.typeOperation,
        history.description,
        history.login,
        history.date,
      ]);
  }

  // Future<List> getLastIdList() async{
  //   var resultTechnics = await _connDB!.query(
  //       'SELECT id FROM equipment ORDER BY id DESC LIMIT 1');
  //   var resultRepair = await _connDB!.query(
  //       'SELECT id FROM repairEquipment ORDER BY id DESC LIMIT 1');
  //   var resultTrouble = await _connDB!.query(
  //       'SELECT id FROM Неисправности ORDER BY id DESC LIMIT 1');
  //   var resultHistory = await _connDB!.query(
  //       'SELECT id FROM history ORDER BY id DESC LIMIT 1');
  //   var resultService = await _connDB!.query(
  //       'SELECT id FROM service ORDER BY id DESC LIMIT 1');
  //   var resultStatusForEquipment = await _connDB!.query(
  //       'SELECT id FROM statusForEquipment ORDER BY id DESC LIMIT 1');
  //   var resultNameEquipment = await _connDB!.query(
  //       'SELECT id FROM nameEquipment ORDER BY id DESC LIMIT 1');
  //   var resultPhotosalons = await _connDB!.query(
  //       'SELECT id FROM Фотосалоны ORDER BY id DESC LIMIT 1');
  //   var resultColorsForPhotosalons = await _connDB!.query(
  //       'SELECT id FROM colorsForPhotosalons ORDER BY id DESC LIMIT 1');
  //
  //   List list = [];
  //   list.add(resultTechnics.last);
  //   list.add(resultRepair.last);
  //   list.add(resultTrouble.last);
  //   list.add(resultHistory.last);
  //   list.add(resultService.last);
  //   list.add(resultStatusForEquipment.last);
  //   list.add(resultNameEquipment.last);
  //   list.add(resultPhotosalons.last);
  //   list.add(resultColorsForPhotosalons.last);
  //
  //   return list;
  // }
  //
  // Future<List> getCountList() async{
  //   var resultTechnics = await _connDB!.query(
  //       'SELECT COUNT(*) AS countEquipment FROM equipment');
  //   var resultRepair = await _connDB!.query(
  //       'SELECT COUNT(*) AS countRepair FROM repairEquipment');
  //   var resultTrouble = await _connDB!.query(
  //       'SELECT COUNT(*) AS countTrouble FROM Неисправности');
  //   var resultHistory = await _connDB!.query(
  //       'SELECT COUNT(*) AS countTrouble FROM history');
  //   var resultNameEquipment = await _connDB!.query(
  //       'SELECT COUNT(*) AS countName FROM nameEquipment');
  //   var resultPhotosalons = await _connDB!.query(
  //       'SELECT COUNT(*) AS countPhotosalons FROM Фотосалоны');
  //   var resultService = await _connDB!.query(
  //       'SELECT COUNT(*) AS countService FROM service');
  //   var resultStatusForEquipment = await _connDB!.query(
  //       'SELECT COUNT(*) AS countStatus FROM statusForEquipment');
  //   var resultColorsForPhotosalons = await _connDB!.query(
  //       'SELECT COUNT(*) AS countColorsForPhotosalons FROM colorsForPhotosalons');
  //
  //   List list = [];
  //   list.add(resultTechnics.last);
  //   list.add(resultRepair.last);
  //   list.add(resultTrouble.last);
  //   list.add(resultHistory.last);
  //   list.add(resultNameEquipment.last);
  //   list.add(resultPhotosalons.last);
  //   list.add(resultService.last);
  //   list.add(resultStatusForEquipment.last);
  //   list.add(resultColorsForPhotosalons.last);
  //
  //   return list;
  // }
  //
  // Future<List<String>> getPhotosalons() async{
  //   var result = await _connDB!.query('SELECT '
  //       'Фотосалоны.id, '
  //       'Фотосалоны.Фотосалон '
  //       'FROM Фотосалоны');
  //
  //   List<String> list = [];
  //
  //   for (var row in result) {
  //     list.add(row[1].toString());
  //   }
  //   return list;
  // }

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
}
