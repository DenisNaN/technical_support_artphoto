import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:technical_support_artphoto/core/api/provider/provider_model.dart';
import 'package:technical_support_artphoto/core/navigation/main_bottom_app_bar.dart';
import 'package:technical_support_artphoto/features/splash_screen/widgets/appbar_shimmer_home_page.dart';
import 'package:technical_support_artphoto/features/splash_screen/widgets/placeholders.dart';

class ShimmerPageHome extends StatefulWidget {
  const ShimmerPageHome({super.key});

  @override
  State<ShimmerPageHome> createState() => _ShimmerPageHomeState();
}

class _ShimmerPageHomeState extends State<ShimmerPageHome> {
  @override
  Widget build(BuildContext context) {
    final providerModel = Provider.of<ProviderModel>(context);
    return Scaffold(
      appBar: AppBarShimmerHomePage(),
      floatingActionButton: FloatingActionButton.extended(
          icon: Icon(Icons.add),
          label: Text('Добавить технику'),
          onPressed: null
      ),
      bottomNavigationBar: MainBottomAppBar(pageController: null,),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              flex: 6,
              child: Shimmer.fromColors(
                  baseColor: providerModel.colorPhotosalons,
                  highlightColor: Colors.grey.shade100,
                  enabled: true,
                  child: GridView.count(
                    padding: const EdgeInsets.all(20),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    crossAxisCount: 3,
                    children: [
                      BannerPlaceholder(),
                      BannerPlaceholder(),
                      BannerPlaceholder(),
                      BannerPlaceholder(),
                      BannerPlaceholder(),
                      BannerPlaceholder(),
                    ],
                  )),
            ),
            Flexible(
              flex: 3,
              child: Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  enabled: true,
                  child: GridView.count(
                    primary: false,
                    padding: const EdgeInsets.all(20),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    crossAxisCount: 3,
                    children: [
                      BannerPlaceholder(),
                      BannerPlaceholder(),
                    ],
                  )),
            ),
            Flexible(
              flex: 7,
              child: Shimmer.fromColors(
                  baseColor: providerModel.colorRepairs,
                  highlightColor: Colors.grey.shade100,
                  enabled: true,
                  child: GridView.count(
                    primary: false,
                    padding: const EdgeInsets.all(20),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    crossAxisCount: 3,
                    children: [
                      BannerPlaceholder(),
                      BannerPlaceholder(),
                      BannerPlaceholder(),
                      BannerPlaceholder(),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
