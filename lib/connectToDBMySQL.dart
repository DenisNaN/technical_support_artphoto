import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:intl/intl.dart';
import 'package:mysql1/mysql1.dart';
import 'package:technical_support_artphoto/repair/Repair.dart';
import 'package:technical_support_artphoto/technics/Technic.dart';

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
        'equipment.id, equipment.number, '
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
        'testDrive.checkEquipment'
        'FROM equipment '
        // 'JOIN statusEquipment ON (SELECT idEquipment FROM statusEquipment ORDER BY id DESC LIMIT 1) = equipment.id');
        'JOIN statusEquipment ON statusEquipment.idEquipment = equipment.id'
        'JOIN testDrive ON testDrive.idEquipment = equipment.id');

    var list = [];
    for (var row in result) {
      // id-row[0], number-row[1],  name-row[2],  category-row[3], cost-row[4], dateBuy-row[5], status-row[6], dislocation-row[7], comment-row[8]
      Technic technic = Technic(row[0], row[1],  row[2],  row[3], row[4],
          getDateFormatted(row[5].toString()), row[6], row[7], row[8],
          row[9], row[10], row[11], row[12]);
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
        'repairEquipment.dateStartTestDrive, '
        'repairEquipment.dateFinishTestDrive, '
        'repairEquipment.resultTestDrive, '
        'repairEquipment.newStatus, '
        'repairEquipment.newDislocation, '
        'repairEquipment.dateReceipt '
        'FROM repairEquipment');

    var list = [];
    for (var row in result) {
      // id-row[0], number-row[1],  category-row[2],  dislocationOld-row[3], status-row[4], complaint-row[5], dateDeparture-row[6], serviceDislocation-row[7],
      // dateTransferForService-row[8], dateDepartureFromService-row[9],  worksPerformed-row[10],  costService-row[11], diagnosisService-row[12],
      // recommendationsNotes-row[13], dateStartTestDrive-row[14], dateFinishTestDrive-row[15], resultTestDrive-row[16],
      // newStatus-row[17],  newDislocation-row[18], dateReceipt-row[19]
      String dateDeparture = getDateFormatted(row[6].toString()) == "30 ноября 0001" ? "Нет даты" : getDateFormatted(row[6].toString());
      String dateTransferForService = getDateFormatted(row[8].toString()) == "30 ноября 0001" ? "Нет даты" : getDateFormatted(row[8].toString());
      String dateDepartureFromService = getDateFormatted(row[9].toString()) == "30 ноября 0001" ? "Нет даты" : getDateFormatted(row[9].toString());
      String dateStartTestDrive = getDateFormatted(row[14].toString()) == "30 ноября 0001" ? "Нет даты" : getDateFormatted(row[14].toString());
      String dateFinishTestDrive = getDateFormatted(row[15].toString()) == "30 ноября 0001" ? "Нет даты" : getDateFormatted(row[15].toString());
      String dateReceipt = getDateFormatted(row[19].toString()) == "30 ноября 0001" ? "Нет даты" : getDateFormatted(row[19].toString());

      Repair repair = Repair(row[0], row[1],  row[2],  row[3], row[4], row[5], dateDeparture, row[7], dateTransferForService,
          dateDepartureFromService, row[10],  row[11],  row[12], row[13], dateStartTestDrive, dateFinishTestDrive,
          row[16], row[17], row[18], dateReceipt);
      list.add(repair);
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
        'equipment.comment '
        'FROM equipment JOIN statusEquipment ON statusEquipment.idEquipment = equipment.id WHERE equipment.id > ?', [id]);

    var list = [];
    for (var row in result) {
      // id-row[0], number-row[1],  name-row[2],  category-row[3], cost-row[4], dateBuy-row[5], status-row[6], dislocation-row[7], comment-row[8]
      Technic technic = Technic(row[0], row[1],  row[2],  row[3],
          row[4], getDateFormatted(row[5].toString()), row[6], row[7],
          row[8], row[9], row[10], row[11], row[12]);
      list.add(technic);
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
        'repairEquipment.dateStartTestDrive, '
        'repairEquipment.dateFinishTestDrive, '
        'repairEquipment.resultTestDrive, '
        'repairEquipment.newStatus, '
        'repairEquipment.newDislocation, '
        'repairEquipment.dateReceipt '
        'FROM repairEquipment WHERE id > ?', [id]);

    var list = [];
    for (var row in result) {
      // id-row[0], number-row[1],  category-row[2],  dislocationOld-row[3], status-row[4], complaint-row[5], dateDeparture-row[6], serviceDislocation-row[7],
      // dateTransferForService-row[8], dateDepartureFromService-row[9],  worksPerformed-row[10],  costService-row[11], diagnosisService-row[12],
      // recommendationsNotes-row[13], dateStartTestDrive-row[14], dateFinishTestDrive-row[15], resultTestDrive-row[16],
      // newStatus-row[17],  newDislocation-row[18], dateReceipt-row[19]
      String dateDeparture = getDateFormatted(row[6].toString()) == "30 ноября 0001" ? "Нет даты" : getDateFormatted(row[6].toString());
      String dateTransferForService = getDateFormatted(row[8].toString()) == "30 ноября 0001" ? "Нет даты" : getDateFormatted(row[8].toString());
      String dateDepartureFromService = getDateFormatted(row[9].toString()) == "30 ноября 0001" ? "Нет даты" : getDateFormatted(row[9].toString());
      String dateStartTestDrive = getDateFormatted(row[14].toString()) == "30 ноября 0001" ? "Нет даты" : getDateFormatted(row[14].toString());
      String dateFinishTestDrive = getDateFormatted(row[15].toString()) == "30 ноября 0001" ? "Нет даты" : getDateFormatted(row[15].toString());
      String dateReceipt = getDateFormatted(row[19].toString()) == "30 ноября 0001" ? "Нет даты" : getDateFormatted(row[19].toString());

      Repair repair = Repair(row[0], row[1],  row[2],  row[3], row[4], row[5], dateDeparture, row[7], dateTransferForService,
          dateDepartureFromService, row[10],  row[11],  row[12], row[13], dateStartTestDrive, dateFinishTestDrive,
          row[16], row[17], row[18], dateReceipt);
      list.add(repair);
    }
    return list;
  }

  String getDateFormatted(String date){
    return DateFormat('d MMMM yyyy', "ru_RU").format(DateTime.parse(date));
  }

  Future insertTechnicInDB(Technic technic) async{
    await ConnectToDBMySQL.connDB.connDatabase();
    var resultEquipment = await _connDB!.query(
        'INSERT INTO equipment (number, category, name, dateBuy, cost, comment) VALUES (?, ?, ?, ?, ?, ?)',
        [technic.internalID,  technic.category, technic.name, technic.dateBuyTechnic, technic.cost, technic.comment]);

    var statusEquipment = await _connDB!.query(
        'INSERT INTO statusEquipment (idEquipment, status, dislocation, date) '
            'VALUES ((SELECT id FROM equipment ORDER BY id DESC LIMIT 1), ?, ?, ?)',
        [technic.status, technic.dislocation, DateFormat('yyyy.MM.dd').format(DateTime.now())]);

    var testDrive = await _connDB!.query(
      'INSERT INTO testDrive (idEquipment, category, dateStart, dateFinish, result, '
          'checkEquipment) VALUES ((SELECT id FROM equipment ORDER BY id DESC LIMIT 1), ?, ?, ? , ?, ?)',
      [technic.category, technic.dateStartTestDrive, technic.dateFinishTestDrive, technic.resultTestDrive, technic.checkboxTestDrive]);
  }

  Future insertRepairInDB(Repair repair) async{
    await ConnectToDBMySQL.connDB.connDatabase();
    var resultHistory = await _connDB!.query('INSERT INTO repairEquipment ('
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
        ') VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
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
      repair.dateStartTestDrive,
      repair.dateFinishTestDrive,
      repair.resultTestDrive,
      repair.newStatus,
      repair.newDislocation,
      repair.dateReceipt
    ]);
  }
  
  Future<List> getLastIdList() async{
    var resultTechnics = await _connDB!.query(
        'SELECT id FROM equipment ORDER BY id DESC LIMIT 1');
    var resultRepair = await _connDB!.query(
        'SELECT id FROM repairEquipment ORDER BY id DESC LIMIT 1');
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

    List<DropDownValueModel> list = [];

    for (var row in result) {
      list.add(DropDownValueModel(name: row[1].toString(), value: row[1].toString()));
    }
    return list;
  }

  Future<List> getStatusForEquipment() async{
    var result = await _connDB!.query('SELECT '
        'statusForEquipment.id, '
        'statusForEquipment.status '
        'FROM statusForEquipment');

    List<DropDownValueModel> list = [];
    for (var row in result) {
      list.add(DropDownValueModel(name: row[1].toString(), value: row[1].toString()));
    }
    return list;
  }

  Future<List> getService() async{
    var result = await _connDB!.query('SELECT '
        'service.id, '
        'service.repairmen '
        'FROM service');

    List<DropDownValueModel> list = [];
    for (var row in result) {
      list.add(DropDownValueModel(name: row[1].toString(), value: row[1].toString()));
    }
    return list;
  }

  Future<List> getNameEquipment() async{
    var result = await _connDB!.query('SELECT '
        'nameEquipment.id, '
        'nameEquipment.name '
        'FROM nameEquipment');

    List<DropDownValueModel> list = [];
    for (var row in result) {
      list.add(DropDownValueModel(name: row[1].toString(), value: row[1].toString()));
    }
    return list;
  }
}
