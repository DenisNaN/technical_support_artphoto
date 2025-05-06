import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/core/api/data/repositories/technical_support_repo_impl.dart';
import 'package:technical_support_artphoto/core/api/provider/provider_model.dart';
import 'package:technical_support_artphoto/features/home/presentation/widgets/grid_view_home_page.dart';
import 'package:technical_support_artphoto/features/home/presentation/widgets/my_custom_refresh_indicator.dart';
import 'package:technical_support_artphoto/features/technics/presentation/page/technic_add.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = IndicatorController();

  @override
  Widget build(BuildContext context) {
    final providerModel = Provider.of<ProviderModel>(context);
    String userName = providerModel.user.keys.first;
    return Scaffold(
      appBar: AppBar(
        title: Text(userName),
        // actions: [
        //   MenuHomePage(),
        // ],
      ),
      body: SafeArea(child:
        WarpIndicator(
          controller: _controller,
            onRefresh: () => TechnicalSupportRepoImpl.downloadData.refreshData().then((resultData) {
                  providerModel.refreshAllElement(
                      resultData['Photosalons'], resultData['Repairs'], resultData['Storages']);
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
        )),
        ),
      floatingActionButton: FloatingActionButton.extended(
          icon: Icon(Icons.add),
          label: Text('Добавить технику'),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const TechnicAdd()));
          }),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
