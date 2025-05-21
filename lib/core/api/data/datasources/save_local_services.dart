// ignore_for_file: unused-code

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:technical_support_artphoto/core/api/data/models/user.dart';

/// Save local services
class SaveLocalServices {
  final ImagePicker _picker = ImagePicker();

  /// Фабричный конструктор для получения единственного экземпляра
  factory SaveLocalServices() => _instance;

  /// Закрытый конструктор для синглтона
  SaveLocalServices._internal();
  static final SaveLocalServices _instance = SaveLocalServices._internal();
  late SharedPreferences _prefs;

  /// Асинхронный метод инициализации для загрузки SharedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Сохранение пользователя в SharedPreferences
  Future<void> saveUser(User user) async {
    final String userString = jsonEncode(user.toJson());
    await _prefs.setString('user', userString);
  }

  /// Получение пользователя из SharedPreferences
  User? getUser() {
    final String? userString = _prefs.getString('user');
    if (userString == null) return null;
    return User.fromJson(jsonDecode(userString));
  }

  /// Удаление пользователя из SharedPreferences (для выхода из аккаунта)
  Future<void> removeUser() async {
    await _prefs.remove('user');
  }

  Future<XFile?> pickImage() async {
    try {
      return await _picker.pickImage(source: ImageSource.gallery);
    } on Exception catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  /// Save the image to local storage (SharedPreferences) for an unregistered user
  Future<String> saveImageLocally({required File imageFile}) async {
    final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    final String imageFileName =
    DateTime.now().millisecondsSinceEpoch.toString();

    final String localDirPath = '${appDocumentsDir.path}/images_meal/';

    final Directory localDir = Directory(localDirPath);
    if (!localDir.existsSync()) {
      await localDir.create(recursive: true);
      debugPrint('Directory created at: $localDirPath');
    }

    final String localImagePath = '$localDirPath$imageFileName.jpg';
    await imageFile.copy(localImagePath);
    debugPrint('Image successfully saved locally: $localImagePath');

    return localImagePath;
  }
}
