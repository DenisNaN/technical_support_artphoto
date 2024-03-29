import 'package:technical_support_artphoto/technics/Technic.dart';
import 'package:technical_support_artphoto/utils/utils.dart' as utils;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class TechnicSQFlite{
  TechnicSQFlite._();

  static final TechnicSQFlite db = TechnicSQFlite._();
  Database? _db;

  Future database() async{
    _db ??= await init();
    return _db;
  }

  Future<Database> init() async{
    String path = join(utils.docsDir!.path, 'technic.db');
    Database db = await openDatabase(path, version: 1, onOpen: (db){},
        onCreate: (Database inDB, int inVersion) async {
          await inDB.execute("CREATE TABLE IF NOT EXISTS equipment ("
              "id INTEGER, internalID INTEGER, name TEXT, category TEXT, "
              "cost INTEGER, dateBuyTechnic TEXT, status TEXT, dislocation TEXT, dateChangeStatus TEXT, "
              "comment TEXT, testDriveDislocation TEXT, dateStartTestDrive TEXT, "
              "dateFinishTestDrive TEXT, resultTestDrive TEXT, "
              "checkboxTestDrive TEXT, user TEXT)");
        });
    return db;
  }

  Technic technicFromMap(Map inMap){
    bool _checkboxTestDrive = false;
    inMap['checkboxTestDrive'] == '0' ? _checkboxTestDrive = false : _checkboxTestDrive = true;

    Technic technic = Technic(
        inMap['id'],
        inMap['internalID'],
        inMap['name'],
        inMap['category'],
        inMap['cost'],
        inMap['dateBuyTechnic'],
        inMap['status'],
        inMap['dislocation'],
        inMap['dateChangeStatus'],
        inMap['comment'],
        inMap['testDriveDislocation'],
        inMap['dateStartTestDrive'],
        inMap['dateFinishTestDrive'],
        inMap['resultTestDrive'],
        _checkboxTestDrive
    );
    return technic;
  }

  Map<String, dynamic> technicToMap(Technic inTechnic){
    String _checkboxTestDrive = '';
    inTechnic.checkboxTestDrive ? _checkboxTestDrive = '1' : _checkboxTestDrive = '0';

    Map<String, dynamic> map = Map<String, dynamic>();
    map['id'] = inTechnic.id;
    map['internalID'] = inTechnic.internalID;
    map['name'] = inTechnic.name;
    map['category'] = inTechnic.category;
    map['cost'] = inTechnic.cost;
    map['dateBuyTechnic'] = inTechnic.dateBuyTechnic;
    map['status'] = inTechnic.status;
    map['dislocation'] = inTechnic.dislocation;
    map['dateChangeStatus'] = inTechnic.dateChangeStatus;
    map['comment'] = inTechnic.comment;
    map['testDriveDislocation'] = inTechnic.testDriveDislocation;
    map['dateStartTestDrive'] = inTechnic.dateStartTestDrive;
    map['dateFinishTestDrive'] = inTechnic.dateFinishTestDrive;
    map['resultTestDrive'] = inTechnic.resultTestDrive;
    map['checkboxTestDrive'] = _checkboxTestDrive;
    return map;
  }

  Future insertEquipment(Technic inTechnic) async {
    Database db = await database();

    await db.execute(
        "INSERT INTO equipment (id, internalID, name, category, cost, "
            "dateBuyTechnic, status, dislocation, dateChangeStatus, comment, testDriveDislocation,"
            " dateStartTestDrive, dateFinishTestDrive, resultTestDrive, "
            "checkboxTestDrive, user) "
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
        [
          inTechnic.id,
          inTechnic.internalID,
          inTechnic.name,
          inTechnic.category,
          inTechnic.cost,
          inTechnic.dateBuyTechnic,
          inTechnic.status,
          inTechnic.dislocation,
          inTechnic.dateChangeStatus,
          inTechnic.comment,
          inTechnic.testDriveDislocation,
          inTechnic.dateStartTestDrive,
          inTechnic.dateFinishTestDrive,
          inTechnic.resultTestDrive,
          inTechnic.checkboxTestDrive,
          utils.LoginPassword.login
        ]
    );
  }

  Future<List> getAllTechnics() async {
    Database db = await database();
    var recs = await db.query("equipment");
    var list = recs.isNotEmpty ? recs.map((m) => technicFromMap(m)).toList() : [];
    var reversedList = List.from(list.reversed);
    return reversedList;
  }

  Future updateTechnic(Technic inTechnic) async {
    Database db = await database();
    return await db.update("equipment", technicToMap(inTechnic),
        where: "id = ?", whereArgs: [inTechnic.id]);
  }

  Future updateStatusDislocationTechnic(int id, String status, String dislocation) async {
    Database db = await database();
    return await db.execute(
        'UPDATE equipment SET '
        'status = ?, '
        'dislocation = ?, '
        'dateChangeStatus = ? '
        'WHERE id = ?',
      [status, dislocation, DateFormat('yyyy.MM.dd').format(DateTime.now()), id]
    );
  }

  Future deleteTables() async{
    Database db = await database();
    await db.rawQuery("DROP TABLE IF EXISTS equipment");
  }

  Future createTables() async{
    Database db = await database();
    await db.rawQuery("CREATE TABLE IF NOT EXISTS equipment ("
        "id INTEGER, internalID INTEGER, name TEXT, category TEXT,"
        "cost INTEGER, dateBuyTechnic TEXT, status TEXT, dislocation TEXT, dateChangeStatus TEXT, "
        "comment TEXT, testDriveDislocation TEXT, dateStartTestDrive TEXT, "
        "dateFinishTestDrive TEXT, resultTestDrive TEXT,"
        "checkboxTestDrive TEXT, user TEXT)");
  }

  Future<Technic> get(int inID) async {
    Database db = await database();
    var rec = await db.query("equipment", where: "id = ?", whereArgs: [inID]);
    return technicFromMap(rec.first);
  }
}