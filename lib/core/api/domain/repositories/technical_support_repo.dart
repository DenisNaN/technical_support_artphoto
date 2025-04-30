import 'package:technical_support_artphoto/core/api/data/models/user.dart';

abstract interface class TechnicalSupportRepo {
  Future<Map<String, dynamic>> getStartData();
  Future<Map<String, dynamic>> refreshData();
  Future<User?> getUser(String password);
  Future<bool> checkNumberTechnic(String number);

}