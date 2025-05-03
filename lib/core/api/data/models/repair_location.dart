import 'package:technical_support_artphoto/core/api/data/models/location.dart';
import 'package:technical_support_artphoto/core/api/data/models/technic.dart';

class RepairLocation implements Location{
  String name;
  List<Technic> technics = [];

  RepairLocation(this.name);
}