import 'package:technical_support_artphoto/core/api/data/models/technic.dart';
import 'package:technical_support_artphoto/core/api/data/models/user.dart';
import 'package:technical_support_artphoto/features/repairs/models/summ_repair.dart';

import '../../../../features/repairs/models/repair.dart';
import '../../data/models/decommissioned.dart';

abstract interface class TechnicalSupportRepo {
  Future<Map<String, dynamic>> getStartData();
  Future<Map<String, dynamic>> refreshTechnicsData();
  Future<List<Repair>> refreshRepairsData();
  Future<User?> getUser(String password);
  Future<bool> checkNumberTechnic(String number);
  Future<Technic?> getTechnic(String number);
  Future<int?> saveTechnic(Technic technic, String nameUser);
  Future<bool> updateTechnic(Technic technic);
  Future<int?> saveRepair(Repair repair);
  Future<bool> updateRepair(Repair repair, bool isStepOne);
  Future<bool> deleteRepair(String id);
  Future<bool> updateStatusAndDislocationTechnic(Technic technic, String userName);
  Future<Map<int, List<SummRepair>>> getSumRepairs(String numberTechnic);
  Future<DecommissionedLocation> getTechnicsDecommissioned();
}