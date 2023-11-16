import 'package:technical_support_artphoto/connectToDBMySQL.dart';
import 'package:technical_support_artphoto/technics/TechnicSQFlite.dart';
import 'package:technical_support_artphoto/utils/CategoryDropDownValueSQFlite.dart';
import 'package:technical_support_artphoto/utils/hasNetwork.dart';
import '../repair/RepairSQFlite.dart';

class DownloadAllList{
  DownloadAllList._();

  static final DownloadAllList downloadAllList = DownloadAllList._();

  Future<List> getAllList() async{
    List listAll = [];
    List listLastId = [];
    List listCount = [];

    bool isConnectInternet = await HasNetwork().isConnectInterten();
    if(isConnectInternet) {
      await ConnectToDBMySQL.connDB.connDatabase();
      listLastId = await ConnectToDBMySQL.connDB.getLastIdList();
      listCount = await ConnectToDBMySQL.connDB.getCountList();
    }

    List listAllTechnics = await getAllActualTechnics(isConnectInternet, listLastId[0]['id'], listCount[0]['countEquipment']);
    List listAllRepair = await getAllActualRepair(isConnectInternet, listLastId[1]['id'], listCount[1]['countRepair']);

    listAll.add(listAllTechnics);
    listAll.add(listAllRepair);

    print('list1 SQFlite: ${listAllRepair}');

    List list2 = await NameEquipmentSQFlite.db.getNameEquipment();
    print('list2 SQFlite: ${list2}');
    if(list2.isEmpty){
      list2 = await ConnectToDBMySQL.connDB.getNameEquipment();
      print('list2 mySQL: ${list2}');
    }

    // list.add(await getStatusForEquipment());
    // list.add(await getNameEquipment());
    // list.add(await getPhotosalons());


    return listAll;
  }

  Future<List> getAllActualTechnics(bool isConnectInternet, int lastId, int countEntities) async{
    List allTechnics = [];
    List addTechnicInSQFlite = [];

    allTechnics = await TechnicSQFlite.db.getAllTechnics();

    if(!isConnectInternet) return allTechnics;

    if(allTechnics.isNotEmpty){

      int lastIdSQFlite = allTechnics.first.id;
      int lastIdMySQL = lastId;
      if(lastIdSQFlite < lastIdMySQL){
        var reversedAllTechnic = List.from(allTechnics.reversed);
        addTechnicInSQFlite = await ConnectToDBMySQL.connDB.getRangeGreaterOnIDTechnics(lastIdSQFlite);

        for(var technic in addTechnicInSQFlite.reversed){
          TechnicSQFlite.db.create(technic);
        }
        reversedAllTechnic.addAll(addTechnicInSQFlite.reversed);

        allTechnics.clear();
        allTechnics.addAll(reversedAllTechnic.reversed);
      }
    } else {
      allTechnics = await ConnectToDBMySQL.connDB.getAllTechnics();
      for(var technic in allTechnics.reversed){
        TechnicSQFlite.db.create(technic);
      }
    }

    if(countEntities != allTechnics.length){
      TechnicSQFlite.db.deleteTable();
      TechnicSQFlite.db.createTable();

      allTechnics = await ConnectToDBMySQL.connDB.getAllTechnics();
      for(var technic in allTechnics.reversed){
        TechnicSQFlite.db.create(technic);
      }
    }

    return allTechnics;
  }

  Future<List> getAllActualRepair(bool isConnectInternet, int lastId, int countEntities) async{
    List allRepair = [];
    List addRepairInSQFlite = [];

    allRepair = await RepairSQFlite.db.getAllRepair();

    if(!isConnectInternet) return allRepair;

    if(allRepair.isNotEmpty){

      int lastIdSQFlite = allRepair.first.id;
      int lastIdMySQL = lastId;
      if(lastIdSQFlite < lastIdMySQL){
        var reversedAllRepair = List.from(allRepair.reversed);
        addRepairInSQFlite = await ConnectToDBMySQL.connDB.getRangeGreaterOnIDRepairs(lastIdSQFlite);

        for(var repair in addRepairInSQFlite){
          RepairSQFlite.db.create(repair);
        }
        reversedAllRepair.addAll(addRepairInSQFlite);

        allRepair.clear();
        allRepair.addAll(reversedAllRepair.reversed);
      }
    } else {
      allRepair = await ConnectToDBMySQL.connDB.getAllRepair();
      for(var repair in allRepair.reversed){
        RepairSQFlite.db.create(repair);
      }
    }

    if(countEntities != allRepair.length){
      RepairSQFlite.db.deleteTable();
      RepairSQFlite.db.createTable();

      allRepair = await ConnectToDBMySQL.connDB.getAllRepair();
      for(var repair in allRepair.reversed){
        RepairSQFlite.db.create(repair);
      }
    }

    return allRepair;
  }
}