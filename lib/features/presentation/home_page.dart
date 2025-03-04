import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/features/grid_view/grid_view_home_page.dart';
import 'package:technical_support_artphoto/features/popup_menu/menu_home_page.dart';
import '../../core/data/download_data.dart';
import '../../core/domain/models/providerModel.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final providerModel = Provider.of<ProviderModel>(context);
    String userName = providerModel.user.keys.first;

    return Scaffold(
      appBar: AppBar(
        title: Text(userName),
        actions: [
          MenuHomePage(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async{
          List<String, dynamic> list = await DownloadData.downloadData.refreshData();
          providerModel.downloadAllElements(photosalons, repairs, storages);
        },
        child: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            GridViewHomePage(locations: providerModel.photosolons, color: providerModel.colorPhotosalons),
            GridViewHomePage(locations: providerModel.storages, color: providerModel.colorStorages),
            GridViewHomePage(locations: providerModel.repairs, color: providerModel.colorRepairs),
            GridViewHomePage(locations: providerModel.repairs, color: providerModel.colorRepairs),
            GridViewHomePage(locations: providerModel.repairs, color: providerModel.colorRepairs),
          ],
        ),
      ),
    );
  }
}
