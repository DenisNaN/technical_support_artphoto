class TroubleAccountMailRu{
  final int id;
  final String name;
  final String account;
  final String password;

  TroubleAccountMailRu({required this.id, required this.name, required this.account, required this.password});

  factory TroubleAccountMailRu.fromJson(Map<String, Object?> jsonMap){
    return TroubleAccountMailRu(id: jsonMap["id"] as int, name: jsonMap["name"] as String, account: jsonMap["account"] as String, password: jsonMap["password"] as String);
  }

  Map toJson() => { "id": id, "name": name, "account": account, "password": password};
}