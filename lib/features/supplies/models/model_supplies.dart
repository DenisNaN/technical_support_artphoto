import 'package:technical_support_artphoto/features/supplies/models/supplies_entity.dart';

class ModelSupplies{
  int? id;
  final String location;
  final List<SuppliesEntity> suppliesEntity;

  ModelSupplies(this.location, this.suppliesEntity);
}
