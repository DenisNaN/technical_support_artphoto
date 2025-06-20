import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:technical_support_artphoto/core/api/data/models/repair_location.dart';
import 'package:technical_support_artphoto/features/technics/presentation/widgets/grid_view_technics.dart';

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
            int countBrokenTechnics = 0;
            int countTestDrive = 0;
            int countNotDeadlineTestDrive = 0;
            bool isHeader = false;
            bool isFooter = false;

            bool isHeaderRepair = locations[nameLocation] is RepairLocation;
            if(!isHeaderRepair){
              locations[nameLocation].technics.forEach((element){
                if(element.status == 'Неисправна'){
                  countBrokenTechnics++;
                }
                if(element.status == 'Тест-драйв' && element.testDrive != null){
                  if (element.testDrive!.dateFinish.difference(DateTime.now()).inDays < 0) {
                    countNotDeadlineTestDrive++;
                  }else{
                    countTestDrive++;
                  }
                }
              });
            }
            if((isHeaderRepair && countTechnics > 0) || (!isHeaderRepair && countBrokenTechnics > 0)){
              isHeader = true;
            }
            if(countTestDrive > 0 || countNotDeadlineTestDrive > 0){
              isFooter = true;
            }

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
                  return GridViewTechnics(location: locations[nameLocation]);
                },
                closedBuilder: (context, openContainer) {
                  return GestureDetector(
                    onTap: () {
                      openContainer();
                    },
                    child: GridTile(
                      header: isHeader
                          ? Padding(
                              padding: const EdgeInsets.all(7.0),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: CircleAvatar(
                                  radius: 12,
                                  foregroundColor: Colors.white,
                                  backgroundColor: isHeaderRepair ? Colors.green.shade400 : Colors.red.shade400,
                                  child: Text(isHeaderRepair? countTechnics.toString() : countBrokenTechnics.toString()),
                                ),
                              ),
                            )
                          : SizedBox(),
                      footer: isFooter ? Padding(
                        padding: const EdgeInsets.all(7.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              countTestDrive > 0 ? CircleAvatar(
                                radius: 12,
                                foregroundColor: Colors.black45,
                                backgroundColor: Colors.yellowAccent,
                                child: Text(countTestDrive.toString()),
                              ) : SizedBox(),
                              SizedBox(width: countTestDrive > 0 ? 5 : 0,),
                              countNotDeadlineTestDrive > 0 ? CircleAvatar(
                                radius: 12,
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.deepOrangeAccent.shade200,
                                child: Text(countNotDeadlineTestDrive.toString()),
                              ) : SizedBox(),
                            ],
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
