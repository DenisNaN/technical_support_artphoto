import 'package:technical_support_artphoto/utils/utils.dart' as utils;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'Trouble.dart';

class TroubleSQFlite{
  TroubleSQFlite._();

  static final TroubleSQFlite db = TroubleSQFlite._();
  Database? _db;

  Future get database async{
    _db ??= await init();
    return _db;
  }

  Future<Database> init() async{
    String path = join(utils.docsDir!.path, 'trouble.db');
    Database db = await openDatabase(path, version: 1, onOpen: (db){},
        onCreate: (Database inDB, int inVersion) async {
          await inDB.execute("CREATE TABLE IF NOT EXISTS trouble ("
              "id INTEGER, photosalon TEXT, dateTrouble TEXT, employee TEXT, "
              "internalID INTEGER, trouble TEXT, dateCheckFixTroubleEmployee TEXT,"
              "employeeCheckFixTrouble TEXT, dateCheckFixTroubleEngineer TEXT, "
              "engineerCheckFixTrouble TEXT, photoTrouble TEXT)");
        });
    return db;
  }

  Trouble troubleFromMap(Map inMap){

    Trouble trouble = Trouble(
        inMap['id'],
        inMap['photosalon'],
        inMap['dateTrouble'],
        inMap['employee'],
        inMap['internalID'],
        inMap['trouble'],
        inMap['dateCheckFixTroubleEmployee'],
        inMap['employeeCheckFixTrouble'],
        inMap['dateCheckFixTroubleEngineer'],
        inMap['engineerCheckFixTrouble'],
        inMap['photoTrouble']
    );
    return trouble;
  }

  Map<String, dynamic> troubleToMap(Trouble inTrouble){

    Map<String, dynamic> map = Map<String, dynamic>();
    map['id'] = inTrouble.id;
    map['photosalon'] = inTrouble.photosalon;
    map['dateTrouble'] = inTrouble.dateTrouble;
    map['employee'] = inTrouble.employee;
    map['internalID'] = inTrouble.internalID;
    map['trouble'] = inTrouble.trouble;
    map['dateCheckFixTroubleEmployee'] = inTrouble.dateCheckFixTroubleEmployee;
    map['employeeCheckFixTrouble'] = inTrouble.employeeCheckFixTrouble;
    map['dateCheckFixTroubleEngineer'] = inTrouble.dateCheckFixTroubleEngineer;
    map['engineerCheckFixTrouble'] = inTrouble.engineerCheckFixTrouble;
    map['photoTrouble'] = inTrouble.photoTrouble;
    return map;
  }

  Future insertTrouble(Trouble inTrouble) async {
    Database db = await database;

    await db.execute(
        "INSERT INTO trouble (id, photosalon, dateTrouble, employee, internalID, "
            "trouble, dateCheckFixTroubleEmployee, employeeCheckFixTrouble, "
            "dateCheckFixTroubleEngineer, engineerCheckFixTrouble, photoTrouble) "
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
        [
          inTrouble.id,
          inTrouble.photosalon,
          inTrouble.dateTrouble,
          utils.LoginPassword.login,
          inTrouble.internalID,
          inTrouble.trouble,
          inTrouble.dateCheckFixTroubleEmployee,
          inTrouble.employeeCheckFixTrouble,
          inTrouble.dateCheckFixTroubleEngineer,
          inTrouble.engineerCheckFixTrouble,
          inTrouble.photoTrouble,
        ]
    );
  }

  // Future<Technic> get(int inID) async {
  //   Database db = await database;
  //   var rec = await db.query("technic", where: "id = ?", whereArgs: [inID]);
  //   return technicFromMap(rec.first);
  // }

  Future<List> getAllTrouble() async {
    Database db = await database;
    var recs = await db.query("trouble");
    var list = recs.isNotEmpty ? recs.map((m) => troubleFromMap(m)).toList() : [];
    var reversedList = List.from(list.reversed);
    return reversedList;
  }

  Future updateTrouble(Trouble inTrouble) async {
    Database db = await database;
    return await db.update("trouble", troubleToMap(inTrouble),
        where: "id = ?", whereArgs: [inTrouble.id]);
  }

  // Future delete(int inID) async {
  //   Database db = await database;
  //   return await db.delete("technic", where: "id = ?", whereArgs: [inID]);
  // }

  Future deleteTables() async{
    Database db = await database;
    await db.rawQuery("DROP TABLE IF EXISTS trouble");
  }

  Future createTables() async{
    Database db = await database;
    await db.rawQuery("CREATE TABLE IF NOT EXISTS trouble ("
        "id INTEGER, photosalon TEXT, dateTrouble TEXT, employee TEXT, "
        "internalID INTEGER, trouble TEXT, dateCheckFixTroubleEmployee TEXT,"
        "employeeCheckFixTrouble TEXT, dateCheckFixTroubleEngineer TEXT, "
        "engineerCheckFixTrouble TEXT, photoTrouble TEXT)");
  }

  Future getTrouble() async{
    Database db = await database;
    var recs = await db.rawQuery('SELECT * FROM trouble');
    recs.isNotEmpty ? recs.map((m) => print(m)) : [];
  }
}