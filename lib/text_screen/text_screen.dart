import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:translation_app/TextRecognizer.dart';
import 'package:translation_app/drawer/drawer.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:share_plus/share_plus.dart';

class TextScreen extends StatefulWidget {
  const TextScreen({super.key});

  @override
  State<TextScreen> createState() => _TextScreenState();
}

class _TextScreenState extends State<TextScreen> {
  TextEditingController inputFieldController = TextEditingController();
  TranslateLanguage _selectedFromLang = TranslateLanguage.english;
  TranslateLanguage _selectedToLang = TranslateLanguage.spanish;
  String _translatedText = "";
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  final FlutterTts _flutterTts = FlutterTts();
  bool isTextEmpty = true;
  TextEditingController fromTextController = TextEditingController();
  TextEditingController toTextController = TextEditingController();
  bool isFromTextEmpty = true;
  bool isToTextEmpty = true;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    print(result.recognizedWords);
    setState(() {
      inputFieldController.text = result.recognizedWords;
      _lastWords = result.recognizedWords;
    });
  }

  void translateText() async {
    String text = inputFieldController.text;

    final onDeviceTranslator = OnDeviceTranslator(
        sourceLanguage: _selectedFromLang, targetLanguage: _selectedToLang);

    final String translatedText = await onDeviceTranslator.translateText(text);

    setState(() {
      _translatedText = translatedText;
    });
  }

  void _startSpeaking(text) {
    _flutterTts.setLanguage(_selectedToLang.bcpCode);
    _flutterTts.speak(text);
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

  void _onFromSelected(TranslateLanguage lang, BuildContext ctx) {
    setState(() {
      _selectedFromLang = lang;
    });

    Navigator.pop(ctx);
  }

  void _onToSelected(TranslateLanguage lang, BuildContext ctx) {
    setState(() {
      _selectedToLang = lang;
    });

    Navigator.pop(ctx);
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
        builder: (ctx) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
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
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 20.0),
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
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30)),
                            labelText: "Search",
                          ))),
                  const ListTile(
                      title: Text("All Languages",
                          style: TextStyle(fontSize: 20))),
                  const Divider(indent: 5),
                  ...TranslateLanguage.values
                      .where((element) =>
                          element.name.contains(fromTextController.text))
                      .map((title) => ListTile(
                          title: TextButton(
                              style: const ButtonStyle(
                                  alignment: Alignment.centerLeft),
                              onPressed: () => _onFromSelected(title, ctx),
                              child: Text(title.name))))
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
        builder: (ctx) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
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
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 20.0),
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
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30)),
                            labelText: "Search",
                          ))),
                  const ListTile(
                      title: Text("All Languages",
                          style: TextStyle(fontSize: 20))),
                  const Divider(indent: 5),
                  ...TranslateLanguage.values
                      .where((element) =>
                          element.name.contains(toTextController.text))
                      .map((title) => ListTile(
                          title: TextButton(
                              style: const ButtonStyle(
                                  alignment: Alignment.centerLeft),
                              onPressed: () => _onToSelected(title, ctx),
                              child: Text(title.name))))
                      .toList()
                ]),
              );
            }));
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
                onPressed: () {},
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
                  margin:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
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
                                        shape: MaterialStatePropertyAll<
                                                RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10))),
                                        foregroundColor:
                                            const MaterialStatePropertyAll(
                                                Colors.black),
                                        backgroundColor:
                                            MaterialStatePropertyAll(
                                                Colors.blue.shade200)),
                                    onPressed: () => _showFrom(context),
                                    label: Text(_selectedFromLang.name),
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
                                        shape: MaterialStatePropertyAll<
                                                RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10))),
                                        foregroundColor:
                                            const MaterialStatePropertyAll(
                                                Colors.black),
                                        backgroundColor:
                                            MaterialStatePropertyAll(
                                                Colors.blue.shade200)),
                                    onPressed: () => _showTo(context),
                                    label: Text(_selectedToLang.name),
                                    icon: const Icon(Icons.arrow_drop_down)),
                              ),
                              // _buildToDropdown(),
                            ])),
                    const Divider(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
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
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Row(
                          mainAxisAlignment: inputFieldController.text != ""
                              ? MainAxisAlignment.spaceBetween
                              : MainAxisAlignment.end,
                          children: [
                            Visibility(
                              // Use Visibility for conditional visibility
                              visible: !isTextEmpty,
                              child: IconButton.filled(
                                onPressed: () =>
                                    _startSpeaking(inputFieldController.text),
                                icon: SvgPicture.asset(
                                  "assets/images/speak.svg",
                                  colorFilter: ColorFilter.mode(
                                    theme.colorScheme.onPrimary,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
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
                                      onPressed: _speechToText.isNotListening
                                          ? _startListening
                                          : _stopListening,
                                      icon: _speechToText.isListening
                                          ? SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                color:
                                                    theme.colorScheme.onPrimary,
                                              ))
                                          : const Icon(Icons.mic)),
                                  ElevatedButton(
                                    onPressed: () => translateText(),
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                theme.colorScheme.primary),
                                        foregroundColor:
                                            MaterialStateProperty.all<Color>(
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
                              _translatedText == ""
                                  ? "Translated text"
                                  : _translatedText,
                              style: TextStyle(
                                  fontSize: 30,
                                  color: theme.colorScheme.primary),
                            ),
                          ),
                        ),
                        Container(
                            margin: const EdgeInsets.only(
                                left: 10, right: 10, bottom: 5),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _translatedText != ""
                                      ? IconButton.filled(
                                          onPressed: () =>
                                              _startSpeaking(_translatedText),
                                          icon: SvgPicture.asset(
                                            "assets/images/speak.svg",
                                            colorFilter: ColorFilter.mode(
                                                theme.colorScheme.onPrimary,
                                                BlendMode.srcIn),
                                          ))
                                      : const SizedBox.shrink(),
                                  Row(
                                    children: [
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

  Widget _buildDropdown() => DropdownButton<TranslateLanguage>(
        value: _selectedFromLang,
        icon: const Icon(Icons.arrow_downward),
        elevation: 16,
        style: const TextStyle(color: Colors.blue),
        underline: Container(
          height: 2,
          color: Colors.blue,
        ),
        onChanged: (TranslateLanguage? script) {
          if (script != null) {
            setState(() {
              _selectedFromLang = script;
            });
          }
        },
        items: TranslateLanguage.values
            .map<DropdownMenuItem<TranslateLanguage>>((script) {
          return DropdownMenuItem<TranslateLanguage>(
            value: script,
            child: Text(script.name.isNotEmpty
                ? script.name[0].toUpperCase() + script.name.substring(1)
                : script.name),
          );
        }).toList(),
      );

  Widget _buildToDropdown() => DropdownButton<TranslateLanguage>(
        value: _selectedToLang,
        icon: const Icon(Icons.arrow_downward),
        elevation: 16,
        style: const TextStyle(color: Colors.blue),
        underline: Container(
          height: 2,
          color: Colors.blue,
        ),
        onChanged: (TranslateLanguage? script) {
          if (script != null) {
            setState(() {
              _selectedToLang = script;
            });
          }
        },
        items: TranslateLanguage.values
            .map<DropdownMenuItem<TranslateLanguage>>((script) {
          return DropdownMenuItem<TranslateLanguage>(
            value: script,
            child: Text(script.name.isNotEmpty
                ? script.name[0].toUpperCase() + script.name.substring(1)
                : script.name),
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
