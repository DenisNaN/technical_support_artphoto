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
    db.rawQuery("CREATE TABLE IF NOT EXISTS colorsForPhotosalons ("
        "id INTEGER, "
        "photosalon TEXT, "
        "color TEXT)");
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

  Future<List<String>> getCategory(String nameTable) async {
    Database db = await database;
    List<Map> recs = await db.query(nameTable);

    List<String> list = [];
    for(int i = recs.length - 1; i >= 0; i--){
      list.add(recs[i].values.last);
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

  Future<Map<String, int>> getColorsForPhotosalons() async {
    Database db = await database;
    List<Map> recs = await db.query('colorsForPhotosalons');

    Map<String, int> map = {};
    recs.forEach((element) {
      map[element['photosalon']] = int.parse(element['color']);
    });
    return map;
  }

  Future createColorsForPhotosalons(int id, String key, String value) async {
    Database db = await database;
    return await db.rawInsert(
        'INSERT INTO colorsForPhotosalons ('
            'id, photosalon, color) '
            'VALUES (?, ?, ?)',
        [id, key, value]);
  }

  Future deleteTableColorsForPhotosalons() async{
    Database db = await database;
    return await db.rawQuery('DROP TABLE IF EXISTS colorsForPhotosalons');
  }

  Future createTableColorsForPhotosalons() async{
    Database db = await database;
    return await db.rawQuery('CREATE TABLE IF NOT EXISTS colorsForPhotosalons ('
        'id INTEGER, photosalon TEXT, color TEXT)');
  }
}