import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:technical_support_artphoto/core/api/data/models/decommissioned.dart';
import 'package:technical_support_artphoto/core/api/data/repositories/technical_support_repo_impl.dart';
import 'package:technical_support_artphoto/features/technics/presentation/widgets/grid_view_technics.dart';

import '../../../../core/shared/custom_app_bar/custom_app_bar.dart';
import '../../../../core/shared/logo_animate/logo_matrix_transition_animate.dart';
import '../../../../core/utils/enums.dart';

class GridViewBasketDecommissioned extends StatelessWidget {
  const GridViewBasketDecommissioned({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    return SliverPadding(
      padding: const EdgeInsets.all(14.0),
      sliver: SliverGrid.builder(
          itemCount: 1,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (_, int index) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade500,
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: OpenContainer(
                transitionDuration: Duration(milliseconds: 600),
                openBuilder: (context, openContainer) {
                  return FutureBuilder(
                    future: TechnicalSupportRepoImpl.downloadData.getTechnicsDecommissioned(),
                    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.hasData) {
                        DecommissionedLocation decommissioned = snapshot.data;
                        return GridViewTechnics(location: decommissioned);
                      } else if (snapshot.hasError) {
                        return Scaffold(
                            appBar: CustomAppBar(typePage: TypePage.error, location: 'Произошел сбой', technic: null),
                            body: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.wifi_off,
                                    size: 150,
                                    color: Colors.blue,
                                    shadows: [
                                      BoxShadow(
                                        color: Colors.grey.withValues(alpha: 0.5),
                                        spreadRadius: 3,
                                        blurRadius: 4,
                                        offset: Offset(0, 4), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Данные не загрузились.\nПроверьте подключение к сети',
                                    style: TextStyle(fontSize: 20),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ));
                      } else {
                        return Padding(
                          padding: EdgeInsets.only(top: height / 2.5),
                          child: Center(child: MatrixTransitionLogo()),
                        );
                      }
                    },
                  );
                },
                closedBuilder: (context, openContainer) {
                  return GestureDetector(
                    onTap: () {
                      openContainer();
                    },
                    child: GridTile(
                      child: Container(
                          color: Colors.grey.shade300,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.print_disabled,
                                  size: 35,
                                ),
                                Text(
                                  'Списанная',
                                  style: TextStyle(fontSize: 15),
                                ),
                                Text(
                                  'техника',
                                  style: TextStyle(fontSize: 15),
                                )
                              ],
                            ),
                          )),
                    ),
                  );
                },
              ),
            );
          }),
    );
  }
}
