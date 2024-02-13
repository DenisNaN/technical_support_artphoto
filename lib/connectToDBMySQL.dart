import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:mysql1/mysql1.dart';
import 'package:technical_support_artphoto/repair/Repair.dart';
import 'package:technical_support_artphoto/technics/Technic.dart';
import 'package:technical_support_artphoto/trouble/Trouble.dart';
import 'package:technical_support_artphoto/history/History.dart';
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
        't.testDriveDislocation, '
        't.dateStart, '
        't.dateFinish, '
        't.result, '
        't.checkEquipment '
        'FROM equipment '
        'LEFT JOIN (SELECT * FROM statusEquipment s1 WHERE NOT EXISTS (SELECT 1 FROM statusEquipment s2 WHERE s2.id > s1.id AND s2.idEquipment = s1.idEquipment)) s ON s.idEquipment = equipment.id '
        'LEFT JOIN (SELECT * FROM testDrive t1 WHERE NOT EXISTS (SELECT 1 FROM testDrive t2 WHERE t2.id > t1.id AND t2.idEquipment = t1.idEquipment)) t ON t.idEquipment = equipment.id '
        'ORDER BY equipment.id');

    var list = technicListFromMap(result);
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
        's.status, '
        's.dislocation, '
        'equipment.comment, '
        't.testDriveDislocation, '
        't.dateStart, '
        't.dateFinish, '
        't.result, '
        't.checkEquipment '
        'FROM equipment '
        'LEFT JOIN (SELECT * FROM statusEquipment s1 WHERE NOT EXISTS (SELECT 1 FROM statusEquipment s2 WHERE s2.id > s1.id AND s2.idEquipment = s1.idEquipment)) s ON s.idEquipment = equipment.id '
        'LEFT JOIN (SELECT * FROM testDrive t1 WHERE NOT EXISTS (SELECT 1 FROM testDrive t2 WHERE t2.id > t1.id AND t2.idEquipment = t1.idEquipment)) t ON t.idEquipment = equipment.id '
        'WHERE equipment.id > ?', [id]);

    var list = technicListFromMap(result);
    var reversedList = List.from(list.reversed);
    return reversedList;
  }

  Future<Technic?> getTechnic(int id) async {
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
        't.testDriveDislocation, '
        't.dateStart, '
        't.dateFinish, '
        't.result, '
        't.checkEquipment '
        'FROM equipment '
        'LEFT JOIN (SELECT * FROM statusEquipment s1 WHERE NOT EXISTS (SELECT 1 FROM statusEquipment s2 WHERE s2.id > s1.id AND s2.idEquipment = s1.idEquipment)) s ON s.idEquipment = equipment.id '
        'LEFT JOIN (SELECT * FROM testDrive t1 WHERE NOT EXISTS (SELECT 1 FROM testDrive t2 WHERE t2.id > t1.id AND t2.idEquipment = t1.idEquipment)) t ON t.idEquipment = equipment.id '
        'WHERE equipment.id = ?', [id]);
    Technic? technic = technicListFromMap(result).first;
    return technic;
  }

  List technicListFromMap(var result){
    List list = [];
    for (var row in result) {
      // id-row[0], number-row[1],  name-row[2],  category-row[3], cost-row[4],
      // dateBuy-row[5], status-row[6], dislocation-row[7], comment-row[8], testDriveDislocation-row[9],
      // dateStart-row[10], dateFinish-row[11], resultTestDrive-row[12],
      // checkTestDrive-row[13]

      String dateStartTestDrive = '';
      if(row[10] != null && row[10].toString() != "-0001-11-30 00:00:00.000Z") dateStartTestDrive = getDateFormatted(row[10].toString());
      String dateFinishTestDrive = '';
      if(row[11] != null && row[11].toString() != "-0001-11-30 00:00:00.000Z") dateFinishTestDrive = getDateFormatted(row[11].toString());
      bool checkTestDrive = false;
      if(row[13] != null && row[13] == 1) checkTestDrive = true;

      Technic technic = Technic(row[0], row[1],  row[2],  row[3], row[4],
          getDateFormatted(row[5].toString()), row[6] ?? '', row[7] ?? '', row[8],
          row[9] ?? '', dateStartTestDrive, dateFinishTestDrive, row[12] ?? '', checkTestDrive);
      list.add(technic);
    }
    return list;
  }

  Future<List> getAllTestDrive() async {
    List list = [];
    var result = await _connDB!.query('SELECT * FROM testDrive');
    // id-row[0], idEquipment-row[1],  category-row[2],  testDriveDislocation-row[3],
    // dateStart-row[4], dateFinish-row[5], result-row[6], checkEquipment-row[7], user-row[8]

    for(var row in result){
      String dateStartTestDrive = '';
      if(row[4] != null && row[4].toString() != "-0001-11-30 00:00:00.000Z") dateStartTestDrive = getDateFormatted(row[4].toString());
      String dateFinishTestDrive = '';
      if(row[5] != null && row[5].toString() != "-0001-11-30 00:00:00.000Z") dateFinishTestDrive = getDateFormatted(row[5].toString());
      bool checkTestDrive = false;
      if(row[7] != null && row[7] == 1) checkTestDrive = true;
      
      Technic testDriveTechnic = Technic.testDrive(
          row[1], row[2], row[3], dateStartTestDrive, dateFinishTestDrive,
          row[6], checkTestDrive, row[8]);
      list.add(testDriveTechnic);
    }
    return list;
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
        'repairEquipment.dateTransferInService, '
        'repairEquipment.dateDepartureFromService, '
        'repairEquipment.worksPerformed, '
        'repairEquipment.costService, '
        'repairEquipment.diagnosisService, '
        'repairEquipment.recommendationsNotes, '
        'repairEquipment.newStatus, '
        'repairEquipment.newDislocation, '
        'repairEquipment.dateReceipt '
        'FROM repairEquipment');

    var list = repairListFromMap(result);
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
        'repairEquipment.dateTransferInService, '
        'repairEquipment.dateDepartureFromService, '
        'repairEquipment.worksPerformed, '
        'repairEquipment.costService, '
        'repairEquipment.diagnosisService, '
        'repairEquipment.recommendationsNotes, '
        'repairEquipment.newStatus, '
        'repairEquipment.newDislocation, '
        'repairEquipment.dateReceipt '
        'FROM repairEquipment WHERE id > ?', [id]);

    var list = repairListFromMap(result);
    var reversedList = List.from(list.reversed);
    return reversedList;
  }

  Future<Repair?> getRepair(int id) async {
    var result = await _connDB!.query('SELECT * FROM repairEquipment WHERE id = ?', [id]);
    Repair? repair = repairListFromMap(result).first;
    return repair;
  }

  List repairListFromMap(var result){
    List list = [];
    for (var row in result) {
      // id-row[0], number-row[1],  category-row[2],  dislocationOld-row[3], status-row[4], complaint-row[5], dateDeparture-row[6], serviceDislocation-row[7],
      // dateTransferInService-row[8], dateDepartureFromService-row[9],  worksPerformed-row[10],  costService-row[11], diagnosisService-row[12],
      // recommendationsNotes-row[13], newStatus-row[14],  newDislocation-row[15], dateReceipt-row[16]
      String dateDeparture = row[6].toString() == "-0001-11-30 00:00:00.000Z" ? "" : getDateFormatted(row[6].toString());
      String dateTransferInService = row[8].toString() == "-0001-11-30 00:00:00.000Z" ? "" : getDateFormatted(row[8].toString());
      String dateDepartureFromService = row[9].toString() == "-0001-11-30 00:00:00.000Z" ? "" : getDateFormatted(row[9].toString());
      String dateReceipt = row[16].toString() == "-0001-11-30 00:00:00.000Z" ? "" : getDateFormatted(row[16].toString());

      Repair repair = Repair(row[0], row[1],  row[2],  row[3], row[4], row[5], dateDeparture, row[7], dateTransferInService,
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

    var list = troubleListFromMap(result);
    var reversedList = List.from(list.reversed);
    return reversedList;
  }

  Future<List> getRangeGreaterOnIDTrouble(int id) async{
    var result = await _connDB!.query('SELECT '
        'id, Фотосалон, ДатаНеисправности, Сотрудник, НомерТехники, Неисправность, '
        'ДатаУстрСотр, СотрПодтверУстр, '
        'ДатаУстрИнженер, ИнженерПодтверУстр, Фотография '
        'FROM Неисправности WHERE id > ?', [id]);

    var list = troubleListFromMap(result);
    var reversedList = List.from(list.reversed);
    return reversedList;
  }

  Future<Trouble?> getTrouble(int id) async {
    var result = await _connDB!.query('SELECT * FROM Неисправности WHERE id = ?', [id]);
    Trouble? trouble = troubleListFromMap(result).first;
    return trouble;
  }

  List troubleListFromMap(var result) {
    List list = [];
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
    return list;
  }

  Future<List> getAllHistory() async{
    var result = await _connDB!.query('SELECT * FROM history');
    var list = historyListFromMap(result);
    var reversedList = List.from(list.reversed);
    return reversedList;
  }

  Future<List> getRangeGreaterOnIDHistory(int id) async{
    var result = await _connDB!.query('SELECT * FROM history WHERE id > ?', [id]);
    var list = historyListFromMap(result);
    var reversedList = List.from(list.reversed);
    return reversedList;
  }

  List historyListFromMap(var result) {
    List list = [];
    for (var row in result) {
      // id-row[0], section-row[1],  idSection-row[2],  typeOperation-row[3], description-row[4], login-row[5],
      // date-row[6]
      String dateHystory = row[6].toString() == "-0001-11-30 00:00:00.000Z" ? "" : getDateFormatted(row[6].toString());
      History history = History(row[0], row[1],  row[2],  row[3], row[4].toString(), row[5].toString(), dateHystory);
      list.add(history);
    }
    return list;
  }

  String getDateFormatted(String date){
    return DateFormat('yyyy.MM.dd').format(DateTime.parse(date));
  }

  Future<int> insertTechnicInDB(Technic technic) async{
    await ConnectToDBMySQL.connDB.connDatabase();
    var result = await _connDB!.query(
        'INSERT INTO equipment (number, category, name, dateBuy, cost, comment, user) VALUES (?, ?, ?, ?, ?, ?, ?)',
        [technic.internalID,  technic.category, technic.name, technic.dateBuyTechnic, technic.cost, technic.comment,
        LoginPassword.login]);

    int id = result.insertId!;
    await insertStatusInDB(id, technic.status, technic.dislocation);

    if(technic.dateStartTestDrive != '') {
      await insertTestDriveInDB(technic);
    }
    return result.insertId!;
  }

  Future insertTestDriveInDB(Technic technic) async{
    await ConnectToDBMySQL.connDB.connDatabase();
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
          LoginPassword.login
        ]);
  }

  Future updateTestDriveInDB(Technic technic) async{
    int checkBox = 0;
    if(technic.checkboxTestDrive) checkBox = 1;

    await ConnectToDBMySQL.connDB.connDatabase();
    int id = await findLastTestDriveTechnic(technic);
    await _connDB!.query(
        'UPDATE testDrive SET testDriveDislocation = ?, dateStart = ?, dateFinish = ?, '
            'result = ?, checkEquipment = ? WHERE id = ?',
        [
          technic.testDriveDislocation,
          technic.dateStartTestDrive,
          technic.dateFinishTestDrive,
          technic.resultTestDrive,
          checkBox,
          id
        ]);
  }

  Future<int> findLastTestDriveTechnic(Technic technic) async {
    await ConnectToDBMySQL.connDB.connDatabase();
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
        'dateTransferInService, '
        'dateDepartureFromService, '
        'worksPerformed, '
        'costService, '
        'diagnosisService, '
        'recommendationsNotes, '
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
      repair.dateTransferInService,
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
          repair.complaint,
          repair.dateDeparture,
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

  Future<int> insertTroubleInDB(Trouble trouble) async{
    await ConnectToDBMySQL.connDB.connDatabase();
    var result = await _connDB!.query('INSERT INTO Неисправности ('
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
      trouble.photoTrouble ?? ''
    ]);
    return result.insertId!;
  }

  Future updateTroubleInDB(Trouble trouble) async{
    await ConnectToDBMySQL.connDB.connDatabase();
    await _connDB!.query(
        'UPDATE Неисправности SET '
            'ДатаУстрСотр = ?, '
            'СотрПодтверУстр = ?, '
            'ДатаУстрИнженер = ?, '
            'ИнженерПодтверУстр = ? '
            'WHERE id = ?',
        [
          trouble.dateCheckFixTroubleEmployee,
          trouble.employeeCheckFixTrouble,
          trouble.dateCheckFixTroubleEngineer,
          trouble.engineerCheckFixTrouble,
          trouble.id
        ]);
  }

  Future insertHistory(History history) async{
    await ConnectToDBMySQL.connDB.connDatabase();
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
  
  Future<List> getLastIdList() async{
    var resultTechnics = await _connDB!.query(
        'SELECT id FROM equipment ORDER BY id DESC LIMIT 1');
    var resultRepair = await _connDB!.query(
        'SELECT id FROM repairEquipment ORDER BY id DESC LIMIT 1');
    var resultTrouble = await _connDB!.query(
        'SELECT id FROM Неисправности ORDER BY id DESC LIMIT 1');
    var resultHistory = await _connDB!.query(
        'SELECT id FROM history ORDER BY id DESC LIMIT 1');
    var resultService = await _connDB!.query(
        'SELECT id FROM service ORDER BY id DESC LIMIT 1');
    var resultStatusForEquipment = await _connDB!.query(
        'SELECT id FROM statusForEquipment ORDER BY id DESC LIMIT 1');
    var resultNameEquipment = await _connDB!.query(
        'SELECT id FROM nameEquipment ORDER BY id DESC LIMIT 1');
    var resultPhotosalons = await _connDB!.query(
        'SELECT id FROM Фотосалоны ORDER BY id DESC LIMIT 1');
    var resultColorsForPhotosalons = await _connDB!.query(
        'SELECT id FROM colorsForPhotosalons ORDER BY id DESC LIMIT 1');

    List list = [];
    list.add(resultTechnics.last);
    list.add(resultRepair.last);
    list.add(resultTrouble.last);
    list.add(resultHistory.last);
    list.add(resultService.last);
    list.add(resultStatusForEquipment.last);
    list.add(resultNameEquipment.last);
    list.add(resultPhotosalons.last);
    list.add(resultColorsForPhotosalons.last);

    return list;
  }

  Future<List> getCountList() async{
    var resultTechnics = await _connDB!.query(
        'SELECT COUNT(*) AS countEquipment FROM equipment');
    var resultRepair = await _connDB!.query(
        'SELECT COUNT(*) AS countRepair FROM repairEquipment');
    var resultTrouble = await _connDB!.query(
        'SELECT COUNT(*) AS countTrouble FROM Неисправности');
    var resultHistory = await _connDB!.query(
        'SELECT COUNT(*) AS countTrouble FROM history');
    var resultNameEquipment = await _connDB!.query(
        'SELECT COUNT(*) AS countName FROM nameEquipment');
    var resultPhotosalons = await _connDB!.query(
        'SELECT COUNT(*) AS countPhotosalons FROM Фотосалоны');
    var resultService = await _connDB!.query(
        'SELECT COUNT(*) AS countService FROM service');
    var resultStatusForEquipment = await _connDB!.query(
        'SELECT COUNT(*) AS countStatus FROM statusForEquipment');
    var resultColorsForPhotosalons = await _connDB!.query(
        'SELECT COUNT(*) AS countColorsForPhotosalons FROM colorsForPhotosalons');

    List list = [];
    list.add(resultTechnics.last);
    list.add(resultRepair.last);
    list.add(resultTrouble.last);
    list.add(resultHistory.last);
    list.add(resultNameEquipment.last);
    list.add(resultPhotosalons.last);
    list.add(resultService.last);
    list.add(resultStatusForEquipment.last);
    list.add(resultColorsForPhotosalons.last);

    return list;
  }

  Future<Map<String, List>> getLoginPassword() async{
    var result = await _connDB!.query(
        'SELECT * FROM loginPassword');

    Map<String, List> map = {};
    for (var row in result) {
      map[row[2]] = [row[1], row[3]];
    }
    return map;
  }

  Future<List<String>> getPhotosalons() async{
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

  Future<List<String>> getStatusForEquipment() async{
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

  Future<List<String>> getService() async{
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

  Future<List<String>> getNameEquipment() async{
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

  Future<Map<String, int>> getColorForEquipment() async{
    var result = await _connDB!.query('SELECT * FROM colorsForPhotosalons');

    Map<String, int> map = {};
    for (var row in result) {
      map[row[1]] = int.parse(row[2]);
    }
    return map;
  }
}
