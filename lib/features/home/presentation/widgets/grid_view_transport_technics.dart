import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:technical_support_artphoto/core/api/data/models/transportation_location.dart';
import 'package:technical_support_artphoto/features/technics/presentation/widgets/grid_view_technics.dart';

class GridViewTransportTechnics extends StatelessWidget {
  final Map<String, dynamic> locations;
  final Color color;

  const GridViewTransportTechnics({super.key, required this.locations, required this.color});

  @override
  Widget build(BuildContext context) {
    Map<String, TransportationLocation> mapLocations = {};
    for(final element in locations.entries){
      TransportationLocation transportationLocation = element.value;
       if(transportationLocation.technics.isNotEmpty) {
        mapLocations[element.key] = transportationLocation;
      }
    }
    return SliverPadding(
      padding: const EdgeInsets.all(14.0),
      sliver: SliverGrid.builder(
          itemCount: mapLocations.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (_, int index) {
            String nameLocation = mapLocations.keys.toList()[index];
            int countTechnics = mapLocations[nameLocation]!.technics.length;

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
                  return GridViewTechnics(location: mapLocations[nameLocation]);
                },
                closedBuilder: (context, openContainer) {
                  return GestureDetector(
                    onTap: () {
                      openContainer();
                    },
                    child: GridTile(
                      header: Padding(
                        padding: const EdgeInsets.all(7.0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: CircleAvatar(
                            radius: 12,
                            foregroundColor: Colors.black54,
                            backgroundColor: Colors.white,
                            child: Text(countTechnics.toString()),
                          ),
                        ),
                      ),
                      child: Container(
                          color: color,
                          child: Center(
                            child: Text(mapLocations.keys.toList()[index],
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
