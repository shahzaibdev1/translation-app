import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';

import 'dart:async';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> getAssetPath(String asset) async {
  final path = await getLocalPath(asset);
  await Directory(dirname(path)).create(recursive: true);
  final file = File(path);
  if (!await file.exists()) {
    final byteData = await rootBundle.load(asset);
    await file
        .writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  }
  return file.path;
}

Future<String> getLocalPath(String path) async {
  return '${(await getApplicationSupportDirectory()).path}/$path';
}

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

class PreferencesSettings {
  static void saveTheme(bool theme) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('theme', theme);
  }

  static void getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.getBool('theme') ?? false;
  }
}
