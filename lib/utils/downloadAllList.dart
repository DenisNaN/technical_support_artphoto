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
    List listAddRepairOnSQFlite = [];
    bool isInternet = await HasNetwork().isConnectInterten();

    // RepairSQFlite.db.deleteTable();
    // RepairSQFlite.db.createTable();

    if(isInternet){
      await ConnectToDBMySQL.connDB.connDatabase();
      listAll.add('trueInternet');
      listAllRepair = await RepairSQFlite.db.getAllRepair();

      if(listAllRepair.isNotEmpty){

        List listLastId = await ConnectToDBMySQL.connDB.getLastIdList();

        int idSQFlite = listAllRepair.first.id;
        int idMySQL = listLastId[1]['id'];
        if(idSQFlite < idMySQL){
          listAddRepairOnSQFlite = await ConnectToDBMySQL.connDB.getRangeGreaterOnIDRepairs(idSQFlite);
          for(var repair in listAddRepairOnSQFlite){
            RepairSQFlite.db.create(repair);
          }
          listAllRepair.addAll(listAddRepairOnSQFlite);
        }
      } else {
        listAllRepair = await ConnectToDBMySQL.connDB.getAllRepair();
        for(var repair in listAllRepair.reversed){
          RepairSQFlite.db.create(repair);
        }
        listAll.addAll(listAllRepair);
      }
    } else {
      listAll.add('falseInternet');
      listAllRepair = await RepairSQFlite.db.getAllRepair();
      listAll.addAll(listAllRepair);
    }


    print('list1 SQFlite: ${listAllRepair}');



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
}