import 'package:technical_support_artphoto/core/api/data/models/technic.dart';
import 'package:technical_support_artphoto/core/api/data/models/user.dart';
import 'package:technical_support_artphoto/features/repairs/models/summs_repair.dart';

abstract interface class TechnicalSupportRepo {
  Future<Map<String, dynamic>> getStartData();
  Future<Map<String, dynamic>> refreshData();
  Future<User?> getUser(String password);
  Future<bool> checkNumberTechnic(String number);
  Future<bool> updateTechnic(Technic technic);
  Future<Map<int, List<SummRepair>>> getSummsRepairs(String numberTechnic);
}