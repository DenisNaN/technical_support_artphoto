import 'package:technical_support_artphoto/ConnectToDBMySQL.dart';
import 'package:technical_support_artphoto/utils/CategoryDropDownValueSQFlite.dart';
import '../repair/RepairSQFlite.dart';

class DownloadAllList{
  DownloadAllList._();

  static final DownloadAllList downloadAllList = DownloadAllList._();

  Future<List> getAllList() async{
    List list = [];

    RepairSQFlite.db.deleteTable();
    RepairSQFlite.db.createTable();

    List listAllRepair = await RepairSQFlite.db.getAllRepair();
    print('list1 SQFlite: ${listAllRepair}');

    if(listAllRepair.isEmpty){
      await ConnectToDBMySQL.connDB.connDatabase();
      
      int count = await ConnectToDBMySQL.connDB.getCountRecordsRepair();
      print('count: ${count}');

      listAllRepair = await ConnectToDBMySQL.connDB.getAllRepair();
      for(var repair in listAllRepair){
        RepairSQFlite.db.create(repair);
      }
    }
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



    return list;
  }
}