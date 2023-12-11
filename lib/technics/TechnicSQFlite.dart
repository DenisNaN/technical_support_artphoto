import 'package:technical_support_artphoto/technics/Technic.dart';
import 'package:technical_support_artphoto/utils/utils.dart' as utils;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class TechnicSQFlite{
  TechnicSQFlite._();

  static final TechnicSQFlite db = TechnicSQFlite._();
  Database? _db;

  Future get database async{
    _db ??= await init();
    return _db;
  }

  Future<Database> init() async{
    String path = join(utils.docsDir!.path, 'technic.db');
    Database db = await openDatabase(path, version: 1, onOpen: (db){},
        onCreate: (Database inDB, int inVersion) async {

          await inDB.execute("CREATE TABLE IF NOT EXISTS Equipment ("
              "id INTEGER, internalID INTEGER, category TEXT, name TEXT, "
              "dateBuyTechnic TEXT, cost INTEGER, comment TEXT)");

          await inDB.execute('CREATE TABLE IF NOT EXISTS statusEquipment ('
              'id INTEGER, idEquipment INTEGER, status TEXT, dislocation TEXT, date TEXT)');
          
          await inDB.execute('CREATE TABLE IF NOT EXISTS testDrive ('
              'id INTEGER, idEquipment INTEGER, category TEXT, '
              'dateStart TEXT, dateFinish TEXT, result TEXT, '
              'checkEquipment INTEGER');
        });
    return db;
  }

  Technic technicFromMap(Map inMap){
    Technic technic = Technic(
        inMap['id'],
        inMap['internalID'],
        inMap['name'],
        inMap['category'],
        inMap['cost'],
        inMap['dateBuyTechnic'],
        inMap['status'],
        inMap['dislocation'],
        inMap['comment'],
        inMap['dateStartTestDrive'],
        inMap['dateFinishTestDrive'],
        inMap['resultTestDrive'],
        inMap['checkboxTestDrive'],
    );
    return technic;
  }

  Map<String, dynamic> technicToMap(Technic inTechnic){
    Map<String, dynamic> map = Map<String, dynamic>();
    map['id'] = inTechnic.id;
    map['internalID'] = inTechnic.internalID;
    map['name'] = inTechnic.name;
    map['category'] = inTechnic.category;
    map['cost'] = inTechnic.cost;
    map['dateBuyTechnic'] = inTechnic.dateBuyTechnic;
    map['status'] = inTechnic.status;
    map['dislocation'] = inTechnic.dislocation;
    map['comment'] = inTechnic.comment;
    map['dateStartTestDrive'] = inTechnic.dateStartTestDrive;
    map['dateFinishTestDrive'] = inTechnic.dateFinishTestDrive;
    map['resultTestDrive'] = inTechnic.resultTestDrive;
    map['checkboxTestDrive'] = inTechnic.checkboxTestDrive;
    return map;
  }

  Future create(Technic inTechnic) async {
    Database db = await database;

    var resultEquipment = await db.rawInsert(
        "INSERT INTO Equipment (id, internalID, category, name, dateBuyTechnic, "
            "cost, comment) "
            "VALUES (?, ?, ?, ?, ?, ?, ?)",
        [inTechnic.id, inTechnic.internalID, inTechnic.category, inTechnic.name,
          inTechnic.dateBuyTechnic, inTechnic.cost, inTechnic.comment]
    );

    var resultStatus = await db.rawInsert(
        'INSERT INTO statusEquipment (id, idEquipment, status, dislocation, '
            'date) VALUES (?, ?, ?, ?, ?)',
      [inTechnic.id, inTechnic.internalID, inTechnic.status, inTechnic.dislocation,
        DateFormat('yyyy.MM.dd').format(DateTime.now())]
    );

    var resultTestDrive = await db.rawInsert(
        'INSERT INTO testDrive (id, idEquipment, category, dateStart, dateFinish, '
            'result, checkEquipment) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [inTechnic.id, inTechnic.internalID, inTechnic.category, inTechnic.dateStartTestDrive,
      inTechnic.dateFinishTestDrive, inTechnic.resultTestDrive, inTechnic.checkboxTestDrive]
    );
  }

  // Future<Technic> get(int inID) async {
  //   Database db = await database;
  //   var rec = await db.query("technic", where: "id = ?", whereArgs: [inID]);
  //   return technicFromMap(rec.first);
  // }

  // "id INTEGER, internalID INTEGER, category TEXT, name TEXT, "
  // "dateBuyTechnic TEXT, cost INTEGER, comment TEXT)");
  Future<List> getAllTechnics() async {
    Database db = await database;
    // var recs = await db.query("technic");
    var recs = await db.rawQuery('SELECT '
        'equipment.id, '
        'equipment.internalID, '
        'equipment.name, '
        'equipment.category, '
        'equipment.cost, '
        'equipment.dateBuyTechnic, '
        'statusEquipment.status, '
        'statusEquipment.dislocation, '
        'equipment.comment, '
        'testDrive.dateStart, '
        'testDrive.dateFinish, '
        'testDrive.result, '
        'testDrive.checkEquipment '
        'FROM equipment '
    // 'JOIN statusEquipment ON (SELECT idEquipment FROM statusEquipment ORDER BY id DESC LIMIT 1) = equipment.id');
        'JOIN statusEquipment ON statusEquipment.idEquipment = equipment.id '
        'JOIN testDrive ON testDrive.idEquipment = equipment.id');
    var list = recs.isNotEmpty ? recs.map((m) => technicFromMap(m)).toList() : [];
    var reversedList = List.from(list.reversed);
    return reversedList;
  }

  Future update(Technic inTechnic) async {
    Database db = await database;
    return await db.update("Equipment", technicToMap(inTechnic),
        where: "id = ?", whereArgs: [inTechnic.id]);
  }

  // Future delete(int inID) async {
  //   Database db = await database;
  //   return await db.delete("technic", where: "id = ?", whereArgs: [inID]);
  // }

  Future deleteTable() async{
    Database db = await database;
    await db.rawQuery("DROP TABLE IF EXISTS Equipment");
    await db.rawQuery("DROP TABLE IF EXISTS statusEquipment");
    await db.rawQuery("DROP TABLE IF EXISTS testDrive");
  }

  Future createTable() async{
    Database db = await database;
    await db.rawQuery("CREATE TABLE IF NOT EXISTS Equipment ("
        "id INTEGER, internalID INTEGER, category TEXT, name TEXT, "
        "dateBuyTechnic TEXT, cost INTEGER, comment TEXT)");
    await db.rawQuery('CREATE TABLE IF NOT EXISTS statusEquipment ('
        'id INTEGER, idEquipment INTEGER, status TEXT, dislocation TEXT, date TEXT)');
    await db.rawQuery('CREATE TABLE IF NOT EXISTS testDrive ('
        'id INTEGER, idEquipment INTEGER, category TEXT, '
        'dateStart TEXT, dateFinish TEXT, result TEXT, '
        'checkEquipment INTEGER)');
  }
}