import 'package:technical_support_artphoto/features/troubles/models/trouble.dart';

import '../../features/repairs/models/repair.dart';

bool isFieldsFilledRepair(Repair repair){
    bool isDateTransferInService = repair.dateTransferInService.toString() == "-0001-11-30 00:00:00.000Z" ||
        repair.dateTransferInService.toString() == "0001-11-30 00:00:00.000Z" || repair.dateTransferInService == null;
    bool isServiceDislocation = repair.serviceDislocation == null;
    bool isDateDepartureFormService = repair.dateDepartureFromService.toString() == "-0001-11-30 00:00:00.000Z"  ||
        repair.dateDepartureFromService.toString() == "0001-11-30 00:00:00.000Z" || repair.dateDepartureFromService == null;
    bool isWorksPerformed = repair.worksPerformed == '' || repair.worksPerformed == null;
    bool isDiagnosisService = repair.diagnosisService == '' || repair.diagnosisService == null;
    bool isNewStatus = repair.newStatus == '' || repair.newStatus == null;
    bool isNewDislocation = repair.newDislocation == '' || repair.newDislocation == null;
    bool isDateReceipt = repair.dateReceipt.toString() == "-0001-11-30 00:00:00.000Z" ||
        repair.dateReceipt.toString() == "0001-11-30 00:00:00.000Z" || repair.dateReceipt == null;


    if (isDateTransferInService &&
        isServiceDislocation &&
        isDateDepartureFormService &&
        isWorksPerformed &&
        isDiagnosisService &&
        isNewStatus &&
        isNewDislocation &&
        isDateReceipt) {
      return false;
    }
    return true;
}

bool isFieldsFilledTrouble(Trouble trouble){
    if (trouble.fixTroubleEngineer == '' ||
        trouble.fixTroubleEmployee == ''
        ) {
        return false;
    }
    return true;
}

bool isFieldEmployeeFilledTrouble(Trouble trouble) {
    bool result = false;
    if (trouble.dateFixTroubleEmployee.toString() != "-0001-11-30 00:00:00.000Z" &&
        trouble.dateFixTroubleEmployee.toString() != "0001-11-30 00:00:00.000Z") {
        result = true;
    }
    return result;
}