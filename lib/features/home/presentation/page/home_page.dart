import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/core/api/data/repositories/technical_support_repo_impl.dart';
import 'package:technical_support_artphoto/core/api/provider/providerModel.dart';
import 'package:technical_support_artphoto/features/home/presentation/widgets/grid_view_home_page.dart';
import 'package:technical_support_artphoto/features/home/presentation/widgets/menu_home_page.dart';
import 'package:technical_support_artphoto/features/technics/presentation/page/technic_add.dart';

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
          // MenuHomePage(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => TechnicalSupportRepoImpl.downloadData.refreshData().then((resultData) {
          providerModel.refreshAllElement(resultData['Photosalons'], resultData['Repairs'], resultData['Storages']);
        }),
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
      floatingActionButton: FloatingActionButton.extended(
          icon: Icon(Icons.add),
          label: Text('Добавить технику'),
          onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const TechnicAdd()));
      }),
    );
  }
}
