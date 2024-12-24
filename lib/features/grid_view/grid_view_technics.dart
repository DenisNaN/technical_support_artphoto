import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/core/domain/models/providerModel.dart';
import 'package:technical_support_artphoto/core/domain/models/technic.dart';
import 'dart:math';

class GridViewTechnics extends StatelessWidget {
  final dynamic location;
  const GridViewTechnics({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    final providerModel = Provider.of<ProviderModel>(context);
    final List<Technic> technics = location.technics;

    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(location.name, style: Theme.of(context).textTheme.titleMedium),
              Text(
                'Кол-во: ${location.technics.length}',
                style: Theme.of(context).textTheme.titleMedium,
              )
            ],
          ),
        ),
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
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
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
                                child: Stack(children: [
                              technic.category == 'Телевизор' ? Image.asset(_randomScreenForTV()) : SizedBox(),
                              Image.asset(_switchIconTechnic(technic.category))
                            ])),
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
                    );
                  }),
            ),
          ],
        ));
  }

  String _switchIconTechnic(String category) {
    switch (category) {
      case 'Принтер':
        return 'assets/icons_gridview_technical/printer.png';
      case 'Копир':
        return 'assets/icons_gridview_technical/copier.png';
      case 'Фотоаппарат':
        return 'assets/icons_gridview_technical/camera.png';
      case 'Вспышка':
        return 'assets/icons_gridview_technical/flash.png';
      case 'Ламинатор':
        return 'assets/icons_gridview_technical/laminator.png';
      case 'Сканер':
        return 'assets/icons_gridview_technical/scanner.png';
      case 'Телевизор':
        return 'assets/icons_gridview_technical/television.png';
      default:
        return '';
    }
  }

  String _randomScreenForTV() {
    return 'assets/icons_gridview_technical/screens_tv/screentv-${Random().nextInt(33) + 1}.png';
  }
}
