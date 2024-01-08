import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:mysql1/mysql1.dart';
import 'package:technical_support_artphoto/repair/Repair.dart';
import 'package:technical_support_artphoto/technics/Technic.dart';
import 'package:technical_support_artphoto/trouble/Trouble.dart';
import 'package:technical_support_artphoto/utils/utils.dart';

class ConnectToDBMySQL {
  ConnectToDBMySQL._();

  static final ConnectToDBMySQL connDB = ConnectToDBMySQL._();
  MySqlConnection? _connDB;

  Future connDatabase() async {
    _connDB ??= await _init();
  }

  Future<MySqlConnection> _init() async {
    MySqlConnection connDB = await MySqlConnection.connect(ConnectionSettings(
        // host: '', port: , user: '', db: '', password: '')) ;
        print('connectDatabase');
        return connDB;
    }

  Future<List> getAllTechnics() async{
    var result = await _connDB!.query('SELECT '
        'equipment.id, '
        'equipment.number, '
        'equipment.name, '
        'equipment.category, '
        'equipment.cost, '
        'equipment.dateBuy, '
        's.status, '
        's.dislocation, '
        'equipment.comment, '
        't.dateStart, '
        't.dateFinish, '
        't.result, '
        't.checkEquipment '
        'FROM equipment '
        'LEFT JOIN (SELECT * FROM statusEquipment s1 WHERE NOT EXISTS (SELECT 1 FROM statusEquipment s2 WHERE s2.id > s1.id AND s2.idEquipment = s1.idEquipment)) s ON s.idEquipment = equipment.id '
        'LEFT JOIN (SELECT * FROM testDrive t1 WHERE NOT EXISTS (SELECT 1 FROM testDrive t2 WHERE t2.id > t1.id AND t2.idEquipment = t1.idEquipment)) t ON t.idEquipment = equipment.id '
        'ORDER BY equipment.id');

    var list = [];
    for (var row in result) {
      // id-row[0], number-row[1],  name-row[2],  category-row[3], cost-row[4],
      // dateBuy-row[5], status-row[6], dislocation-row[7], comment-row[8]
      // dateStart-row[9], dateFinish-row[10], resultTestDrive-row[11],
      // checkTestDrive-row[12]

      String dateStartTestDrive = '';
      if(row[9] != null && row[9].toString() != "-0001-11-30 00:00:00.000Z") dateStartTestDrive = getDateFormatted(row[9].toString());
      String dateFinishTestDrive = '';
      if(row[10] != null && row[10].toString() != "-0001-11-30 00:00:00.000Z") dateFinishTestDrive = getDateFormatted(row[10].toString());
      bool checkTestDrive = false;
      if(row[12] != null && row[12] == 1) checkTestDrive = true;

      Technic technic = Technic(row[0], row[1],  row[2],  row[3], row[4],
          getDateFormatted(row[5].toString()), row[6] ?? '', row[7] ?? '', row[8],
          dateStartTestDrive, dateFinishTestDrive, row[11] ?? '', checkTestDrive);
      list.add(technic);
    }
    var reversedList = List.from(list.reversed);
    return reversedList;
  }

  Future<List> getRangeGreaterOnIDTechnics(int id) async{
    var result = await _connDB!.query('SELECT '
        'equipment.id, '
        'equipment.number, '
        'equipment.name, '
        'equipment.category, '
        'equipment.cost, '
        'equipment.dateBuy, '
        'statusEquipment.status, '
        'statusEquipment.dislocation, '
        'equipment.comment, '
        'testDrive.dateStart, '
        'testDrive.dateFinish, '
        'testDrive.result, '
        'testDrive.checkEquipment '
        'FROM equipment '
        'LEFT JOIN (SELECT * FROM statusEquipment s1 WHERE NOT EXISTS (SELECT 1 FROM statusEquipment s2 WHERE s2.id > s1.id AND s2.idEquipment = s1.idEquipment)) s ON s.idEquipment = equipment.id '
        'LEFT JOIN (SELECT * FROM testDrive t1 WHERE NOT EXISTS (SELECT 1 FROM testDrive t2 WHERE t2.id > t1.id AND t2.idEquipment = t1.idEquipment)) t ON t.idEquipment = equipment.id '
        'WHERE equipment.id > ?', [id]);

    var list = [];
    for (var row in result) {
      // id-row[0], number-row[1],  name-row[2],  category-row[3], cost-row[4],
      // dateBuy-row[5], status-row[6], dislocation-row[7], comment-row[8]
      // dateStart-row[9], dateFinish-row[10], resultTestDrive-row[11],
      // checkTestDrive-row[12]

      String dateStartTestDrive = '';
      if(row[9] != null && row[9].toString() != "-0001-11-30 00:00:00.000Z") dateStartTestDrive = getDateFormatted(row[9].toString());
      String dateFinishTestDrive = '';
      if(row[10] != null && row[10].toString() != "-0001-11-30 00:00:00.000Z") dateFinishTestDrive = getDateFormatted(row[10].toString());
      bool checkTestDrive = false;
      if(row[12] != null && row[12] == 1) checkTestDrive = true;

      Technic technic = Technic(row[0], row[1],  row[2],  row[3], row[4],
          getDateFormatted(row[5].toString()), row[6] ?? '', row[7] ?? '', row[8],
          dateStartTestDrive, dateFinishTestDrive, row[11] ?? '', checkTestDrive);
      list.add(technic);
    }
    var reversedList = List.from(list.reversed);
    return reversedList;
  }

  Future<List> getAllRepair() async{
    var result = await _connDB!.query('SELECT '
        'repairEquipment.id, '
        'repairEquipment.number, '
        'repairEquipment.category, '
        'repairEquipment.dislocationOld, '
        'repairEquipment.status, '
        'repairEquipment.complaint, '
        'repairEquipment.dateDeparture, '
        'repairEquipment.serviceDislocation, '
        'repairEquipment.dateTransferForService, '
        'repairEquipment.dateDepartureFromService, '
        'repairEquipment.worksPerformed, '
        'repairEquipment.costService, '
        'repairEquipment.diagnosisService, '
        'repairEquipment.recommendationsNotes, '
        'repairEquipment.newStatus, '
        'repairEquipment.newDislocation, '
        'repairEquipment.dateReceipt '
        'FROM repairEquipment');

    var list = [];
    for (var row in result) {
      // id-row[0], number-row[1],  category-row[2],  dislocationOld-row[3], status-row[4], complaint-row[5], dateDeparture-row[6], serviceDislocation-row[7],
      // dateTransferForService-row[8], dateDepartureFromService-row[9],  worksPerformed-row[10],  costService-row[11], diagnosisService-row[12],
      // recommendationsNotes-row[13], newStatus-row[14],  newDislocation-row[15], dateReceipt-row[16]
      String dateDeparture = row[6].toString() == "-0001-11-30 00:00:00.000Z" ? "" : getDateFormatted(row[6].toString());
      String dateTransferForService = row[8].toString() == "-0001-11-30 00:00:00.000Z" ? "" : getDateFormatted(row[8].toString());
      String dateDepartureFromService = row[9].toString() == "-0001-11-30 00:00:00.000Z" ? "" : getDateFormatted(row[9].toString());
      String dateReceipt = row[16].toString() == "-0001-11-30 00:00:00.000Z" ? "" : getDateFormatted(row[16].toString());

      Repair repair = Repair(row[0], row[1],  row[2],  row[3], row[4], row[5], dateDeparture, row[7], dateTransferForService,
          dateDepartureFromService, row[10],  row[11],  row[12], row[13], row[14], row[15], dateReceipt);
      list.add(repair);
    }
    var reversedList = List.from(list.reversed);
    return reversedList;
  }

  Future<List> getRangeGreaterOnIDRepairs(int id) async{
    var result = await _connDB!.query('SELECT '
        'repairEquipment.id, '
        'repairEquipment.number, '
        'repairEquipment.category, '
        'repairEquipment.dislocationOld, '
        'repairEquipment.status, '
        'repairEquipment.complaint, '
        'repairEquipment.dateDeparture, '
        'repairEquipment.serviceDislocation, '
        'repairEquipment.dateTransferForService, '
        'repairEquipment.dateDepartureFromService, '
        'repairEquipment.worksPerformed, '
        'repairEquipment.costService, '
        'repairEquipment.diagnosisService, '
        'repairEquipment.recommendationsNotes, '
        'repairEquipment.newStatus, '
        'repairEquipment.newDislocation, '
        'repairEquipment.dateReceipt '
        'FROM repairEquipment WHERE id > ?', [id]);

    var list = [];
    for (var row in result) {
      // id-row[0], number-row[1],  category-row[2],  dislocationOld-row[3], status-row[4], complaint-row[5], dateDeparture-row[6], serviceDislocation-row[7],
      // dateTransferForService-row[8], dateDepartureFromService-row[9],  worksPerformed-row[10],  costService-row[11], diagnosisService-row[12],
      // recommendationsNotes-row[13], newStatus-row[14],  newDislocation-row[15], dateReceipt-row[16]
      String dateDeparture = row[6].toString() == "-0001-11-30 00:00:00.000Z" ? "" : getDateFormatted(row[6].toString());
      String dateTransferForService = row[8].toString() == "-0001-11-30 00:00:00.000Z" ? "" : getDateFormatted(row[8].toString());
      String dateDepartureFromService = row[9].toString() == "-0001-11-30 00:00:00.000Z" ? "" : getDateFormatted(row[9].toString());
      String dateReceipt = row[16].toString() == "-0001-11-30 00:00:00.000Z" ? "" : getDateFormatted(row[19].toString());

      Repair repair = Repair(row[0], row[1],  row[2],  row[3], row[4], row[5], dateDeparture, row[7], dateTransferForService,
          dateDepartureFromService, row[10],  row[11],  row[12], row[13], row[14], row[15], dateReceipt);
      list.add(repair);
    }
    return list;
  }

  Future<List> getAllTrouble() async{
    var result = await _connDB!.query('SELECT '
        'id, Фотосалон, ДатаНеисправности, Сотрудник, НомерТехники, Неисправность, '
        'ДатаУстрСотр, СотрПодтверУстр, '
        'ДатаУстрИнженер, ИнженерПодтверУстр, Фотография '
        'FROM Неисправности');

    var list = [];
    for (var row in result) {
      // id-row[0], photosalon-row[1],  dateTrouble-row[2],  employee-row[3], internalID-row[4], trouble-row[5],
      // dateCheckFixTroubleEmployee-row[6], employeeCheckFixTrouble-row[7],  dateCheckFixTroubleEngineer-row[8],
      // engineerCheckFixTrouble-row[9], photoTrouble-row[10]
      String dateTrouble = row[2].toString() == "-0001-11-30 00:00:00.000Z" ? "" : getDateFormatted(row[2].toString());
      String dateCheckFixTroubleEmployee = row[6].toString() == "-0001-11-30 00:00:00.000Z" ? "" : getDateFormatted(row[6].toString());
      String dateCheckFixTroubleEngineer = row[8].toString() == "-0001-11-30 00:00:00.000Z" ? "" : getDateFormatted(row[8].toString());

      Blob blobImage = row[10];
      Uint8List image = Uint8List.fromList(blobImage.toBytes());

      Trouble trouble = Trouble(row[0], row[1].toString(),  dateTrouble,  row[3].toString(), row[4], row[5].toString(), dateCheckFixTroubleEmployee,
          row[7].toString(), dateCheckFixTroubleEngineer, row[9].toString(), image);
      list.add(trouble);
    }
    var reversedList = List.from(list.reversed);
    return reversedList;
  }

  Future<List> getRangeGreaterOnIDTrouble(int id) async{
    var result = await _connDB!.query('SELECT '
        'id, Фотосалон, ДатаНеисправности, Сотрудник, НомерТехники, Неисправность, '
        'ДатаУстрСотр, СотрПодтверУстр, '
        'ДатаУстрИнженер, ИнженерПодтверУстр, Фотография '
        'FROM Неисправности WHERE id > ?', [id]);

    var list = [];
    for (var row in result) {
      // id-row[0], photosalon-row[1],  dateTrouble-row[2],  employee-row[3], internalID-row[4], trouble-row[5],
      // dateCheckFixTroubleEmployee-row[6], employeeCheckFixTrouble-row[7],  dateCheckFixTroubleEngineer-row[8],
      // engineerCheckFixTrouble-row[9], photoTrouble-row[10]
      String dateTrouble = row[2].toString() == "-0001-11-30 00:00:00.000Z" ? "" : getDateFormatted(row[2].toString());
      String dateCheckFixTroubleEmployee = row[6].toString() == "-0001-11-30 00:00:00.000Z" ? "" : getDateFormatted(row[6].toString());
      String dateCheckFixTroubleEngineer = row[8].toString() == "-0001-11-30 00:00:00.000Z" ? "" : getDateFormatted(row[8].toString());

      Trouble trouble = Trouble(row[0], row[1],  dateTrouble,  row[3], row[4], row[5], dateCheckFixTroubleEmployee,
          row[7], dateCheckFixTroubleEngineer, row[9], row[10]);
      list.add(trouble);
    }
    return list;
  }

  String getDateFormatted(String date){
    return DateFormat('yyyy.MM.dd').format(DateTime.parse(date));
  }

  Future insertTechnicInDB(Technic technic) async{
    await ConnectToDBMySQL.connDB.connDatabase();
    await _connDB!.query(
        'INSERT INTO equipment (number, category, name, dateBuy, cost, comment, user) VALUES (?, ?, ?, ?, ?, ?, ?)',
        [technic.internalID,  technic.category, technic.name, technic.dateBuyTechnic, technic.cost, technic.comment,
        LoginPassword.login]);

   insertStatusInDB(technic.id!, technic.status, technic.dislocation);

    if(technic.dateStartTestDrive != '') {
      insertTestDriveInDB(technic);
    }
  }

  Future insertTestDriveInDB(Technic technic) async{
    await ConnectToDBMySQL.connDB.connDatabase();
    await _connDB!.query(
        'INSERT INTO testDrive (idEquipment, category, dateStart, dateFinish, result, '
            'checkEquipment, user) VALUES (?, ?, ?, ? , ?, ?, ?)',
        [
          technic.id,
          technic.category,
          technic.dateStartTestDrive,
          technic.dateFinishTestDrive,
          technic.resultTestDrive,
          technic.checkboxTestDrive,
          LoginPassword.login
        ]);
  }

  Future insertStatusInDB(int id, String status, String dislocation) async{
    await ConnectToDBMySQL.connDB.connDatabase();
    await _connDB!.query(
        'INSERT INTO statusEquipment (idEquipment, status, dislocation, date, user) '
            'VALUES (?, ?, ?, ?, ?)',
        [id, status, dislocation, DateFormat('yyyy.MM.dd').format(DateTime.now()),
          LoginPassword.login]);
  }

  Future updateTechnicInDB(Technic technic) async{
    await ConnectToDBMySQL.connDB.connDatabase();
    await _connDB!.query(
        'UPDATE equipment SET category = ?, name = ?, dateBuy = ?, cost = ?, comment = ? WHERE id = ?',
        [
          technic.category,
          technic.name,
          technic.dateBuyTechnic,
          technic.cost,
          technic.comment,
          technic.id
        ]);
  }

  Future insertRepairInDB(Repair repair) async{
    await ConnectToDBMySQL.connDB.connDatabase();
    await _connDB!.query('INSERT INTO repairEquipment ('
        'number, '
        'category, '
        'dislocationOld, '
        'status, '
        'complaint, '
        'dateDeparture, '
        'serviceDislocation, '
        'dateTransferForService, '
        'dateDepartureFromService, '
        'worksPerformed, '
        'costService, '
        'diagnosisService, '
        'recommendationsNotes, '
        'dateStartTestDrive, '
        'dateFinishTestDrive, '
        'resultTestDrive, '
        'newStatus, '
        'newDislocation, '
        'dateReceipt '
        ') VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
      repair.internalID,
      repair.category,
      repair.dislocationOld,
      repair.status,
      repair.complaint,
      repair.dateDeparture,
      repair.serviceDislocation,
      repair.dateTransferForService,
      repair.dateDepartureFromService,
      repair.worksPerformed,
      repair.costService,
      repair.diagnosisService,
      repair.recommendationsNotes,
      repair.newStatus,
      repair.newDislocation,
      repair.dateReceipt
    ]);
  }

  Future updateRepairInDB(Repair repair) async{
    await ConnectToDBMySQL.connDB.connDatabase();
    await _connDB!.query(
        'UPDATE repairEquipment SET '
            'complaint = ?, '
            'dateDeparture = ?, '
            'serviceDislocation = ?, '
            'dateTransferForService = ?, '
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
          repair.complaint,
          repair.dateDeparture,
          repair.serviceDislocation,
          repair.dateTransferForService,
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

  Future insertTroubleInDB(Trouble trouble) async{
    await ConnectToDBMySQL.connDB.connDatabase();
    await _connDB!.query('INSERT INTO Неисправности ('
        'Фотосалон, ДатаНеисправности, Сотрудник, НомерТехники, Неисправность, '
        'ДатаУстрСотр, СотрПодтверУстр, '
        'ДатаУстрИнженер, ИнженерПодтверУстр, Фотография) '
        'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
      trouble.photosalon,
      trouble.dateTrouble,
      trouble.employee,
      trouble.internalID,
      trouble.trouble,
      trouble.dateCheckFixTroubleEmployee,
      trouble.employeeCheckFixTrouble,
      trouble.dateCheckFixTroubleEngineer,
      trouble.engineerCheckFixTrouble,
      trouble.photoTrouble
    ]);
  }

  Future updateTroubleInDB(Trouble trouble) async{
    await ConnectToDBMySQL.connDB.connDatabase();
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
          trouble.dateTrouble,
          trouble.employee,
          trouble.internalID,
          trouble.trouble,
          trouble.dateCheckFixTroubleEmployee,
          trouble.employeeCheckFixTrouble,
          trouble.dateCheckFixTroubleEngineer,
          trouble.engineerCheckFixTrouble,
          trouble.photoTrouble,
          trouble.id
        ]);
  }
  
  Future<List> getLastIdList() async{
    var resultTechnics = await _connDB!.query(
        'SELECT id FROM equipment ORDER BY id DESC LIMIT 1');
    var resultRepair = await _connDB!.query(
        'SELECT id FROM repairEquipment ORDER BY id DESC LIMIT 1');
    var resultTrouble = await _connDB!.query(
        'SELECT id FROM Неисправности ORDER BY id DESC LIMIT 1');
    var resultService = await _connDB!.query(
        'SELECT id FROM service ORDER BY id DESC LIMIT 1');
    var resultStatusForEquipment = await _connDB!.query(
        'SELECT id FROM statusForEquipment ORDER BY id DESC LIMIT 1');
    var resultNameEquipment = await _connDB!.query(
        'SELECT id FROM nameEquipment ORDER BY id DESC LIMIT 1');
    var resultPhotosalons = await _connDB!.query(
        'SELECT id FROM Фотосалоны ORDER BY id DESC LIMIT 1');

    List list = [];
    list.add(resultTechnics.last);
    list.add(resultRepair.last);
    list.add(resultTrouble.last);
    list.add(resultService.last);
    list.add(resultStatusForEquipment.last);
    list.add(resultNameEquipment.last);
    list.add(resultPhotosalons.last);

    return list;
  }

  Future<List> getCountList() async{
    var resultTechnics = await _connDB!.query(
        'SELECT COUNT(*) AS countEquipment FROM equipment');
    var resultRepair = await _connDB!.query(
        'SELECT COUNT(*) AS countRepair FROM repairEquipment');
    var resultTrouble = await _connDB!.query(
        'SELECT COUNT(*) AS countTrouble FROM Неисправности');
    var resultNameEquipment = await _connDB!.query(
        'SELECT COUNT(*) AS countName FROM nameEquipment');
    var resultPhotosalons = await _connDB!.query(
        'SELECT COUNT(*) AS countPhotosalons FROM Фотосалоны');
    var resultService = await _connDB!.query(
        'SELECT COUNT(*) AS countService FROM service');
    var resultStatusForEquipment = await _connDB!.query(
        'SELECT COUNT(*) AS countStatus FROM statusForEquipment');

    List list = [];
    list.add(resultTechnics.last);
    list.add(resultRepair.last);
    list.add(resultTrouble.last);
    list.add(resultNameEquipment.last);
    list.add(resultPhotosalons.last);
    list.add(resultService.last);
    list.add(resultStatusForEquipment.last);

    return list;
  }

  Future<Map<String, String>> getLoginPassword() async{
    var result = await _connDB!.query(
        'SELECT * FROM loginPassword');

    Map<String, String> map = {};
    for (var row in result) {
      map[row[2]] = row[1];
    }
    return map;
  }

  Future<List> getPhotosalons() async{
    var result = await _connDB!.query('SELECT '
        'Фотосалоны.id, '
        'Фотосалоны.Фотосалон '
        'FROM Фотосалоны');

    List<String> list = [];

    for (var row in result) {
      list.add(row[1].toString());
    }
    return list;
  }

  Future<List> getStatusForEquipment() async{
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

  Future<List> getService() async{
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

  Future<List> getNameEquipment() async{
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
}
