import 'package:package_info_plus/package_info_plus.dart';
import 'package:technical_support_artphoto/connectToDBMySQL.dart';
import 'package:technical_support_artphoto/history/HistorySQFlite.dart';
import 'package:technical_support_artphoto/repair/Repair.dart';
import 'package:technical_support_artphoto/technics/TechnicSQFlite.dart';
import 'package:technical_support_artphoto/trouble/Trouble.dart';
import 'package:technical_support_artphoto/trouble/TroubleSQFlite.dart';
import 'package:technical_support_artphoto/utils/categoryDropDownValueSQFlite.dart';
import 'package:technical_support_artphoto/utils/hasNetwork.dart';
import 'package:technical_support_artphoto/utils/utils.dart';
import '../history/History.dart';
import '../repair/RepairSQFlite.dart';
import '../technics/Technic.dart';
import 'categoryDropDownValueModel.dart';
import 'package:intl/intl.dart';
import 'utils.dart' as utils;

class DownloadAllList{
  DownloadAllList._();

  static final DownloadAllList downloadAllList = DownloadAllList._();

  Future<bool>  getAllList() async{
    bool result = true;
    List listLastId = [];
    List listCount = [];

    utils.packageInfo = await PackageInfo.fromPlatform();

    // rebootAllBasicListSQFlite();
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
      getAllHasNotNetwork();
    }
    return result;
  }

  Future getAllHasNetwork (List listLastId, List listCount) async{
    Technic.technicList.addAll(
        await getAllActualTechnics(HasNetwork.isConnecting, listLastId[0]['id'], listCount[0]['countEquipment']));
    Technic.technicList.sort();
    Technic.testDriveList.addAll(await ConnectToDBMySQL.connDB.getAllTestDrive());
    Repair.repairList.addAll(
        await getAllActualRepair(HasNetwork.isConnecting, listLastId[1]['id'], listCount[1]['countRepair']));


    Trouble.troubleList.addAll(
        await getAllActualTrouble(HasNetwork.isConnecting, listLastId[2]['id'], listCount[2]['countTrouble']));
    History.historyList.addAll(
        await getAllActualHistory(HasNetwork.isConnecting, listLastId[3]['id'], listCount[3]['countTrouble']));
    CategoryDropDownValueModel.nameEquipment.addAll((await getActualCategory(
        HasNetwork.isConnecting, 'nameEquipment', 'name', listCount[4]['countName'])));
    CategoryDropDownValueModel.photosalons.addAll((await getActualCategory(
        HasNetwork.isConnecting, 'photosalons', 'Фотосалон', listCount[5]['countPhotosalons'])));
    CategoryDropDownValueModel.service.addAll((await getActualCategory(
        HasNetwork.isConnecting, 'service', 'repairmen', listCount[6]['countService'])));
    CategoryDropDownValueModel.statusForEquipment.addAll((await getActualCategory(
        HasNetwork.isConnecting, 'statusForEquipment', 'status', listCount[7]['countStatus'])));
    CategoryDropDownValueModel.colorForEquipment.addAll(await getActualColorsForPhotosalons(
        HasNetwork.isConnecting, listCount[8]['countColorsForPhotosalons']));
  }

  Future getAllHasNotNetwork() async{
    Technic.technicList.addAll(await getAllActualTechnics(HasNetwork.isConnecting));
    Technic.technicList.sort();
    Repair.repairList.addAll(await getAllActualRepair(HasNetwork.isConnecting));
    Trouble.troubleList.addAll(await getAllActualTrouble(HasNetwork.isConnecting));
    History.historyList.addAll(await getAllActualHistory(HasNetwork.isConnecting));
    CategoryDropDownValueModel.nameEquipment.addAll((await getActualCategory(
        HasNetwork.isConnecting, 'nameEquipment', 'name')));
    CategoryDropDownValueModel.photosalons.addAll((await getActualCategory(
        HasNetwork.isConnecting, 'photosalons', 'Фотосалон')));
    CategoryDropDownValueModel.service.addAll((await getActualCategory(
        HasNetwork.isConnecting, 'service', 'repairmen')));
    CategoryDropDownValueModel.statusForEquipment.addAll((await getActualCategory(
        HasNetwork.isConnecting, 'statusForEquipment', 'status')));
    CategoryDropDownValueModel.colorForEquipment.addAll(await getActualColorsForPhotosalons(
        HasNetwork.isConnecting));
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

    for(Repair elem in allRepair){
        TotalSumRepairs totalSumRepairs = TotalSumRepairs(elem.id!, elem.internalID!, elem.costService!);
        Repair.totalSumRepairs.add(totalSumRepairs);
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

  Future<List> getAllActualHistory(bool isConnectInternet, [int lastId = 0, int countEntities = 0]) async{
    List allHistory = [];
    List addHistoryInSQFlite = [];

    allHistory = await HistorySQFlite.db.getAllHistory();

    if(!isConnectInternet) return allHistory;

    if(allHistory.isNotEmpty){

      int lastIdSQFlite = allHistory.first.id;
      int lastIdMySQL = lastId;
      if(lastIdSQFlite < lastIdMySQL){
        var reversedAllHistory = List.from(allHistory.reversed);
        addHistoryInSQFlite = await ConnectToDBMySQL.connDB.getRangeGreaterOnIDHistory(lastIdSQFlite);

        for(var history in addHistoryInSQFlite){
          HistorySQFlite.db.insertHistory(history);
        }
        updateAllRowsIfWereChanges(addHistoryInSQFlite);
        reversedAllHistory.addAll(addHistoryInSQFlite);

        allHistory.clear();
        allHistory.addAll(reversedAllHistory.reversed);
      }
    } else {
      allHistory = await ConnectToDBMySQL.connDB.getAllHistory();
      for(var history in allHistory.reversed){
        HistorySQFlite.db.insertHistory(history);
      }
    }

    if(countEntities != allHistory.length){
      HistorySQFlite.db.deleteTables();
      HistorySQFlite.db.createTables();

      allHistory = await ConnectToDBMySQL.connDB.getAllHistory();
      for(var history in allHistory.reversed){
        HistorySQFlite.db.insertHistory(history);
      }
    }
    return allHistory;
  }

  Future updateAllRowsIfWereChanges(List historyList) async{
    if(historyList.isNotEmpty){
      historyList.forEach((history) async {
        if(history.typeOperation == 'edit'){
          switch(history.section){
            case 'Technic':
              Technic? technic = await ConnectToDBMySQL.connDB.getTechnic(history.idSection);
              if(technic != null) {
                TechnicSQFlite.db.updateTechnic(technic);
                int index = -1;
                Technic.technicList.forEach((element) {
                  if(element.id == technic.id) index = Technic.technicList.indexOf(element);
                });
                if(index != -1) Technic.technicList[index] = technic;
              }
              break;
            case 'Repair':
              Repair? repair = await ConnectToDBMySQL.connDB.getRepair(history.idSection);
              if(repair != null) {
                RepairSQFlite.db.update(repair);
                int index = -1;
                Repair.repairList.forEach((element) {
                  if(element.id == repair.id) index = Repair.repairList.indexOf(element);
                });
                if(index != -1) Repair.repairList[index] = repair;
              }
              break;
            case 'Trouble':
              Trouble? trouble = await ConnectToDBMySQL.connDB.getTrouble(history.idSection);
              if(trouble != null) {
                TroubleSQFlite.db.updateTrouble(trouble);
                int index = -1;
                Trouble.troubleList.forEach((element) {
                  if(element.id == trouble.id) index = Trouble.troubleList.indexOf(element);
                });
                if(index != -1) Trouble.troubleList[index] = trouble;
              }
              break;
          }
        }
      });
    }
  }

  Future<List<String>> getActualCategory(
      bool isConnectInternet,
      String nameTable,
      String nameCategory,
      [int countEntities = 0]) async{
    List<String> actualCategory = [];

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
        ++id;
        CategorySQFlite.db.create(nameTable, nameCategory, id, category);
      }
    }
    return actualCategory;
  }

  Future<Map<String, int>> getActualColorsForPhotosalons(bool isConnectInternet, [int countEntities = 0]) async{
    Map<String, int> actualCategory = {};
    actualCategory = await CategorySQFlite.db.getColorsForPhotosalons();

    if(!isConnectInternet) return actualCategory;

    if(countEntities != actualCategory.length){
      CategorySQFlite.db.deleteTableColorsForPhotosalons();
      CategorySQFlite.db.createTableColorsForPhotosalons();

      actualCategory = await ConnectToDBMySQL.connDB.getColorForEquipment();

      int id = 0;
      for(var category in actualCategory.entries.toList().reversed){
        ++id;
        CategorySQFlite.db.createColorsForPhotosalons(id, category.key, category.value.toString());
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
    CategorySQFlite.db.deleteTableColorsForPhotosalons();
    CategorySQFlite.db.createTableColorsForPhotosalons();
  }

  List getNotifications(){
    List notifications = [];

    Repair.repairList.forEach((repair) {
      DateTime? dateDepFromServ = getDate(repair.dateDepartureFromService);
      if(dateDepFromServ != null){
        if(dateDepFromServ > )
      }
    });

    return notifications;
  }

  DateTime? getDate(String date) {
    if(date != '') {
      return DateTime.parse(date.replaceAll('.', '-'));
    }
    return null;
  }
}