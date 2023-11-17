import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:technical_support_artphoto/utils/utils.dart' as utils;

class CategorySQFlite{
  CategorySQFlite._();

  static final CategorySQFlite db = CategorySQFlite._();
  Database? _db;

  Future get database async{
    _db ??= await init();
    return _db;
  }

  // Future<Database> init() async{
  //   String path = join(utils.docsDir!.path, 'nameEquipment.db');
  //   Database db = await openDatabase(path, version: 1, onOpen: (db){},
  //       onCreate: (Database inDB, int inVersion) async {
  //         await inDB.execute("CREATE TABLE IF NOT EXISTS nameEquipment ("
  //             "id INTEGER, "
  //             "name TEXT)");
  //       });
  //   return db;
  // }

  Future<Database> init() async{
    String path = join(utils.docsDir!.path, 'category.db');
    Database db = await openDatabase(path);
    db.rawQuery("CREATE TABLE IF NOT EXISTS nameEquipment ("
        "id INTEGER, "
        "name TEXT)");
    db.rawQuery("CREATE TABLE IF NOT EXISTS photosalons ("
        "id INTEGER, "
        "Фотосалон TEXT)");
    db.rawQuery("CREATE TABLE IF NOT EXISTS service ("
        "id INTEGER, "
        "repairmen TEXT)");
    db.rawQuery("CREATE TABLE IF NOT EXISTS statusForEquipment ("
        "id INTEGER, "
        "status TEXT)");
    return db;
  }

  Future create(String nameTable, String category, int id, String value) async {
    Database db = await database;
    // var val = await db.rawQuery(
    //     'SELECT MAX(id) + 1 AS id FROM $nameTable');
    // var id = val.first['id'];
    // id ??= 1;
    return await db.rawInsert(
        'INSERT INTO $nameTable ('
            'id, '
            '$category) '
            'VALUES (?, ?)',
        [id, value]);
  }

  Future<List> getCategory(String nameTable) async {
    Database db = await database;
    var recs = await db.query(nameTable);

    List<DropDownValueModel> list = [];
    for(var row in recs){
      list.add(DropDownValueModel(name: row[1].toString(), value: row[1].toString()));
    }
    return list;
  }

  Future deleteTable(String nameTable) async{
    Database db = await database;
    return await db.rawQuery('DROP TABLE IF EXISTS $nameTable');
  }

  Future createTable(String nameTable, String nameCategory) async{
    Database db = await database;
    return await db.rawQuery('CREATE TABLE IF NOT EXISTS $nameTable ('
        'id INTEGER, '
        '$nameCategory TEXT)');
  }
}