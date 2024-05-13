import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:provider/provider.dart';
import 'package:translation_app/providers/theme_provider.dart';
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

    final onDeviceTranslator =
        OnDeviceTranslator(sourceLanguage: _selectedFromLang, targetLanguage: _selectedToLang);

    final String translatedText = await onDeviceTranslator.translateText(text);

    setState(() {
      _translatedText = translatedText;
    });
  }

  void _start_speaking(text) {
    _flutterTts.setLanguage(_selectedToLang.name);
    _flutterTts.speak(text);
  }

  void _stop_speaking(text) {
    _flutterTts.stop();
  }

  share(String text) async {
    await Share.share(text);
  }

  copyText(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
        drawer: Drawer(
          child: SafeArea(
              child: ListView(children: [
            ListTile(
              title: Text(Provider.of<ThemeProvider>(context).isDarkMode
                  ? "Use light theme"
                  : "Use dark theme"),
              onTap: () => Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
            )
          ])),
        ),
        appBar: AppBar(
          title: const Text("Translator"),
        ),
        body: SingleChildScrollView(
          child: SafeArea(
              child: Column(
            children: [
              Card(
                  margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Column(children: [
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildDropdown(),
                              const Icon(Icons.chevron_right),
                              _buildToDropdown(),
                            ])),
                    const Divider(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        minLines: 8,
                        maxLines: 8,
                        controller: inputFieldController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          labelText: "Enter text here",
                        ),
                      ),
                    ),
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Row(
                          mainAxisAlignment: inputFieldController.text != ""
                              ? MainAxisAlignment.spaceBetween
                              : MainAxisAlignment.end,
                          children: [
                            inputFieldController.text != ""
                                ? IconButton.filled(
                                    onPressed: () => _start_speaking(inputFieldController.text),
                                    icon: SvgPicture.asset(
                                      "assets/images/speak.svg",
                                      colorFilter: ColorFilter.mode(
                                          theme.colorScheme.onPrimary, BlendMode.srcIn),
                                    ))
                                : const SizedBox.shrink(),
                            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                              IconButton.filled(
                                  onPressed: _speechToText.isNotListening
                                      ? _startListening
                                      : _stopListening,
                                  icon: _speechToText.isListening
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
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Container(
                      height: 250,
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        child: Text(_translatedText == "" ? "Translated text" : _translatedText),
                      ),
                    ),
                    Container(
                        margin: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          _translatedText != ""
                              ? IconButton.filled(
                                  onPressed: () => _start_speaking(_translatedText),
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
              )
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
        items: TranslateLanguage.values.map<DropdownMenuItem<TranslateLanguage>>((script) {
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
        items: TranslateLanguage.values.map<DropdownMenuItem<TranslateLanguage>>((script) {
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
