import 'package:flutter/material.dart';
import 'package:technical_support_artphoto/core/api/data/models/technic.dart';
import 'package:technical_support_artphoto/core/shared/custom_app_bar/custom_app_bar.dart';
import 'package:technical_support_artphoto/core/utils/enums.dart';
import 'package:technical_support_artphoto/core/shared/technic_image/technic_image.dart';
import 'package:technical_support_artphoto/features/technics/presentation/page/technic_view.dart';
import '../../../../core/navigation/animation_navigation.dart';

class GridViewTechnics extends StatelessWidget {
  const GridViewTechnics({super.key, required this.location});
  final dynamic location;

  @override
  Widget build(BuildContext context) {
    final List<Technic> technics = location.technics;

    return Scaffold(
        appBar: CustomAppBar(typePage: TypePage.listTechnics, location: location, technic: null),
        body: CustomScrollView(
          physics: BouncingScrollPhysics(),
          primary: false,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(14.0),
              sliver: SliverGrid.builder(
                  itemCount: technics.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemBuilder: (_, int index) {
                    Technic technic = technics[index];

                    return GridTile(
                      header: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 2),
                              child: Text(
                                technic.category,
                                style: Theme.of(context).textTheme.titleSmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black54, width: 1),
                                  borderRadius: BorderRadius.only(topRight: Radius.circular(10))),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Text(technic.number.toString()),
                              )),
                        ],
                      ),
                      child: InkWell(
                        onTap: (){
                          Navigator.push(
                              context, animationRouteSlideTransition(TechnicView(location: location, technic: technic)));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade500,
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              Expanded(
                                  child: TechnicImage(category: technic.category)),
                              Padding(
                                padding: const EdgeInsets.only(left: 4, right: 2),
                                child: Text(
                                  technic.name == '' ? 'Модель не указана' : technic.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            ),
          ],
        ));
  }
}
