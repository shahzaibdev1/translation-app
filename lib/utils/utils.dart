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

List allLanguages = [
  {"code": "af", "name": "afrikaans"},
  {"code": "sq", "name": "albanian"},
  {"code": "am", "name": "amharic"},
  {"code": "ar", "name": "arabic"},
  {"code": "hy", "name": "armenian"},
  {"code": "as", "name": "assamese"},
  {"code": "ay", "name": "aymara"},
  {"code": "az", "name": "azerbaijani"},
  {"code": "bm", "name": "bambara"},
  {"code": "eu", "name": "basque"},
  {"code": "be", "name": "belarusian"},
  {"code": "bn", "name": "bengali"},
  {"code": "bho", "name": "bhojpuri"},
  {"code": "bs", "name": "bosnian"},
  {"code": "bg", "name": "bulgarian"},
  {"code": "ca", "name": "catalan"},
  {"code": "ceb", "name": "cebuano"},
  {"code": "ny", "name": "chichewa"},
  {"code": "zh", "name": "chinese"},
  {"code": "zh_HANT", "name": "chinese (traditional)"},
  {"code": "co", "name": "corsican"},
  {"code": "hr", "name": "croatian"},
  {"code": "cs", "name": "czech"},
  {"code": "da", "name": "danish"},
  {"code": "dv", "name": "dhivehi"},
  {"code": "doi", "name": "dogri"},
  {"code": "nl", "name": "dutch"},
  {"code": "en", "name": "english"},
  {"code": "eo", "name": "esperanto"},
  {"code": "et", "name": "estonian"},
  {"code": "ee", "name": "ewe"},
  {"code": "tl", "name": "filipino"},
  {"code": "fi", "name": "finnish"},
  {"code": "fr", "name": "french"},
  {"code": "fy", "name": "frisian"},
  {"code": "gl", "name": "galician"},
  {"code": "ka", "name": "georgian"},
  {"code": "de", "name": "german"},
  {"code": "el", "name": "greek"},
  {"code": "gn", "name": "guarani"},
  {"code": "gu", "name": "gujarati"},
  {"code": "ht", "name": "haitian creole"},
  {"code": "ha", "name": "hausa"},
  {"code": "haw", "name": "hawaiian"},
  {"code": "iw", "name": "hebrew"},
  {"code": "hi", "name": "hindi"},
  {"code": "hmn", "name": "hmong"},
  {"code": "hu", "name": "hungarian"},
  {"code": "is", "name": "icelandic"},
  {"code": "ig", "name": "igbo"},
  {"code": "ilo", "name": "ilocano"},
  {"code": "id", "name": "indonesian"},
  {"code": "ga", "name": "irish"},
  {"code": "it", "name": "italian"},
  {"code": "ja", "name": "japanese"},
  {"code": "jw", "name": "javanese"},
  {"code": "kn", "name": "kannada"},
  {"code": "kk", "name": "kazakh"},
  {"code": "km", "name": "khmer"},
  {"code": "rw", "name": "kinyarwanda"},
  {"code": "gom", "name": "konkani"},
  {"code": "ko", "name": "korean"},
  {"code": "kri", "name": "krio"},
  {"code": "ku", "name": "kurdish (kurmanji)"},
  {"code": "ckb", "name": "kurdish (sorani)"},
  {"code": "ky", "name": "kyrgyz"},
  {"code": "lo", "name": "lao"},
  {"code": "la", "name": "latin"},
  {"code": "lv", "name": "latvian"},
  {"code": "ln", "name": "lingala"},
  {"code": "lt", "name": "lithuanian"},
  {"code": "lg", "name": "luganda"},
  {"code": "lb", "name": "luxembourgish"},
  {"code": "mk", "name": "macedonian"},
  {"code": "mai", "name": "maithili"},
  {"code": "mg", "name": "malagasy"},
  {"code": "ms", "name": "malay"},
  {"code": "ml", "name": "malayalam"},
  {"code": "mt", "name": "maltese"},
  {"code": "mi", "name": "maori"},
  {"code": "mr", "name": "marathi"},
  {"code": "mni-Mtei", "name": "meiteilon (manipuri)"},
  {"code": "lus", "name": "mizo"},
  {"code": "mn", "name": "mongolian"},
  {"code": "my", "name": "myanmar (burmese)"},
  {"code": "ne", "name": "nepali"},
  {"code": "no", "name": "norwegian"},
  {"code": "or", "name": "odia (oriya)"},
  {"code": "om", "name": "oromo"},
  {"code": "ps", "name": "pashto"},
  {"code": "fa", "name": "persian"},
  {"code": "pl", "name": "polish"},
  {"code": "pt", "name": "portuguese"},
  {"code": "pa", "name": "punjabi"},
  {"code": "qu", "name": "quechua"},
  {"code": "ro", "name": "romanian"},
  {"code": "ru", "name": "russian"},
  {"code": "sm", "name": "samoan"},
  {"code": "sa", "name": "sanskrit"},
  {"code": "gd", "name": "scots gaelic"},
  {"code": "nso", "name": "sepedi"},
  {"code": "sr", "name": "serbian"},
  {"code": "st", "name": "sesotho"},
  {"code": "sn", "name": "shona"},
  {"code": "sd", "name": "sindhi"},
  {"code": "si", "name": "sinhala"},
  {"code": "sk", "name": "slovak"},
  {"code": "sl", "name": "slovenian"},
  {"code": "so", "name": "somali"},
  {"code": "es", "name": "spanish"},
  {"code": "su", "name": "sundanese"},
  {"code": "sw", "name": "swahili"},
  {"code": "sv", "name": "swedish"},
  {"code": "tg", "name": "tajik"},
  {"code": "ta", "name": "tamil"},
  {"code": "tt", "name": "tatar"},
  {"code": "te", "name": "telugu"},
  {"code": "th", "name": "thai"},
  {"code": "ti", "name": "tigrinya"},
  {"code": "ts", "name": "tsonga"},
  {"code": "tr", "name": "turkish"},
  {"code": "tk", "name": "turkmen"},
  {"code": "ak", "name": "twi"},
  {"code": "uk", "name": "ukrainian"},
  {"code": "ur", "name": "urdu"},
  {"code": "ug", "name": "uyghur"},
  {"code": "uz", "name": "uzbek"},
  {"code": "vi", "name": "vietnamese"},
  {"code": "cy", "name": "welsh"},
  {"code": "xh", "name": "xhosa"},
  {"code": "yi", "name": "yiddish"},
  {"code": "yo", "name": "yoruba"},
  {"code": "zu", "name": "zulu"}
];
