import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/core/api/data/repositories/technical_support_repo_impl.dart';
import 'package:technical_support_artphoto/core/api/provider/provider_model.dart';
import 'package:technical_support_artphoto/core/shared/loader_overlay/loading_overlay.dart';
import 'package:technical_support_artphoto/features/home/presentation/widgets/grid_view_basket_decommissioned.dart';
import 'package:technical_support_artphoto/features/home/presentation/widgets/grid_view_home_page.dart';
import 'package:technical_support_artphoto/features/home/presentation/widgets/my_custom_refresh_indicator.dart';
import 'package:technical_support_artphoto/features/technics/presentation/page/technic_add.dart';
import '../widgets/appbar_homepage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = IndicatorController();
  bool isVisibleExit = false;

  @override
  Widget build(BuildContext context) {
    final providerModel = Provider.of<ProviderModel>(context);
    return Scaffold(
      appBar: AppBarHomepage(),
      body: SafeArea(
        child: WarpIndicator(
            controller: _controller,
            onRefresh: () => TechnicalSupportRepoImpl.downloadData.refreshTechnicsData().then((resultData) {
                  providerModel.refreshTechnics(
                      resultData['Photosalons'], resultData['Repairs'], resultData['Storages']);
                }),
            child: CustomScrollView(
              physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                GridViewHomePage(locations: providerModel.technicsInPhotosalons, color: providerModel.colorPhotosalons),
                GridViewHomePage(locations: providerModel.technicsInStorages, color: providerModel.colorStorages),
                GridViewHomePage(locations: providerModel.technicsInRepairs, color: providerModel.colorRepairs),
                GridViewBasketDecommissioned(),
              ],
            )),
      ),
      floatingActionButton: FloatingActionButton.extended(
          icon: Icon(Icons.add),
          label: Text('Добавить технику'),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const LoadingOverlay(child: TechnicAdd())));
          }),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
