import 'package:technical_support_artphoto/core/domain/models/photosalon.dart';
import 'package:technical_support_artphoto/core/domain/models/repair.dart';
import 'package:technical_support_artphoto/core/domain/models/storage.dart';
import 'package:technical_support_artphoto/core/domain/models/user.dart';

abstract interface class TechnicalSupportRepository {
  Future<Map<String, Photosalon>> fetchPhotosalons();
  Future<Map<String, Repair>> fetchRepairs();
  Future<Map<String, Storage>> fetchStorages();
  Future<User> fetchAccessLevel(String password);
}