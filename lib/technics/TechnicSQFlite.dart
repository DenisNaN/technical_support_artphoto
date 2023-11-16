import 'package:technical_support_artphoto/technics/Technic.dart';
import 'package:technical_support_artphoto/utils/utils.dart' as utils;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
          await inDB.execute("CREATE TABLE IF NOT EXISTS technic ("
              "id INTEGER, "
              "internalID INTEGER, "
              "name TEXT, "
              "category TEXT, "
              "cost INTEGER, "
              "dateBuyTechnic TEXT, "
              "status TEXT, "
              "dislocation TEXT, "
              "comment TEXT)");
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
        inMap['comment']);
    return technic;
  }

  Map<String, dynamic> repairToMap(Technic inTechnic){
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
    return map;
  }

  Future create(Technic inTechnic) async {
    Database db = await database;

    return await db.rawInsert(
        "INSERT INTO technic ("
            "id, "
            "internalID, "
            "name, "
            "category, "
            "cost, "
            "dateBuyTechnic, "
            "status, "
            "dislocation, "
            "comment) "
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
        [inTechnic.id,
          inTechnic.internalID,
          inTechnic.name,
          inTechnic.category,
          inTechnic.cost,
          inTechnic.dateBuyTechnic,
          inTechnic.status,
          inTechnic.dislocation,
          inTechnic.comment]);
  }

  Future<Technic> get(int inID) async {
    Database db = await database;
    var rec = await db.query("technic", where: "id = ?", whereArgs: [inID]);
    return technicFromMap(rec.first);
  }

  Future<List> getAllTechnics() async {
    Database db = await database;
    var recs = await db.query("technic");
    var list = recs.isNotEmpty ? recs.map((m) => technicFromMap(m)).toList() : [];
    var reversedList = List.from(list.reversed);
    return reversedList;
  }

  Future update(Technic inTechnic) async {
    Database db = await database;
    return await db.update("technic", repairToMap(inTechnic),
        where: "id = ?", whereArgs: [inTechnic.id]);
  }

  Future delete(int inID) async {
    Database db = await database;
    return await db.delete("technic", where: "id = ?", whereArgs: [inID]);
  }

  Future deleteTable() async{
    Database db = await database;
    return await db.rawQuery("DROP TABLE IF EXISTS technic");
  }

  Future createTable() async{
    Database db = await database;
    return await db.rawQuery("CREATE TABLE IF NOT EXISTS technic ("
        "id, "
        "internalID, "
        "name, "
        "category, "
        "cost, "
        "dateBuyTechnic, "
        "status, "
        "dislocation, "
        "comment)");
  }
}