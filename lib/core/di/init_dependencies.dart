import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../utils/utils.dart' as utils;

/// Initialize application dependencies
Future<void> initDependencies() async {
  await dotenv.load();
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  utils.packageInfo = packageInfo;
}