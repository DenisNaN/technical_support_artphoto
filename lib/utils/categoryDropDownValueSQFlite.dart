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
    return await db.rawInsert(
        'INSERT INTO $nameTable ('
            'id, '
            '$category) '
            'VALUES (?, ?)',
        [id, value]);
  }

  Future<List> getCategory(String nameTable) async {
    Database db = await database;
    List<Map> recs = await db.query(nameTable);

    List<DropDownValueModel> list = [];
    for(int i = recs.length; i < 0; i--){
      list.add(DropDownValueModel(name: recs[i].values.last, value: recs[i].values.last));
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