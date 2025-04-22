import 'package:flutter/material.dart';
import 'package:technical_support_artphoto/core/api/data/models/repair.dart';
import 'package:technical_support_artphoto/features/technics/presentation/widgets/grid_view_technics.dart';
import 'package:animations/src/open_container.dart';

class GridViewHomePage extends StatelessWidget {
  final Map<String, dynamic> locations;
  final Color color;

  const GridViewHomePage({super.key, required this.locations, required this.color});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(14.0),
      sliver: SliverGrid.builder(
          itemCount: locations.keys.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (_, int index) {
            String nameLocation = locations.keys.toList()[index];
            int countTechnics = locations[nameLocation].technics.length;
            bool isHeader = locations[nameLocation] is Repair && countTechnics > 0 ? true : false;

            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: OpenContainer(
                transitionDuration: Duration(milliseconds: 600),
                openBuilder: (context, openContainer) {
                  return GridViewTechnics(location: locations[nameLocation]);
                },
                closedBuilder: (context, openContainer) {
                  return GestureDetector(
                    onTap: () {
                      openContainer();
                      // Navigator.push(context,
                      //     createRouteScaleTransition(GridViewTechnics(location: locations[nameLocation])));
                    },
                    child: GridTile(
                      header: isHeader
                          ? Padding(
                              padding: const EdgeInsets.all(7.0),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.red.shade400,
                                  child: Text(countTechnics.toString()),
                                ),
                              ),
                            )
                          : SizedBox(),
                      child: Container(
                          color: color,
                          child: Center(
                            child: Text(locations.keys.toList()[index],
                                overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium),
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
