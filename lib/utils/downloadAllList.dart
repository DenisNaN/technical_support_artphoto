import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:technical_support_artphoto/connectToDBMySQL.dart';
import 'package:technical_support_artphoto/technics/TechnicSQFlite.dart';
import 'package:technical_support_artphoto/utils/categoryDropDownValueSQFlite.dart';
import 'package:technical_support_artphoto/utils/hasNetwork.dart';
import 'package:technical_support_artphoto/utils/utils.dart';
import '../repair/RepairSQFlite.dart';

class DownloadAllList{
  DownloadAllList._();

  static final DownloadAllList downloadAllList = DownloadAllList._();

  Future<List> getAllList() async{
    List listAllTechnics;
    List listAllRepair;
    List listAllNameEquipment;
    List listAllPhotosalons;
    List listAllService;
    List listAllStatusForEquipment;

    List listAll = [];
    List listLastId = [];
    List listCount = [];

    // rebootAllListCategorySQFlite('nameEquipment', 'name');
    // rebootAllListCategorySQFlite('photosalons', 'Фотосалон');
    // rebootAllListCategorySQFlite('service', 'repairmen');
    // rebootAllListCategorySQFlite('statusForEquipment', 'status');

    await HasNetwork().checkConnectingToInterten();

    if(HasNetwork.isConnecting) {
      await ConnectToDBMySQL.connDB.connDatabase();
      listLastId = await ConnectToDBMySQL.connDB.getLastIdList();
      listCount = await ConnectToDBMySQL.connDB.getCountList();
      LoginPassword.loginPassword.addAll(await ConnectToDBMySQL.connDB.getLoginPassword());

      listAllTechnics = await getAllActualTechnics(HasNetwork.isConnecting, listLastId[0]['id'], listCount[0]['countEquipment']);
      listAllRepair = await getAllActualRepair(HasNetwork.isConnecting, listLastId[1]['id'], listCount[1]['countRepair']);
      listAllNameEquipment = await getActualCategory(
          HasNetwork.isConnecting, 'nameEquipment', 'name', listCount[2]['countName']);
      listAllPhotosalons = await getActualCategory(
          HasNetwork.isConnecting, 'photosalons', 'Фотосалон', listCount[3]['countPhotosalons']);
      listAllService = await getActualCategory(
          HasNetwork.isConnecting, 'service', 'repairmen', listCount[4]['countService']);
      listAllStatusForEquipment = await getActualCategory(
          HasNetwork.isConnecting, 'statusForEquipment', 'status', listCount[5]['countStatus']);
    } else{
      listAllTechnics = await getAllActualTechnics(HasNetwork.isConnecting);
      listAllRepair = await getAllActualRepair(HasNetwork.isConnecting);
      listAllNameEquipment = await getActualCategory(
          HasNetwork.isConnecting, 'nameEquipment', 'name');
      listAllPhotosalons = await getActualCategory(
          HasNetwork.isConnecting, 'photosalons', 'Фотосалон');
      listAllService = await getActualCategory(
          HasNetwork.isConnecting, 'service', 'repairmen');
      listAllStatusForEquipment = await getActualCategory(
          HasNetwork.isConnecting, 'statusForEquipment', 'status');
    }

    listAll.add(listAllTechnics);
    listAll.add(listAllRepair);
    listAll.add(listAllNameEquipment);
    listAll.add(listAllPhotosalons);
    listAll.add(listAllService);
    listAll.add(listAllStatusForEquipment);

    return listAll;
  }

  Future<List> getAllActualTechnics(bool isConnectInternet, [int lastId = 0, int countEntities = 0]) async{
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

  Future<List> getAllActualRepair(bool isConnectInternet, [int lastId = 0, int countEntities = 0]) async{
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

  Future<List> getActualCategory(
      bool isConnectInternet,
      String nameTable,
      String nameCategory,
      [int countEntities = 0]
      ) async{
    List actualCategory = [];

    actualCategory = await CategorySQFlite.db.getCategory(nameTable);

    if(!isConnectInternet) return actualCategory;

    if(countEntities != actualCategory.length){
      CategorySQFlite.db.deleteTable(nameTable);
      CategorySQFlite.db.createTable(nameTable, nameCategory);

      switch(nameTable){
        case 'nameEquipment':
          actualCategory = await ConnectToDBMySQL.connDB.getNameEquipment();
          break;
        case 'photosalons':
          actualCategory = await ConnectToDBMySQL.connDB.getPhotosalons();
          break;
        case 'service':
          actualCategory = await ConnectToDBMySQL.connDB.getService();
          break;
        case 'statusForEquipment':
          actualCategory = await ConnectToDBMySQL.connDB.getStatusForEquipment();
          break;
      }

      int id = 0;
      for(var category in actualCategory.reversed){
        DropDownValueModel dropDownValueName = category;
        ++id;
        CategorySQFlite.db.create(nameTable, nameCategory, id, dropDownValueName.name);
      }
    }

    return actualCategory;
  }

  Future rebootAllBasicListSQFlite() async{
    TechnicSQFlite.db.deleteTable();
    TechnicSQFlite.db.createTable();
    RepairSQFlite.db.deleteTable();
    RepairSQFlite.db.createTable();
  }

  Future rebootAllListCategorySQFlite(String nameTable, String nameCategory) async{
    CategorySQFlite.db.deleteTable(nameTable);
    CategorySQFlite.db.createTable(nameTable, nameCategory);
  }

}