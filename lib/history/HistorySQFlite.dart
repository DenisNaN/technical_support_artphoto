import 'package:technical_support_artphoto/utils/utils.dart' as utils;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'History.dart';


class HistorySQFlite{
  HistorySQFlite._();

  static final HistorySQFlite db = HistorySQFlite._();
  Database? _db;

  Future database() async{
    _db ??= await init();
    return _db;
  }

  Future<Database> init() async{
    String path = join(utils.docsDir!.path, 'history.db');
    Database db = await openDatabase(path, version: 1, onOpen: (db){},
        onCreate: (Database inDB, int inVersion) async {
          await inDB.execute("CREATE TABLE IF NOT EXISTS history ("
              "id INTEGER, section TEXT, idSection INTEGER,"
              "typeOperation TEXT, description TEXT, login TEXT, date TEXT)");
        });
    return db;
  }

  History historyFromMap(Map inMap){

    History history = History(
        inMap['id'],
        inMap['section'],
        inMap['idSection'],
        inMap['typeOperation'],
        inMap['description'],
        inMap['login'],
        inMap['date'],
    );
    return history;
  }

  Map<String, dynamic> historyToMap(History inhistory){

    Map<String, dynamic> map = Map<String, dynamic>();
    map['id'] = inhistory.id;
    map['section'] = inhistory.section;
    map['idSection'] = inhistory.idSection;
    map['typeOperation'] = inhistory.typeOperation;
    map['description'] = inhistory.description;
    map['login'] = inhistory.login;
    map['date'] = inhistory.date;
    return map;
  }

  Future insertHistory(History inHistory) async {
    Database db = await database();

    await db.execute(
        "INSERT INTO history (id, section, idSection, "
            "typeOperation, description, login, date) "
            "VALUES (?, ?, ?, ?, ?, ?, ?)",
        [
          inHistory.id,
          inHistory.section,
          inHistory.idSection,
          inHistory.typeOperation,
          inHistory.description,
          inHistory.login,
          inHistory.date
        ]
    );
  }

  // Future<Technic> get(int inID) async {
  //   Database db = await database;
  //   var rec = await db.query("technic", where: "id = ?", whereArgs: [inID]);
  //   return technicFromMap(rec.first);
  // }

  Future<List> getAllHistory() async {
    Database db = await database();
    var recs = await db.query("history");
    var list = recs.isNotEmpty ? recs.map((m) => historyFromMap(m)).toList() : [];
    var reversedList = List.from(list.reversed);
    return reversedList;
  }

  Future updateHistory(History inHistory) async {
    Database db = await database();
    return await db.update("history", historyToMap(inHistory),
        where: "id = ?", whereArgs: [inHistory.id]);
  }

  Future deleteTables() async{
    Database db = await database();
    await db.rawQuery("DROP TABLE IF EXISTS history");
  }

  Future createTables() async{
    Database db = await database();
    await db.rawQuery("CREATE TABLE IF NOT EXISTS history ("
        "id INTEGER, section TEXT, idSection INTEGER,"
        "typeOperation TEXT, description TEXT, login TEXT, date TEXT)");
  }
}