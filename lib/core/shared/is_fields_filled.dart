import 'package:technical_support_artphoto/features/troubles/models/trouble.dart';

import '../../features/repairs/models/repair.dart';

bool isFieldsFilledRepair(Repair repair){
    bool isDateTransferInService = repair.dateTransferInService.toString() == "-0001-11-30 00:00:00.000Z" ||
        repair.dateTransferInService.toString() == "0001-11-30 00:00:00.000Z";
    bool isDateDepartureFormService = repair.dateDepartureFromService.toString() == "-0001-11-30 00:00:00.000Z"  ||
        repair.dateDepartureFromService.toString() == "0001-11-30 00:00:00.000Z" ? true : false;
    bool isDateReceipt = repair.dateReceipt.toString() == "-0001-11-30 00:00:00.000Z" ||
        repair.dateReceipt.toString() == "0001-11-30 00:00:00.000Z" ? true : false;

    if (isDateTransferInService &&
        repair.serviceDislocation == null &&
        isDateDepartureFormService &&
        repair.worksPerformed == '' &&
        repair.diagnosisService == '' &&
        repair.newStatus == '' &&
        repair.newDislocation == '' &&
        isDateReceipt) {
      return false;
    }
    return true;
}

bool isFieldsFilledTrouble(Trouble trouble){
    bool isDateTrouble = trouble.dateTrouble.toString() == "-0001-11-30 00:00:00.000Z" ||
        trouble.dateTrouble.toString() == "0001-11-30 00:00:00.000Z";

    if (trouble.photosalon == '' &&
        isDateTrouble &&
        trouble.employee == '' &&
        trouble.trouble == '' &&
        trouble.fixTroubleEngineer == '' &&
        trouble.fixTroubleEmployee == ''
        ) {
        return false;
    }
    return true;
}