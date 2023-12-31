import 'package:technical_support_artphoto/connectToDBMySQL.dart';
import 'package:technical_support_artphoto/repair/Repair.dart';
import 'package:technical_support_artphoto/technics/TechnicSQFlite.dart';
import 'package:technical_support_artphoto/trouble/Trouble.dart';
import 'package:technical_support_artphoto/trouble/TroubleSQFlite.dart';
import 'package:technical_support_artphoto/utils/categoryDropDownValueSQFlite.dart';
import 'package:technical_support_artphoto/utils/hasNetwork.dart';
import 'package:technical_support_artphoto/utils/utils.dart';
import '../repair/RepairSQFlite.dart';
import '../technics/Technic.dart';
import 'categoryDropDownValueModel.dart';

class DownloadAllList{
  DownloadAllList._();

  static final DownloadAllList downloadAllList = DownloadAllList._();

  Future<bool>  getAllList() async{
    bool result = true;
    List listLastId = [];
    List listCount = [];

    rebootAllBasicListSQFlite();
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

      getAllHasNetwork(listLastId, listCount);
    } else{
      getAllHasnotNetwork();
    }
    return result;
  }

  Future getAllHasNetwork (List listLastId, List listCount) async{
    Technic.technicList.addAll(
        await getAllActualTechnics(HasNetwork.isConnecting, listLastId[0]['id'], listCount[0]['countEquipment']));
    Repair.repairList.addAll(
        await getAllActualRepair(HasNetwork.isConnecting, listLastId[1]['id'], listCount[1]['countRepair']));
    Trouble.troubleList.addAll(
        await getAllActualTrouble(HasNetwork.isConnecting, listLastId[2]['id'], listCount[2]['countTrouble']));
    CategoryDropDownValueModel.nameEquipment.addAll((await getActualCategory(
        HasNetwork.isConnecting, 'nameEquipment', 'name', listCount[3]['countName'])) as Iterable<String>);
    CategoryDropDownValueModel.photosalons.addAll((await getActualCategory(
        HasNetwork.isConnecting, 'photosalons', 'Фотосалон', listCount[4]['countPhotosalons'])) as Iterable<String>);
    CategoryDropDownValueModel.service.addAll((await getActualCategory(
        HasNetwork.isConnecting, 'service', 'repairmen', listCount[5]['countService'])) as Iterable<String>);
    CategoryDropDownValueModel.statusForEquipment.addAll((await getActualCategory(
        HasNetwork.isConnecting, 'statusForEquipment', 'status', listCount[6]['countStatus'])) as Iterable<String>);
  }

  Future getAllHasnotNetwork() async{
    Technic.technicList.addAll(await getAllActualTechnics(HasNetwork.isConnecting));
    Repair.repairList.addAll(await getAllActualRepair(HasNetwork.isConnecting));
    Trouble.troubleList.addAll(await getAllActualTrouble(HasNetwork.isConnecting));
    CategoryDropDownValueModel.nameEquipment.addAll((await getActualCategory(
        HasNetwork.isConnecting, 'nameEquipment', 'name')) as Iterable<String>);
    CategoryDropDownValueModel.photosalons.addAll((await getActualCategory(
        HasNetwork.isConnecting, 'photosalons', 'Фотосалон')) as Iterable<String>);
    CategoryDropDownValueModel.service.addAll((await getActualCategory(
        HasNetwork.isConnecting, 'service', 'repairmen')) as Iterable<String>);
    CategoryDropDownValueModel.statusForEquipment.addAll((await getActualCategory(
        HasNetwork.isConnecting, 'statusForEquipment', 'status')) as Iterable<String>);
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
          TechnicSQFlite.db.insertEquipment(technic);
        }
        reversedAllTechnic.addAll(addTechnicInSQFlite.reversed);

        allTechnics.clear();
        allTechnics.addAll(reversedAllTechnic.reversed);
      }
    } else {
      allTechnics = await ConnectToDBMySQL.connDB.getAllTechnics();
      for(var technic in allTechnics.reversed){
        TechnicSQFlite.db.insertEquipment(technic);
      }
    }

    if(countEntities != allTechnics.length){
      TechnicSQFlite.db.deleteTables();
      TechnicSQFlite.db.createTables();

      allTechnics = await ConnectToDBMySQL.connDB.getAllTechnics();
      for(var technic in allTechnics.reversed){
        TechnicSQFlite.db.insertEquipment(technic);
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

  Future<List> getAllActualTrouble(bool isConnectInternet, [int lastId = 0, int countEntities = 0]) async{
    List allTrouble = [];
    List addTroubleInSQFlite = [];

    allTrouble = await TroubleSQFlite.db.getAllTrouble();

    if(!isConnectInternet) return allTrouble;

    if(allTrouble.isNotEmpty){

      int lastIdSQFlite = allTrouble.first.id;
      int lastIdMySQL = lastId;
      if(lastIdSQFlite < lastIdMySQL){
        var reversedAllTrouble = List.from(allTrouble.reversed);
        addTroubleInSQFlite = await ConnectToDBMySQL.connDB.getRangeGreaterOnIDTrouble(lastIdSQFlite);

        for(var trouble in addTroubleInSQFlite){
          TroubleSQFlite.db.insertTrouble(trouble);
        }
        reversedAllTrouble.addAll(addTroubleInSQFlite);

        allTrouble.clear();
        allTrouble.addAll(reversedAllTrouble.reversed);
      }
    } else {
      allTrouble = await ConnectToDBMySQL.connDB.getAllTrouble();
      for(var trouble in allTrouble.reversed){
        TroubleSQFlite.db.insertTrouble(trouble);
      }
    }

    if(countEntities != allTrouble.length){
      TroubleSQFlite.db.deleteTables();
      TroubleSQFlite.db.createTables();

      allTrouble = await ConnectToDBMySQL.connDB.getAllTrouble();
      for(var trouble in allTrouble.reversed){
        TroubleSQFlite.db.insertTrouble(trouble);
      }
    }
    return allTrouble;
  }

  Future<List> getActualCategory(
      bool isConnectInternet,
      String nameTable,
      String nameCategory,
      [int countEntities = 0]) async{
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
        // DropDownValueModel dropDownValueName = category;
        ++id;
        CategorySQFlite.db.create(nameTable, nameCategory, id, category);
      }
    }
    return actualCategory;
  }

  Future rebootAllBasicListSQFlite() async{
    TechnicSQFlite.db.deleteTables();
    TechnicSQFlite.db.createTables();
    RepairSQFlite.db.deleteTable();
    RepairSQFlite.db.createTable();
    TroubleSQFlite.db.deleteTables();
    TroubleSQFlite.db.createTables();
  }

  Future rebootAllListCategorySQFlite(String nameTable, String nameCategory) async{
    CategorySQFlite.db.deleteTable(nameTable);
    CategorySQFlite.db.createTable(nameTable, nameCategory);
  }

}