import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/features/grid_view/grid_view_home_page.dart';
import '../../core/domain/models/providerModel.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final providerModel = Provider.of<ProviderModel>(context);
    return CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: [
        gridViewHomePage(providerModel.photosolons, providerModel.colorPhotosalons),
        gridViewHomePage(providerModel.storages, providerModel.colorStorages),
        gridViewHomePage(providerModel.repairs, providerModel.colorRepairs),
      ],
    );
  }
}
