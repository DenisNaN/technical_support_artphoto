import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/core/api/data/repositories/technical_support_repo_impl.dart';
import 'package:technical_support_artphoto/core/api/provider/provider_model.dart';
import 'package:technical_support_artphoto/features/home/presentation/widgets/my_custom_refresh_indicator.dart';
import 'package:technical_support_artphoto/features/supplies/presentation/widgets/app_bar_supplies.dart';
import '../widgets/grid_view_supplies_paper.dart';

class Supplies extends StatefulWidget {
  const Supplies({super.key});

  @override
  State<Supplies> createState() => _SuppliesState();
}

class _SuppliesState extends State<Supplies> {
  final _controller = IndicatorController();

  @override
  Widget build(BuildContext context) {
    final providerModel = Provider.of<ProviderModel>(context);
    return Scaffold(
      appBar: AppBarSupplies(),
      body: SafeArea(
          child: WarpIndicator(
              controller: _controller,
              onRefresh: () => TechnicalSupportRepoImpl.downloadData.refreshSuppliesData().then((resultData) {
                providerModel.refreshSupplies(resultData);
              }),
              child: CustomScrollView(
                physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  GridViewSuppliesPaper(
                      suppliesGarage: providerModel.getSuppliesGarage,
                      suppliesOffice: providerModel.getSuppliesOffice,
                      color: Colors.lightGreen.shade400,
                      isPaint: false,
                  ),
                  SliverAppBar(
                    title: Text('Краска'),
                    backgroundColor: Colors.white70,
                    titleTextStyle: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                  GridViewSuppliesPaper(
                    suppliesGarage: providerModel.getSuppliesGarage,
                    suppliesOffice: providerModel.getSuppliesOffice,
                    color: Colors.lightGreen.shade400,
                    isPaint: true,
                  ),
                ],
              ))),
    );
  }
}
