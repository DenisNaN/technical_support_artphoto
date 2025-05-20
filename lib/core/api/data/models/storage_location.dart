import 'package:technical_support_artphoto/core/api/data/models/location.dart';
import 'package:technical_support_artphoto/core/api/data/models/technic.dart';

class StorageLocation implements Location{
  String name;
  List<Technic> technics = [];

  StorageLocation(this.name);
}