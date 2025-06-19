enum ColorStageRepair{
  red,
  yellow,
  green
}

enum TypePage{
  listTechnics,
  addTechnic,
  viewTechnic,
  repair,
  addRepair,
  viewRepair,
  history,
  technicRepair,
  addTrouble,
  viewTrouble,
  error,
}

enum TypeDislocation{
  photosalon,
  storage,
  repair,
}

enum TypeMessageForSaveRepairView{
  successSaveRepair,
  notSuccessSaveRepair,
  notSuccessSaveStatus,
  notWriteAllFieldStatus,
  notCheckTechnicInDB,
}

enum TestDriveStatus{
  notMake,
  inProcess,
  finished,
  missDeadline,
}

enum SaveTestDriveStatus{
  notSave,
  save,
  update,
}