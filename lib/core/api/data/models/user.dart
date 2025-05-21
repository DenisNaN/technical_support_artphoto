class User{
  late final String name;
  late final String access;
  bool? isAutocomplete;
  String? imagePath;

  User(this.name, this.access, [this.isAutocomplete, this.imagePath]);

  factory User.fromJson(Map<String, Object?> jsonMap){
    return User(jsonMap["name"] as String, jsonMap["access"] as String, jsonMap["isAutocomplete"] as bool, jsonMap["imagePath"] as String);
  }

  Map toJson() => { "name": name, "access": access, "isAutocomplete": isAutocomplete, "imagePath": imagePath};
}