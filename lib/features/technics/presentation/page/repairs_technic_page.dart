import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:technical_support_artphoto/core/api/data/models/technic.dart';
import 'package:technical_support_artphoto/core/api/data/repositories/technical_support_repo_impl.dart';
import 'package:technical_support_artphoto/core/navigation/animation_navigation.dart';
import 'package:technical_support_artphoto/core/shared/custom_app_bar/custom_app_bar.dart';
import 'package:technical_support_artphoto/core/utils/enums.dart';
import 'package:technical_support_artphoto/features/repairs/models/summ_repair.dart';
import 'package:technical_support_artphoto/features/repairs/presentation/page/repair_view.dart';

class RepairsTechnicPage extends StatefulWidget {
  final List<SummRepair> summsRepairs;
  final Technic technic;

  const RepairsTechnicPage({super.key, required this.summsRepairs, required this.technic});

  @override
  State<RepairsTechnicPage> createState() => _RepairsTechnicPageState();
}

class _RepairsTechnicPageState extends State<RepairsTechnicPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(typePage: TypePage.technicRepair, technic: widget.technic, location: null,),
      body: ListView.builder(
          itemCount: widget.summsRepairs.length,
          itemBuilder: (context, index) {
            Color colorStage = _getColorStage(widget.summsRepairs[index]);
            return Container(
              margin: const EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 8),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 0.5),
                  borderRadius: BorderRadius.circular(10),
                  color: colorStage,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 4,
                      offset: Offset(2, 4), // Shadow position
                    ),
                  ]),
              child: ListTile(
                title: _buildText(context, index),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                onTap: () {
                  TechnicalSupportRepoImpl.downloadData.getRepair(widget.summsRepairs[index].idRepair).then((repair){
                    if(repair != null && context.mounted){
                      Navigator.push(context,
                          animationRouteSlideTransition(RepairView(repair: repair)));
                    }
                  });
                },
              ),
            );
          }),
    );
  }

  Padding _buildText(BuildContext context, int index) {
    SummRepair repair = widget.summsRepairs[index];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ремонтировал: ${repair.repairmen}',
            style: GoogleFonts.montserratAlternates(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Text.rich(TextSpan(children: [
            TextSpan(text: 'Жалоба: ', style: TextStyle(fontWeight: FontWeight.bold)
            ),
            TextSpan(text: repair.complaint)
          ])),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Container(height: 1, color: Colors.black87,),
          ),
          Text.rich(TextSpan(children: [
            TextSpan(text: 'Выполненые работы: ', style: TextStyle(fontWeight: FontWeight.bold)
            ),
            TextSpan(text: repair.worksPerformed)
          ])),
          SizedBox(height: 7,),
          Text('${repair.summRepair} р.',
              style: GoogleFonts.montserratAlternates(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.indigo),
          ),
        ],
      ),
    );

    //   Text.rich(
    //     TextSpan(children: [
    //       TextSpan(text: 'Ремонтировал: ${repair.repairmen}\n', style: const TextStyle(fontSize: 20)),
    //       TextSpan(text: 'Сумма ремонта: ${repair.summRepair}\n'),
    //       TextSpan(text: 'Жалоба: ${repair.complaint}\n'),
    //     ]
    //     )
    // );
  }

  String getDateFormat(DateTime date) {
    return DateFormat("d MMMM yyyy", "ru_RU").format(date);
  }

  Color _getColorStage(SummRepair repair) {
    String dateRec = getDateFormat(repair.dateReceipt!);
    String dateTrans = getDateFormat(repair.dateTransferInService!);
    if (dateRec != '30 ноября 0001') {
      return Colors.lightGreenAccent;
    } else if (dateTrans != '30 ноября 0001') {
      return Colors.yellow.shade200;
    } else {
      return Colors.red.shade100;
    }
  }
}
