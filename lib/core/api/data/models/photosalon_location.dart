import 'package:technical_support_artphoto/core/api/data/models/location.dart';
import 'package:technical_support_artphoto/core/api/data/models/technic.dart';

class PhotosalonLocation implements Location{
  String name;
  List<Technic> technics = [];

  PhotosalonLocation(this.name);
}