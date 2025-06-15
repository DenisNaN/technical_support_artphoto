import 'package:technical_support_artphoto/core/api/data/models/free_number_for_technic.dart';
import 'package:technical_support_artphoto/core/api/data/models/trouble_account_mail_ru.dart';
import 'package:technical_support_artphoto/features/technics/models/technic.dart';
import 'package:technical_support_artphoto/core/api/data/models/user.dart';
import 'package:technical_support_artphoto/features/repairs/models/summ_repair.dart';
import 'package:technical_support_artphoto/features/troubles/models/trouble.dart';

import '../../../../features/repairs/models/repair.dart';
import '../../data/models/decommissioned.dart';

abstract interface class TechnicalSupportRepo {
  Future<Map<String, dynamic>> getStartData();

  Future<Map<String, dynamic>> refreshTechnicsData();
  Future<List<Repair>> refreshCurrentRepairsData();

  Future<User?> getUser(String password);
  Future<TroubleAccountMailRu?> getAccountMailRu();

  Future<FreeNumbersForTechnic> checkNumberTechnic(String number);
  Future<Technic?> getTechnic(String number);
  Future<int?> saveTechnic(Technic technic, String nameUser);
  Future<bool> updateTechnic(Technic technic);
  Future<bool> updateStatusAndDislocationTechnic(Technic technic, String userName);
  Future<Map<int, List<SummRepair>>> getSumRepairs(String numberTechnic);
  Future<DecommissionedLocation> getTechnicsDecommissioned();

  Future<List<Repair>> getFinishedRepairs();
  Future<Repair?> getRepair(int id);
  Future<List<Repair>?> saveRepair(Repair repair);
  Future<List<Repair>?> updateRepair(Repair repair, bool isStepOne);
  Future<bool> deleteRepair(String id);

  Future<List<Trouble>> getTroubles();
  Future<Trouble?> getTrouble(String id);
  Future<List<Trouble>?> saveTrouble(Trouble trouble);
  Future<List<Trouble>> getFinishedTroubles();
  Future<bool> deleteTrouble(String id);
  Future<List<Trouble>?> updateTrouble(Trouble trouble);
}