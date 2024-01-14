
class History{
  static List historyList = [];

  int? id;
  String section = '';
  int? idSection;
  String typeOperation = '';
  String description = '';
  String login = '';
  String date = '';

  History(this.id, this.section, this.idSection, this.typeOperation, this.description, this.login,
      this.date);
}