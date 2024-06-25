import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
// import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:provider/provider.dart';
import 'package:translation_app/TextRecognizer.dart';
import 'package:translation_app/db/db_helper.dart';
import 'package:translation_app/drawer/drawer.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:http/http.dart' as http;

import 'package:share_plus/share_plus.dart';
import 'package:translation_app/favorites/favorites.dart';
import 'package:translation_app/providers/speech_to_text.dart';
import 'package:translation_app/utils/utils.dart';

class TextScreen extends StatefulWidget {
  const TextScreen({super.key});

  @override
  State<TextScreen> createState() => _TextScreenState();
}

class _TextScreenState extends State<TextScreen> {
  TextEditingController inputFieldController = TextEditingController();
  Map<String, String> _selectedFromLang = {"code": "auto", "name": "Detect Language"};
  Map<String, String> _selectedToLang = {"code": "es", "name": "Spanish"};

  String _translatedText = "";
  // final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  final FlutterTts _flutterTts = FlutterTts();
  bool isTextEmpty = true;
  TextEditingController fromTextController = TextEditingController();
  TextEditingController toTextController = TextEditingController();
  bool isFromTextEmpty = true;
  bool isToTextEmpty = true;
  // final _modelManager = OnDeviceTranslatorModelManager();
  bool isLoading = false;
  // bool isListening = false;
  List allFavs = [];

  @override
  void initState() {
    super.initState();
    _initSpeech();

    getFavs();
  }

  void getFavs() async {
    final dbHelper = FavDbHelper();

    var allFavsFromDb = await dbHelper.getData();
    print("allFavsFromDb: $allFavsFromDb");

    setState(() {
      allFavs = allFavsFromDb;
    });
  }

  @override
  void dispose() {
    // _speechToText.cancel();
    super.dispose();
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    // _speechEnabled = await _speechToText.initialize(onStatus: (status) {
    //   if (status == "listening") {
    //     setState(() {
    //       isListening = true;
    //     });
    //   } else if (status == "notListening") {
    //     setState(() {
    //       isListening = false;
    //     });
    //   }
    // }, onError: (errorNotification) {
    //   // ScaffoldMessenger.of(context).showSnackBar(
    //   //   SnackBar(
    //   //     content: Text(errorNotification.errorMsg ?? "Something went wrong"),
    //   //   ),
    //   // );
    // });
  }

  /// Each time to start a speech recognition session
  void _startListening() {
    Provider.of<SpeachToTextProvider>(context, listen: false)
        .startListening(onResult: _onSpeechResult, idx: 1);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() {
    Provider.of<SpeachToTextProvider>(context, listen: false).stopListening();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      inputFieldController.text = result.recognizedWords;
      _lastWords = result.recognizedWords;
    });
  }

  Future<dynamic> fetchData(String text) async {
    final response = await http.get(Uri.parse(
        'https://lingva.ml/api/v1/${_selectedFromLang["code"]}/${_selectedToLang["code"]}/${text}'));

    if (response.statusCode == 200 && text.isNotEmpty) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load translation');
    }
  }

  void translateText() async {
    final ThemeData theme = Theme.of(context);

    setState(() {
      isLoading = true;
    });

    try {
      String text = inputFieldController.text;
      if (text.isEmpty) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: theme.colorScheme.errorContainer,
            content: Text('Text is empty!', style: TextStyle(color: theme.colorScheme.error)),
            duration: const Duration(seconds: 5),
          ),
        );
        return;
      }

      var translatedObj = await fetchData(text);

      if (translatedObj["translation"] != null) {
        var translatedText = translatedObj["translation"];

        // final onDeviceTranslator =
        //     OnDeviceTranslator(sourceLanguage: _selectedFromLang, targetLanguage: _selectedToLang);

        // final String translatedText = await onDeviceTranslator.translateText(text);

        setState(() {
          _translatedText = translatedText;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Something went wrong while translating text: $e");
    }
  }

  void _startSpeaking(text, String target) async {
    await _flutterTts.setVolume(1.0);
    if (target == "to") {
      _flutterTts.setLanguage(_selectedToLang["code"]!);
      _flutterTts.speak(text);
    } else if (target == "from") {
      _flutterTts.setLanguage(_selectedFromLang["code"]!);
      _flutterTts.speak(text);
    }
  }

  void _stopSpeaking(text) {
    _flutterTts.stop();
  }

  share(String text) async {
    await Share.share(text);
  }

  copyText(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  void _onFromSelected(lang, BuildContext ctx) {
    try {
      // _modelManager.isModelDownloaded(lang.bcpCode).then((value) async {
      //   if (!value) {
      //     setState(() {
      //       isDownloading = true;
      //     });
      //     var snackbar = ScaffoldMessenger.of(context).showSnackBar(
      //       const SnackBar(
      //         content: Text('Your language model is downloading...'),
      //         duration: Duration(days: 3),
      //       ),
      //     );

      //     await _modelManager.downloadModel(lang.bcpCode);
      //     setState(() {
      //       isDownloading = false;
      //     });
      //     snackbar.close();
      //   }
      // });

      setState(() {
        _selectedFromLang = lang;
      });

      Navigator.pop(ctx);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong!')),
      );
    }
  }

  void _onToSelected(lang, BuildContext ctx) {
    try {
      // _modelManager.isModelDownloaded(lang.bcpCode).then((value) async {
      //   if (!value) {
      //     setState(() {
      //       isDownloading = true;
      //     });
      //     var snackbar = ScaffoldMessenger.of(context).showSnackBar(
      //       const SnackBar(
      //         content: Text('Your language model is downloading...'),
      //         duration: Duration(days: 3),
      //       ),
      //     );

      //     await _modelManager.downloadModel(lang.bcpCode);
      //     setState(() {
      //       isDownloading = false;
      //     });
      //     snackbar.close();
      //   }
      // });

      setState(() {
        _selectedToLang = lang;
      });

      Navigator.pop(ctx);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong!')),
      );
    }
  }

  handleChange(String value) {
    setState(() {
      fromTextController.text = value; // Update the text controller
      isFromTextEmpty = value.isEmpty;
    });
  }

  handleToChange(String value) {
    setState(() {
      toTextController.text = value; // Update the text controller
      isToTextEmpty = value.isEmpty;
    });
  }

  _showFrom(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    showModalBottomSheet(
        elevation: 10,
        // backgroundColor: Colors.amber,
        enableDrag: true,
        showDragHandle: true,
        context: context,
        builder: (ctx) => StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
              return Container(
                // width: 300,
                height: MediaQuery.of(context).size.height * 0.6,
                // color: Colors.white54,
                alignment: Alignment.center,
                child: ListView(children: [
                  ListTile(
                      title: TextFormField(
                          controller: fromTextController,
                          onChanged: handleChange,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: theme.colorScheme.background,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
                            suffixIcon: Visibility(
                              visible: !isFromTextEmpty,
                              child: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  fromTextController.clear();
                                  setState(() {
                                    isFromTextEmpty = true;
                                  });
                                },
                              ),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                            labelText: "Search",
                          ))),
                  const ListTile(title: Text("All Languages", style: TextStyle(fontSize: 20))),
                  const Divider(indent: 5),
                  ListTile(
                      title: TextButton(
                          style: const ButtonStyle(alignment: Alignment.centerLeft),
                          onPressed: () =>
                              _onFromSelected({"code": "auto", "name": "Detect Language"}, context),
                          child: const Text("Detect Language"))),
                  ...allLanguages
                      .where((element) =>
                          element["name"].startsWith(fromTextController.text.toLowerCase()))
                      .map((title) => ListTile(
                          title: TextButton(
                              style: const ButtonStyle(alignment: Alignment.centerLeft),
                              onPressed: () => _onFromSelected(title, ctx),
                              child: Text(title["name"]))))
                      .toList()
                ]),
              );
            }));
  }

  _showTo(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    showModalBottomSheet(
        elevation: 10,
        // backgroundColor: Colors.amber,
        enableDrag: true,
        showDragHandle: true,
        context: context,
        builder: (ctx) => StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
              return Container(
                // width: 300,
                height: MediaQuery.of(context).size.height * 0.6,
                // color: Colors.white54,
                alignment: Alignment.center,
                child: ListView(children: [
                  ListTile(
                      title: TextFormField(
                          controller: toTextController,
                          onChanged: handleToChange,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: theme.colorScheme.background,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
                            suffixIcon: Visibility(
                              visible: !isToTextEmpty,
                              child: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  toTextController.clear();
                                  setState(() {
                                    isToTextEmpty = true;
                                  });
                                },
                              ),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                            labelText: "Search",
                          ))),
                  const ListTile(title: Text("All Languages", style: TextStyle(fontSize: 20))),
                  const Divider(indent: 5),
                  ...allLanguages
                      .where((element) =>
                          element["name"].startsWith(toTextController.text.toLowerCase()))
                      .map((title) => ListTile(
                          title: TextButton(
                              style: const ButtonStyle(alignment: Alignment.centerLeft),
                              onPressed: () => _onToSelected(title, ctx),
                              child: Text(title["name"]))))
                      .toList()
                ]),
              );
            }));
  }

  void addToFav() async {
    // _translatedText
    // inputFieldController.text
    DateTime time = DateTime.now();
    final dbHelper = FavDbHelper();

    dbHelper.insertData({
      "text": inputFieldController.text,
      "translation": _translatedText,
      'time': DateFormat("dd MMM yyyy, hh:mm a").format(time),
    });

    var allFavsFromDb = await dbHelper.getData();

    setState(() {
      allFavs = allFavsFromDb;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
        drawer: const DrawerWidget(),
        appBar: AppBar(
          title: const Text("Translator"),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return Builder(
                          builder: (context) {
                            return const Favorites();
                          },
                        );
                      },
                    ),
                  );
                },
                icon: const Icon(Icons.star_rounded),
                iconSize: 30)
          ],
        ),
        body: SingleChildScrollView(
          child: SafeArea(
              child: Column(
            children: [
              Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Column(children: [
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SizedBox(
                                // width: MediaQuery.of(context).size.width * 0.35,
                                child: FilledButton.icon(
                                    style: ButtonStyle(
                                        shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10))),
                                        foregroundColor:
                                            const MaterialStatePropertyAll(Colors.black),
                                        backgroundColor:
                                            MaterialStatePropertyAll(Colors.blue.shade200)),
                                    onPressed: () => _showFrom(context),
                                    label: Text(_selectedFromLang["name"]!),
                                    icon: const Icon(Icons.arrow_drop_down)),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.05,
                                child: const Icon(Icons.chevron_right),
                              ),
                              SizedBox(
                                // width: MediaQuery.of(context).size.width * 0.35,
                                child: FilledButton.icon(
                                    style: ButtonStyle(
                                        // textStyle: MaterialStatePropertyAll(TextStyle(fontSize: 12)),
                                        shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10))),
                                        foregroundColor:
                                            const MaterialStatePropertyAll(Colors.black),
                                        backgroundColor:
                                            MaterialStatePropertyAll(Colors.blue.shade200)),
                                    onPressed: () => _showTo(context),
                                    label: Text(_selectedToLang["name"]!),
                                    icon: const Icon(Icons.arrow_drop_down)),
                              ),
                              // _buildToDropdown(),
                            ])),
                    const Divider(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: TextField(
                        minLines: 4,
                        maxLines: 6,
                        controller: inputFieldController,
                        style: const TextStyle(fontSize: 30),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          labelStyle: TextStyle(fontSize: 20),
                          labelText: "Enter text here",
                        ),
                        onChanged: (value) {
                          setState(() {
                            isTextEmpty = value.isEmpty;
                          });
                        },
                      ),
                    ),
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Row(
                          mainAxisAlignment: inputFieldController.text != ""
                              ? MainAxisAlignment.spaceBetween
                              : MainAxisAlignment.end,
                          children: [
                            Visibility(
                              // Use Visibility for conditional visibility
                              visible: !isTextEmpty,
                              child: IconButton.filled(
                                onPressed: () => _startSpeaking(inputFieldController.text, "from"),
                                icon: SvgPicture.asset(
                                  "assets/images/speak.svg",
                                  colorFilter: ColorFilter.mode(
                                    theme.colorScheme.onPrimary,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                              IconButton.filled(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return Builder(
                                            builder: (context) {
                                              return const TextRecognizerView();
                                            },
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.camera_alt)),
                              IconButton.filled(
                                  onPressed: Provider.of<SpeachToTextProvider>(context).status ==
                                          "listening"
                                      ? _stopListening
                                      : _startListening,
                                  icon: Provider.of<SpeachToTextProvider>(context).status ==
                                          "listening"
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: theme.colorScheme.onPrimary,
                                          ))
                                      : const Icon(Icons.mic)),
                              ElevatedButton(
                                onPressed: () => translateText(),
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(theme.colorScheme.primary),
                                    foregroundColor: MaterialStateProperty.all<Color>(
                                        theme.colorScheme.onPrimary)),
                                child: const Text("Translate"),
                              )
                            ])
                          ],
                        ))
                  ])),
              Visibility(
                  visible: _translatedText.isNotEmpty,
                  child: Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Container(
                          height: 250,
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.all(20),
                          child: SingleChildScrollView(
                            child: Text(
                              _translatedText == "" ? "Translated text" : _translatedText,
                              style: TextStyle(fontSize: 30, color: theme.colorScheme.primary),
                            ),
                          ),
                        ),
                        Container(
                            margin: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
                            child:
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              _translatedText != ""
                                  ? IconButton.filled(
                                      onPressed: () => _startSpeaking(_translatedText, "to"),
                                      icon: SvgPicture.asset(
                                        "assets/images/speak.svg",
                                        colorFilter: ColorFilter.mode(
                                            theme.colorScheme.onPrimary, BlendMode.srcIn),
                                      ))
                                  : const SizedBox.shrink(),
                              Row(
                                children: [
                                  IconButton.filled(
                                      onPressed: () {
                                        addToFav();
                                      },
                                      icon: Icon(allFavs
                                              .where((element) =>
                                                  element["translation"] == _translatedText)
                                              .isEmpty
                                          ? Icons.star_border
                                          : Icons.star)),
                                  IconButton.filled(
                                      onPressed: () {
                                        copyText(_translatedText);
                                      },
                                      icon: const Icon(Icons.copy)),
                                  IconButton.filled(
                                      onPressed: () {
                                        share(_translatedText);
                                      },
                                      icon: const Icon(Icons.share))
                                ],
                              )
                            ]))
                      ],
                    ),
                  ))
            ],
          )),
        ));
  }

  Widget _buildDropdown() => DropdownButton(
        value: _selectedFromLang,
        icon: const Icon(Icons.arrow_downward),
        elevation: 16,
        style: const TextStyle(color: Colors.blue),
        underline: Container(
          height: 2,
          color: Colors.blue,
        ),
        onChanged: (script) {
          if (script != null) {
            setState(() {
              _selectedFromLang = script;
            });
          }
        },
        items: allLanguages.map<DropdownMenuItem>((script) {
          return DropdownMenuItem(
            value: script,
            child: Text(script["name"]!.isNotEmpty
                ? script["name"]![0].toUpperCase() + script["name"]!.substring(1)
                : script["name"]!),
          );
        }).toList(),
      );

  Widget _buildToDropdown() => DropdownButton(
        value: _selectedToLang,
        icon: const Icon(Icons.arrow_downward),
        elevation: 16,
        style: const TextStyle(color: Colors.blue),
        underline: Container(
          height: 2,
          color: Colors.blue,
        ),
        onChanged: (script) {
          if (script != null) {
            setState(() {
              _selectedToLang = script;
            });
          }
        },
        items: allLanguages.map<DropdownMenuItem>((script) {
          return DropdownMenuItem(
            value: script,
            child: Text(script["name"]!.isNotEmpty
                ? script["name"]![0].toUpperCase() + script["name"]!.substring(1)
                : script["name"]!),
          );
        }).toList(),
      );

// Widget _buildDropdown() => DropdownButton<TranslateLanguage>(
//       value: _selectedFromLang,
//       items: ()
//       onChanged: (int? langCode) {
//         if (langCode != null) {
//           print("$langCode Lang Code");
//           setState(() {
//             _textRecognizer = TextRecognizer(script: fromLanguages[langCode]["orig"]);
//             _selectedLanguage = fromLanguages[langCode]["lang"];
//           });
//         }
//       },
//     );
}
