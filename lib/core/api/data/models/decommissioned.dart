import 'package:technical_support_artphoto/features/technics/models/technic.dart';

import 'location.dart';

class DecommissionedLocation implements Location{
  String name;
  final List<Technic> technics = [];

  DecommissionedLocation(this.name);
}