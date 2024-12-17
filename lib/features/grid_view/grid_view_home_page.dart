import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/core/domain/models/photosalon.dart';
import 'package:technical_support_artphoto/core/domain/models/providerModel.dart';
import 'package:technical_support_artphoto/core/domain/models/repair.dart';
import 'package:technical_support_artphoto/core/domain/models/technic.dart';

class GridViewHomePage extends StatelessWidget {
  final Map<String, dynamic> location;
  final Color color;
  const GridViewHomePage({super.key, required this.location, required this.color});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(14.0),
      sliver: SliverGrid.builder(
          itemCount: location.keys.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (_, int index) {
            String nameLocation = location.keys.toList()[index];
            int countTechnics = location[nameLocation].technicals.length;
            bool isHeader = location[nameLocation] is Repair && countTechnics > 0 ? true : false;

            // if(nameLocation == 'Рамиль'){
            //   location[nameLocation].technicals.add(Technic(111111, 234234, 'category', 'name', 'status', 'dislocation'));
            // }

            return GestureDetector(
              onTap: (){
                Navigator.pushNamed(context, 'GridViewTechnics', arguments: location[nameLocation]);
              },
              child: GridTile(
                header: isHeader ? Padding(
                  padding: const EdgeInsets.all(7.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.red.shade400,
                      child: Text(countTechnics.toString()),
                    ),
                  ),
                ) : SizedBox(),
                child: Container(
                    decoration: BoxDecoration(
                      color: color,
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
                    child: Center(
                        // child: Hero(
                        //   tag: 'namePhotosalon',
                          child: Text(location.keys.toList()[index],
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium
                          ),
                        // )
                    )),
              ),
            );
          }),
    );
  }
}


// SliverPadding gridViewHomePage(Map<String, dynamic> location, Color color) {
//   return SliverPadding(
//     padding: const EdgeInsets.all(14.0),
//     sliver: SliverGrid.builder(
//         itemCount: location.keys.length,
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 3,
//           crossAxisSpacing: 16,
//           mainAxisSpacing: 16,
//         ),
//         itemBuilder: (_, int index) {
//           String nameLocation = location.keys.toList()[index];
//           int countTechnics = location[nameLocation].technicals.length;
//           bool isHeader = location[nameLocation] is Repair && countTechnics > 0 ? true : false;
//
//           // if(nameLocation == 'Рамиль'){
//           //   location[nameLocation].technicals.add(Technic(111111, 234234, 'category', 'name', 'status', 'dislocation'));
//           // }
//
//           return GestureDetector(
//             onTap: (){
//
//             },
//             child: GridTile(
//               header: isHeader ? Padding(
//                 padding: const EdgeInsets.all(7.0),
//                 child: Align(
//                   alignment: Alignment.centerRight,
//                   child: CircleAvatar(
//                     radius: 12,
//                     backgroundColor: Colors.red.shade400,
//                     child: Text(countTechnics.toString()),
//                   ),
//                 ),
//               ) : SizedBox(),
//               child: Container(
//                   decoration: BoxDecoration(
//                     color: color,
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.5),
//                         spreadRadius: 2,
//                         blurRadius: 4,
//                         offset: Offset(0, 3), // changes position of shadow
//                       ),
//                     ],
//                   ),
//                   child: Center(
//                       child: Text(location.keys.toList()[index],
//                           overflow: TextOverflow.ellipsis,
//                           style: GoogleFonts.philosopher(
//                             fontSize: 21,
//                             color: Colors.black54,
//                             fontWeight: FontWeight.w700,
//                             fontStyle: FontStyle.italic,
//                           )))),
//             ),
//           );
//         }),
//   );
// }
