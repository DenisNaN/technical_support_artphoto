import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:technical_support_artphoto/utils/utils.dart' as utils;

class NameEquipmentSQFlite{
  NameEquipmentSQFlite._();

  static final NameEquipmentSQFlite db = NameEquipmentSQFlite._();
  Database? _db;

  Future get database async{
    _db ??= await init();
    return _db;
  }

  Future<Database> init() async{
    String path = join(utils.docsDir!.path, 'nameEquipment.db');
    Database db = await openDatabase(path, version: 1, onOpen: (db){},
        onCreate: (Database inDB, int inVersion) async {
          await inDB.execute("CREATE TABLE IF NOT EXISTS nameEquipment ("
              "id INTEGER, "
              "name TEXT)");
        });
    return db;
  }

  Future create(String name) async {
    Database db = await database;

    var val = await db.rawQuery("SELECT MAX(id) + 1 AS id FROM nameEquipment");
    int id = val.first["id"] == null ? 1 : val.first["id"] as int;

    return await db.rawInsert(
        "INSERT INTO repair ("
            "id, "
            "name) "
            "VALUES (?, ?)",
        [id, name]);
  }

  Future<List> getNameEquipment() async {
    Database db = await database;
    var recs = await db.query("nameEquipment");

    List<DropDownValueModel> list = [];
    for(var row in recs){
      list.add(DropDownValueModel(name: row[1].toString(), value: row[1].toString()));
    }

    return list;
  }

  Future update(int id, String name) async {
    Map<String, dynamic> map = <String, dynamic>{};
    map["id"] = id;
    map["name"] = name;

    Database db = await database;
    return await db.update("nameEquipment", map,
        where: "id = ?", whereArgs: [id]);
  }

  Future delete(int id) async {
    Database db = await database;
    return await db.delete("nameEquipment", where: "id = ?", whereArgs: [id]);
  }
}