import 'package:technical_support_artphoto/connectToDBMySQL.dart';
import 'package:technical_support_artphoto/utils/CategoryDropDownValueSQFlite.dart';
import 'package:technical_support_artphoto/utils/hasNetwork.dart';
import '../repair/RepairSQFlite.dart';

class DownloadAllList{
  DownloadAllList._();

  static final DownloadAllList downloadAllList = DownloadAllList._();

  Future<List> getAllList() async{
    List listAll = [];
    List listAllRepair = [];
    bool isInternet = await HasNetwork().isConnectInterten();

    if(isInternet){
      await ConnectToDBMySQL.connDB.connDatabase();
      listAllRepair = await getAllActualRepair();
    } else {
      List listAllRepair = await RepairSQFlite.db.getAllRepair();
    }

    listAll.addAll(listAllRepair);

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

  Future<List> getAllActualRepair() async{
    List allRepair = [];
    List addRepairInSQFlite = [];

    // RepairSQFlite.db.deleteTable();
    // RepairSQFlite.db.createTable();

    allRepair = await RepairSQFlite.db.getAllRepair();

    if(allRepair.isNotEmpty){

      List listLastId = await ConnectToDBMySQL.connDB.getLastIdList();

      int idSQFlite = allRepair.last.id;
      int idMySQL = listLastId[1]['id'];
      if(idSQFlite < idMySQL){
        addRepairInSQFlite = await ConnectToDBMySQL.connDB.getRangeGreaterOnIDRepairs(idSQFlite);
        for(var repair in addRepairInSQFlite.reversed){
          RepairSQFlite.db.create(repair);
        }
        allRepair.addAll(addRepairInSQFlite);
      }
    } else {
      allRepair = await ConnectToDBMySQL.connDB.getAllRepair();
      for(var repair in allRepair.reversed){
        RepairSQFlite.db.create(repair);
      }

      List allRep = await RepairSQFlite.db.getAllRepair();
      print(allRep);
    }

    return allRepair;
  }
}