import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
// import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:translation_app/conversation_screen/pressable_badge.dart';
import 'package:translation_app/db/db_helper.dart';
import 'package:translation_app/drawer/drawer.dart';
import 'package:translation_app/providers/speech_to_text.dart';
import 'package:translation_app/utils/utils.dart';

class Conversation extends StatefulWidget {
  const Conversation({super.key});

  @override
  State<Conversation> createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
  final TextEditingController chatTextController = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  Map<String, String> firstMan = {"code": "auto", "name": "Detect Language"};
  Map<String, String> secondMan = {"code": "es", "name": "Spanish"};
  int currentMan = 1;
  // bool is1Listening = false;
  // bool is2Listening = false;
  final FlutterTts _flutterTts = FlutterTts();

  final SpeechToText _speechToText = SpeechToText();
  final SpeechToText _speechToText1 = SpeechToText();

  TextEditingController fromTextController = TextEditingController();
  TextEditingController toTextController = TextEditingController();
  bool isFromTextEmpty = true;
  bool isToTextEmpty = true;

  // final _modelManager = OnDeviceTranslatorModelManager();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    // _initSpeech();
  }

  /// This has to happen only once per app
  // void _initSpeech() async {
  //   await _speechToText.initialize(onStatus: (status) {
  //     print("object 1listening ${status}");
  //     if (status == "listening") {
  //       setState(() {
  //         is1Listening = true;
  //       });
  //     } else if (status == "notListening") {
  //       setState(() {
  //         is1Listening = false;
  //       });
  //     }
  //   }, onError: (errorNotification) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(errorNotification.errorMsg ?? "Something went wrong"),
  //       ),
  //     );
  //   });
  //
  //   await _speechToText1.initialize(onStatus: (status) {
  //     print("object 2listening ${status}");
  //     if (status == "listening") {
  //       setState(() {
  //         is2Listening = true;
  //       });
  //     } else if (status == "notListening") {
  //       setState(() {
  //         is2Listening = false;
  //       });
  //     }
  //   }, onError: (errorNotification) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(errorNotification.errorMsg ?? "Something went wrong"),
  //       ),
  //     );
  //   });
  //   setState(() {});
  // }

  /// Each time to start a speech recognition session
  void _startListening() {
    Provider.of<SpeachToTextProvider>(context, listen: false)
        .startListening(onResult: _onSpeechResult, idx: 2);
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() {
    Provider.of<SpeachToTextProvider>(context, listen: false).stopListening();
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) async {
    if (result.recognizedWords == "") {
      // setState(() {
      //   is1Listening = false;
      // });
      return;
    }

    String text = result.recognizedWords;

    // final onDeviceTranslator =
    //     OnDeviceTranslator(sourceLanguage: firstMan, targetLanguage: secondMan);

    // final String translatedText = await onDeviceTranslator.translateText(text);
    var translatedObj = await fetchData(text, 1);

    if (translatedObj["translation"] != null) {
      var translatedText = translatedObj["translation"];

      setState(() {
        messages.add({
          "text": result.recognizedWords,
          "translatedText": translatedText,
          "originLang": firstMan,
          "targetLang": secondMan,
          "currentMan": "1"
        });

        // is1Listening = false;
      });
    }
  }

  Future<dynamic> fetchData(String text, int? man) async {
    String fromLang =
        firstMan["code"] == "auto" || firstMan["code"] == null ? "en" : firstMan["code"]!;

    if (man == 2) {
      final response = await http
          .get(Uri.parse('https://lingva.ml/api/v1/${secondMan["code"]}/$fromLang/$text'));

      if (response.statusCode == 200 && text.isNotEmpty) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load suggestions');
      }
    } else if (man == 1) {
      final response = await http.get(
          Uri.parse('https://lingva.ml/api/v1/${firstMan["code"]}/${secondMan["code"]}/$text'));

      if (response.statusCode == 200 && text.isNotEmpty) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load suggestions');
      }
    } else {
      if (currentMan == 1) {
        final response = await http.get(
            Uri.parse('https://lingva.ml/api/v1/${firstMan["code"]}/${secondMan["code"]}/$text'));

        if (response.statusCode == 200 && text.isNotEmpty) {
          return jsonDecode(response.body);
        } else {
          throw Exception('Failed to load suggestions');
        }
      } else {
        if (currentMan == 1) {
          final response = await http.get(
              Uri.parse('https://lingva.ml/api/v1/${firstMan["code"]}/${secondMan["code"]}/$text'));

          if (response.statusCode == 200 && text.isNotEmpty) {
            return jsonDecode(response.body);
          } else {
            throw Exception('Failed to load suggestions');
          }
        } else {
          final response = await http
              .get(Uri.parse('https://lingva.ml/api/v1/${secondMan["code"]}/$fromLang/$text'));

          if (response.statusCode == 200 && text.isNotEmpty) {
            return jsonDecode(response.body);
          } else {
            print(
                "${response.body} ${'https://lingva.ml/api/v1/${secondMan["code"]}/$fromLang/$text'}");
            throw Exception('Failed to load suggestions');
          }
        }
      }
    }
  }

  /// Each time to start a speech recognition session
  void _startListening1() async {
    Provider.of<SpeachToTextProvider>(context, listen: false)
        .startListening(onResult: _onSpeechResult1, idx: 3);

    // setState(() {
    //   is2Listening = true;
    // });
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening1() {
    Provider.of<SpeachToTextProvider>(context, listen: false).stopListening();
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult1(SpeechRecognitionResult result) async {
    if (result.recognizedWords == "") {
      // setState(() {
      //   is1Listening = false;
      // });
      return;
    }

    String text = result.recognizedWords;

    // final onDeviceTranslator =
    //     OnDeviceTranslator(sourceLanguage: firstMan, targetLanguage: secondMan);

    // final String translatedText = await onDeviceTranslator.translateText(text);
    var translatedObj = await fetchData(text, 2);

    if (translatedObj["translation"] != null) {
      var translatedText = translatedObj["translation"];

      setState(() {
        messages.add({
          "text": result.recognizedWords,
          "translatedText": translatedText,
          "currentMan": "2",
          "originLang": firstMan,
          "targetLang": secondMan,
        });

        // is1Listening = false;
      });
    }
  }

  void handleChange() async {
    setState(() {
      isLoading = true;
    });

    final ThemeData theme = Theme.of(context);
    try {
      String text = chatTextController.text;

      if (text == "") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: theme.colorScheme.errorContainer,
            content: Text('Text is empty!', style: TextStyle(color: theme.colorScheme.error)),
            duration: const Duration(seconds: 3),
          ),
        );
      }

      if (currentMan == 1) {
        // final onDeviceTranslator =
        //     OnDeviceTranslator(sourceLanguage: firstMan, targetLanguage: secondMan);

        // final String translatedText = await onDeviceTranslator.translateText(text);
        var translatedObj = await fetchData(text, 0);

        if (translatedObj["translation"] != null) {
          var translatedText = translatedObj["translation"];

          setState(() {
            messages.add({
              "text": text,
              "translatedText": translatedText,
              "currentMan": currentMan.toString(),
              "originLang": firstMan,
              "targetLang": secondMan,
            });
          });
          addToHistory(text, translatedText);
        }
        chatTextController.clear();
      } else if (currentMan == 2) {
        // final onDeviceTranslator =
        //     OnDeviceTranslator(sourceLanguage: secondMan, targetLanguage: firstMan);

        // final String translatedText = await onDeviceTranslator.translateText(text);
        var translatedObj = await fetchData(text, 0);

        if (translatedObj["translation"] != null) {
          var translatedText = translatedObj["translation"];

          setState(() {
            messages.add({
              "text": text,
              "translatedText": translatedText,
              "currentMan": currentMan.toString(),
              "originLang": firstMan,
              "targetLang": secondMan,
            });
          });
          addToHistory(text, translatedText);

          chatTextController.clear();
        }
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: theme.colorScheme.errorContainer,
          content: Text('Something went wrong! Please check your internet connection.',
              style: TextStyle(color: theme.colorScheme.error)),
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void addToHistory(
    text,
    translatedText,
  ) async {
    // _translatedText
    // inputFieldController.text
    DateTime time = DateTime.now();
    final dbHelper = HistoryDbHelper();

    dbHelper.insertData({
      "text": text,
      "translation": translatedText,
      'time': DateFormat("dd MMM yyyy, hh:mm a").format(time),
      "type": "Conversation"
    });
  }

  void _start_speaking(String text, lang) {
    if (lang != null) {
      _flutterTts.setLanguage(lang["code"] == "auto" ? "en" : lang["code"]);
    }
    _flutterTts.speak(text);
  }

  void _onFromSelected(lang, BuildContext ctx) {
    try {
      // _modelManager.isModelDownloaded(lang["code"]).then((value) async {
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

      //     await _modelManager.downloadModel(lang["code"]);
      //     setState(() {
      //       isDownloading = false;
      //     });
      //     snackbar.close();
      //   }
      // });

      setState(() {
        firstMan = lang;
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
      // _modelManager.isModelDownloaded(lang["code"]).then((value) async {
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

      //     await _modelManager.downloadModel(lang["code"]);
      //     setState(() {
      //       isDownloading = false;
      //     });
      //     snackbar.close();
      //   }
      // });

      setState(() {
        secondMan = lang;
      });

      Navigator.pop(ctx);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong!')),
      );
    }
  }

  handleFromChange(String value) {
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
                          onChanged: handleFromChange,
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

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
        drawer: const DrawerWidget(),
        appBar: AppBar(
          title: const Text("Translator"),
          // actions: [
          //   IconButton(onPressed: () {}, icon: const Icon(Icons.star_rounded), iconSize: 30)
          // ],
        ),
        body: SafeArea(
            child: Theme(
          data: theme.copyWith(
              textSelectionTheme: TextSelectionThemeData(
                  selectionColor: Colors.cyan[800], selectionHandleColor: Colors.cyan[800])),
          child: Column(
            children: [
              Expanded(
                child: messages.isEmpty
                    ? MediaQuery.of(context).viewInsets.bottom == 0
                        ? Center(
                            child: SizedBox(
                                height: MediaQuery.of(context).size.height * 0.4,
                                width: MediaQuery.of(context).size.width * 0.9,
                                child: Column(children: [
                                  Center(
                                      child: Image.asset("assets/images/empty_conversation.png",
                                          height: MediaQuery.of(context).size.height * 0.2,
                                          fit: BoxFit.contain)),
                                  const SizedBox(height: 20),
                                  const Text("Conversation Translator",
                                      style: TextStyle(fontSize: 20, fontFamily: "Gordita Bold")),
                                  const Text("Tap the mic and speak or write in the text field")
                                ])))
                        : const SizedBox.shrink()
                    : ListView.builder(
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
                                          constraints: BoxConstraints(
                                              maxWidth: MediaQuery.of(context).size.width * 0.8),
                                          padding: const EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primary,
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                          child: Column(children: [
                                            SelectableText(
                                                messages[index]["translatedText"] != null
                                                    ? messages[index]["text"]!
                                                    : "",
                                                style: theme.textTheme.bodyLarge!.copyWith(
                                                    color: theme.colorScheme.onPrimary
                                                        .withOpacity(0.3))),
                                            // Divider(),
                                            // Spacer(),
                                            const SizedBox(height: 5),
                                            SelectableText(
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
                              onPressed: Provider.of<SpeachToTextProvider>(context).status ==
                                          "listening" &&
                                      Provider.of<SpeachToTextProvider>(context).idx == 2
                                  ? _stopListening
                                  : _startListening,
                              icon: Provider.of<SpeachToTextProvider>(context).status ==
                                          "listening" &&
                                      Provider.of<SpeachToTextProvider>(context).idx == 2
                                  ? const SizedBox(
                                      width: 25, height: 25, child: CircularProgressIndicator())
                                  : Icon(Icons.mic, color: theme.colorScheme.onBackground),
                              padding: const EdgeInsets.all(20)),
                          const Divider(),
                          SizedBox(
                            // width: MediaQuery.of(context).size.width * 0.33,
                            child: FilledButton.icon(
                                style: ButtonStyle(
                                    shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10))),
                                    foregroundColor: const MaterialStatePropertyAll(Colors.black),
                                    backgroundColor:
                                        MaterialStatePropertyAll(Colors.blue.shade200)),
                                onPressed: () => _showFrom(context),
                                label: Text(firstMan["name"]!),
                                icon: const Icon(Icons.arrow_drop_down)),
                          ),
                        ],
                      ),
                      // IconButton(onPressed: onPressed, icon: Icon(Icons)),
                      Column(
                        children: [
                          IconButton.filled(
                              style: ButtonStyle(
                                  backgroundColor: MaterialStatePropertyAll(
                                      theme.colorScheme.primary.withAlpha(150))),
                              onPressed: Provider.of<SpeachToTextProvider>(context).status ==
                                          "listening" &&
                                      Provider.of<SpeachToTextProvider>(context).idx == 3
                                  ? _stopListening1
                                  : _startListening1,
                              icon: Provider.of<SpeachToTextProvider>(context).status ==
                                          "listening" &&
                                      Provider.of<SpeachToTextProvider>(context).idx == 3
                                  ? const SizedBox(
                                      width: 25, height: 25, child: CircularProgressIndicator())
                                  : Icon(Icons.mic, color: theme.colorScheme.onBackground),
                              padding: const EdgeInsets.all(20)),
                          const Divider(),
                          SizedBox(
                            // width: MediaQuery.of(context).size.width * 0.33,
                            child: FilledButton.icon(
                                style: ButtonStyle(
                                    shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10))),
                                    foregroundColor: const MaterialStatePropertyAll(Colors.black),
                                    backgroundColor:
                                        MaterialStatePropertyAll(Colors.blue.shade200)),
                                onPressed: () => _showTo(context),
                                label: Text(secondMan["name"]!),
                                icon: const Icon(Icons.arrow_drop_down)),
                          ),
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
                    IconButton(
                        onPressed: isLoading ? null : handleChange,
                        icon: isLoading
                            ? const SizedBox(
                                width: 25,
                                height: 25,
                                child: CircularProgressIndicator(strokeWidth: 3))
                            : const Icon(Icons.send))
                  ],
                ),
              ),
            ],
          ),
        )));
  }

  Widget _buildDropdown() => DropdownButton(
        value: firstMan,
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
              firstMan = script;
            });
          }
        },
        items: allLanguages.map<DropdownMenuItem>((script) {
          return DropdownMenuItem(
            value: script,
            child: Text(script["name"].isNotEmpty
                ? script["name"][0].toUpperCase() + script["name"].substring(1)
                : script["name"]),
          );
        }).toList(),
      );

  Widget _buildToDropdown() => DropdownButton(
        value: secondMan,
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
              secondMan = script;
            });
          }
        },
        items: allLanguages.map<DropdownMenuItem>((script) {
          return DropdownMenuItem(
            value: script,
            child: Text(script["name"].isNotEmpty
                ? script["name"][0].toUpperCase() + script["name"].substring(1)
                : script["name"]),
          );
        }).toList(),
      );
}
