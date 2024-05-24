import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:translation_app/conversation_screen/pressable_badge.dart';
import 'package:translation_app/drawer/drawer.dart';

class Conversation extends StatefulWidget {
  const Conversation({super.key});

  @override
  State<Conversation> createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
  final TextEditingController chatTextController = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  TranslateLanguage firstMan = TranslateLanguage.english;
  TranslateLanguage secondMan = TranslateLanguage.spanish;
  int currentMan = 1;
  bool is1Listening = false;
  bool is2Listening = false;
  final FlutterTts _flutterTts = FlutterTts();

  final SpeechToText _speechToText = SpeechToText();
  final SpeechToText _speechToText1 = SpeechToText();

  @override
  void initState() {
    super.initState();

    _initSpeech();
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    await _speechToText.initialize();

    await _speechToText1.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    await _speechToText.listen(
        onResult: _onSpeechResult,
        listenOptions: SpeechListenOptions(partialResults: false, cancelOnError: true));

    setState(() {
      is1Listening = true;
    });
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();

    setState(() {
      is1Listening = false;
    });
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) async {
    if (result.recognizedWords == "") {
      setState(() {
        is1Listening = false;
      });
      return;
    }

    String text = result.recognizedWords;

    final onDeviceTranslator =
        OnDeviceTranslator(sourceLanguage: firstMan, targetLanguage: secondMan);

    final String translatedText = await onDeviceTranslator.translateText(text);

    setState(() {
      messages.add({
        "text": result.recognizedWords,
        "translatedText": translatedText,
        "originLang": firstMan,
        "targetLang": secondMan,
        "currentMan": "1"
      });

      is1Listening = false;
    });
  }

  /// Each time to start a speech recognition session
  void _startListening1() async {
    await _speechToText1.listen(
        onResult: _onSpeechResult1,
        listenOptions: SpeechListenOptions(partialResults: false, cancelOnError: true));

    setState(() {
      is2Listening = true;
    });
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening1() {
    _speechToText1.stop();

    setState(() {
      is2Listening = false;
    });
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult1(SpeechRecognitionResult result) async {
    if (result.recognizedWords == "") {
      setState(() {
        is1Listening = false;
      });
      return;
    }

    String text = result.recognizedWords;

    final onDeviceTranslator =
        OnDeviceTranslator(sourceLanguage: firstMan, targetLanguage: secondMan);

    final String translatedText = await onDeviceTranslator.translateText(text);

    setState(() {
      messages.add({
        "text": result.recognizedWords,
        "translatedText": translatedText,
        "currentMan": "2",
        "originLang": firstMan,
        "targetLang": secondMan,
      });

      is1Listening = false;
    });
  }

  void handleChange() async {
    String text = chatTextController.text;
    if (text == "") return;

    if (currentMan == 1) {
      final onDeviceTranslator =
          OnDeviceTranslator(sourceLanguage: firstMan, targetLanguage: secondMan);

      final String translatedText = await onDeviceTranslator.translateText(text);

      setState(() {
        messages.add({
          "text": text,
          "translatedText": translatedText,
          "currentMan": currentMan.toString(),
          "originLang": firstMan,
          "targetLang": secondMan,
        });
      });

      chatTextController.clear();
    } else if (currentMan == 2) {
      final onDeviceTranslator =
          OnDeviceTranslator(sourceLanguage: secondMan, targetLanguage: firstMan);

      final String translatedText = await onDeviceTranslator.translateText(text);

      setState(() {
        messages.add({
          "text": text,
          "translatedText": translatedText,
          "currentMan": currentMan.toString(),
          "originLang": firstMan,
          "targetLang": secondMan,
        });
      });

      chatTextController.clear();
    }

    return;
  }

  void _start_speaking(String text, TranslateLanguage? lang) {
    if (lang != null) {
      _flutterTts.setLanguage(lang.bcpCode);
    }
    _flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      drawer: const DrawerWidget(),
      appBar: AppBar(
        title: const Text("Translator"),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.star_rounded), iconSize: 30)],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(children: [
                    Align(
                        alignment: messages[index]["currentMan"] == '1'
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Row(
                            mainAxisAlignment: messages[index]["currentMan"] == '1'
                                ? MainAxisAlignment.start
                                : MainAxisAlignment.end,
                            children: [
                              messages[index]["currentMan"] == '1'
                                  ? IconButton.filled(
                                      onPressed: () => _start_speaking(
                                          messages[index]["translatedText"],
                                          messages[index]["targetLang"]),
                                      icon: SvgPicture.asset(
                                        "assets/images/speak.svg",
                                        colorFilter: ColorFilter.mode(
                                          theme.colorScheme.onPrimary,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                              Container(
                                  margin: const EdgeInsets.only(
                                      left: 8.0, right: 8, bottom: 12, top: 4),
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Column(children: [
                                    Text(
                                        messages[index]["translatedText"] != null
                                            ? messages[index]["text"]!
                                            : "",
                                        style: theme.textTheme.bodyLarge!.copyWith(
                                            color: theme.colorScheme.onPrimary.withOpacity(0.3))),
                                    // Divider(),
                                    // Spacer(),
                                    const SizedBox(height: 5),
                                    Text(
                                      messages[index]["translatedText"] != null
                                          ? messages[index]["translatedText"]!
                                          : "",
                                      style: theme.textTheme.bodyLarge!
                                          .copyWith(color: theme.colorScheme.onPrimary),
                                    ),
                                  ])),
                              messages[index]["currentMan"] == '2'
                                  ? IconButton.filled(
                                      onPressed: () => _start_speaking(
                                          messages[index]["translatedText"],
                                          messages[index]["originLang"]),
                                      icon: SvgPicture.asset(
                                        "assets/images/speak.svg",
                                        colorFilter: ColorFilter.mode(
                                          theme.colorScheme.onPrimary,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ])),
                    // Align(
                    //   alignment: Alignment.centerLeft,
                    //   child: Container(
                    //     margin: const EdgeInsets.all(8.0),
                    //     padding: const EdgeInsets.all(8.0),
                    //     decoration: BoxDecoration(
                    //       color: theme.colorScheme.primary,
                    //       borderRadius: BorderRadius.circular(8.0),
                    //     ),
                    //     child: Text(
                    //       messages[index]["translatedText"] != null
                    //           ? messages[index]["translatedText"]!
                    //           : "",
                    //       style: theme.textTheme.bodyLarge!
                    //           .copyWith(color: theme.colorScheme.onPrimary),
                    //     ),
                    //   ),
                    // )
                  ]);
                },
              ),
            ),
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        IconButton.filled(
                            style: ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(
                                    theme.colorScheme.primary.withAlpha(150))),
                            onPressed:
                                _speechToText.isNotListening ? _startListening : _stopListening,
                            icon: _speechToText.isListening
                                ? const SizedBox(
                                    width: 25, height: 25, child: CircularProgressIndicator())
                                : Icon(Icons.mic, color: theme.colorScheme.onBackground),
                            padding: const EdgeInsets.all(20)),
                        const Divider(),
                        _buildDropdown(),
                      ],
                    ),
                    Column(
                      children: [
                        IconButton.filled(
                            style: ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(
                                    theme.colorScheme.primary.withAlpha(150))),
                            onPressed:
                                _speechToText1.isNotListening ? _startListening1 : _stopListening1,
                            icon: _speechToText1.isListening
                                ? const SizedBox(
                                    width: 25, height: 25, child: CircularProgressIndicator())
                                : Icon(Icons.mic, color: theme.colorScheme.onBackground),
                            padding: const EdgeInsets.all(20)),
                        const Divider(),
                        _buildToDropdown(),
                      ],
                    ),
                  ],
                )),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.black.withAlpha(100)),
                          borderRadius: BorderRadius.circular(6)),
                      child: Row(children: [
                        SizedBox(
                            width: MediaQuery.of(context).size.width - 105,
                            child: TextField(
                              controller: chatTextController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                labelText: "Enter your message",
                              ),
                            )),
                        PressableBadge(
                            text: currentMan.toString(),
                            onPressed: () => currentMan == 1
                                ? setState(() => currentMan = 2)
                                : setState(() => currentMan = 1))
                      ])),
                  IconButton(onPressed: handleChange, icon: const Icon(Icons.send))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown() => DropdownButton<TranslateLanguage>(
        value: firstMan,
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
              firstMan = script;
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
        value: secondMan,
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
              secondMan = script;
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
}
