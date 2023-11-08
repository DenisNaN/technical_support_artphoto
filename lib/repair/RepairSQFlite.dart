import 'package:technical_support_artphoto/utils/utils.dart' as utils;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'Repair.dart';

class RepairSQFlite{
  RepairSQFlite._();

  static final RepairSQFlite db = RepairSQFlite._();
  Database? _db;

  Future get database async{
    _db ??= await init();
    return _db;
  }

  Future<Database> init() async{
    String path = join(utils.docsDir!.path, 'repair.db');
    Database db = await openDatabase(path, version: 1, onOpen: (db){},
    onCreate: (Database inDB, int inVersion) async {
      await inDB.execute("CREATE TABLE IF NOT EXISTS repair ("
          "id INTEGER PRIMARY KEY, "
          "internalID INTEGER, "
          "category TEXT, "
          "dislocationOld TEXT, "
          "status TEXT, "
          "complaint TEXT, "
          "dateDeparture TEXT, "
          "serviceDislocation TEXT, "
          "dateTransferForService TEXT, "
          "dateDepartureFromService TEXT, "
          "worksPerformed TEXT, "
          "costService INTEGER, "
          "diagnosisService TEXT, "
          "recommendationsNotes TEXT, "
          "dateStartTestDrive TEXT, "
          "dateFinishTestDrive TEXT, "
          "resultTestDrive TEXT, "
          "newStatus TEXT, "
          "newDislocation TEXT, "
          "dateReceipt TEXT)");
    });
    return db;
  }

  Repair repairFromMap(Map inMap){
    Repair repair = Repair(
      inMap['id'],
      inMap['internalID'],
      inMap['category'],
      inMap['dislocationOld'],
      inMap['status'],
      inMap['complaint'],
      inMap['dateDeparture'],
      inMap['serviceDislocation'],
      inMap['dateTransferForService'],
      inMap['dateDepartureFromService'],
      inMap['worksPerformed'],
      inMap['costService'],
      inMap['diagnosisService'],
      inMap['recommendationsNotes'],
      inMap['dateStartTestDrive'],
      inMap['dateFinishTestDrive'],
      inMap['resultTestDrive'],
      inMap['newStatus'],
      inMap['newDislocation'],
      inMap['dateReceipt']);
    return repair;
  }

  Map<String, dynamic> repairToMap(Repair inRepair){
    Map<String, dynamic> map = Map<String, dynamic>();
    map['id'] = inRepair.id;
    map['internalID'] = inRepair.internalID;
    map['category'] = inRepair.category;
    map['dislocationOld'] = inRepair.dislocationOld;
    map['status'] = inRepair.status;
    map['complaint'] = inRepair.complaint;
    map['dateDeparture'] = inRepair.dateDeparture;
    map['serviceDislocation'] = inRepair.serviceDislocation;
    map['dateTransferForService'] = inRepair.dateTransferForService;
    map['dateDepartureFromService'] = inRepair.dateDepartureFromService;
    map['worksPerformed'] = inRepair.worksPerformed;
    map['costService'] = inRepair.costService;
    map['diagnosisService'] = inRepair.diagnosisService;
    map['recommendationsNotes'] = inRepair.recommendationsNotes;
    map['dateStartTestDrive'] = inRepair.dateStartTestDrive;
    map['dateFinishTestDrive'] = inRepair.dateFinishTestDrive;
    map['resultTestDrive'] = inRepair.resultTestDrive;
    map['newStatus'] = inRepair.newStatus;
    map['newDislocation'] = inRepair.newDislocation;
    map['dateReceipt'] = inRepair.dateReceipt;
    return map;
  }

  Future create(Repair inRepair) async {
    Database db = await database;

    var val = await db.rawQuery("SELECT MAX(id) + 1 AS id FROM repair");
    int id = val.first["id"] == null ? 1 : val.first["id"] as int;

    return await db.rawInsert(
        "INSERT INTO repair ("
            "id, "
            "internalID, "
            "category, "
            "dislocationOld, "
            "status, "
            "complaint, "
            "dateDeparture, "
            "serviceDislocation, "
            "dateTransferForService, "
            "dateDepartureFromService, "
            "worksPerformed, "
            "costService, "
            "diagnosisService, "
            "recommendationsNotes, "
            "dateStartTestDrive, "
            "dateFinishTestDrive, "
            "resultTestDrive, "
            "newStatus, "
            "newDislocation, "
            "dateReceipt) "
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
        [id, inRepair.id,
          inRepair.internalID,
          inRepair.category,
          inRepair.dislocationOld,
          inRepair.status,
          inRepair.complaint,
          inRepair.dateDeparture,
          inRepair.serviceDislocation,
          inRepair.dateTransferForService,
          inRepair.dateDepartureFromService,
          inRepair.worksPerformed,
          inRepair.costService,
          inRepair.diagnosisService,
          inRepair.recommendationsNotes,
          inRepair.dateStartTestDrive,
          inRepair.dateFinishTestDrive,
          inRepair.resultTestDrive,
          inRepair.newStatus,
          inRepair.newDislocation,
          inRepair.dateReceipt]);
  }

  Future<Repair> get(int inID) async {
    Database db = await database;
    var rec = await db.query("repair", where: "id = ?", whereArgs: [inID]);
    return repairFromMap(rec.first);
  }

  Future<List> getAll() async {
    Database db = await database;
    var recs = await db.query("repair");
    var list = recs.isNotEmpty ? recs.map((m) => repairFromMap(m)).toList() : [];
    return list;
  }

  Future update(Repair inRepair) async {
    Database db = await database;
    return await db.update("repair", repairToMap(inRepair),
        where: "id = ?", whereArgs: [inRepair.id]);
  }

  Future delete(int inID) async {
    Database db = await database;
    return await db.delete("repair", where: "id = ?", whereArgs: [inID]);
  }
}