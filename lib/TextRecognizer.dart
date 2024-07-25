import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;

import 'package:translation_app/utils/utils.dart';
// import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import 'detector_view.dart';
import 'painters/text_detector_painter.dart';

const List<Map<String, dynamic>> fromLanguages = [
  {
    "lang": 0,
    "label": "English",
    "orig": TextRecognitionScript.latin,
    "target": {"code": "auto", "name": "Detect"},
  },
  {
    "lang": 1,
    "label": "Spanish",
    "orig": TextRecognitionScript.latin,
    "target": {"code": "es", "name": "Spanish"},
  },
  {
    "lang": 2,
    "label": "French",
    "orig": TextRecognitionScript.latin,
    "target": {"code": "fr", "name": "French"},
  },
  {
    "lang": 3,
    "label": "Portuguese",
    "orig": TextRecognitionScript.latin,
    "target": {"code": "pt", "name": "Portuguese"},
  },
  {
    "lang": 4,
    "label": "Italian",
    "orig": TextRecognitionScript.latin,
    "target": {"code": "it", "name": "Italian"},
  },
  {
    "lang": 5,
    "label": "Romanian",
    "orig": TextRecognitionScript.latin,
    "target": {"code": "ro", "name": "Romanian"},
  },
  {
    "lang": 6,
    "label": "German",
    "orig": TextRecognitionScript.latin,
    "target": {"code": "de", "name": "German"},
  },
  {
    "lang": 7,
    "label": "Polish",
    "orig": TextRecognitionScript.latin,
    "target": {"code": "pl", "name": "Polish"},
  },
  {
    "lang": 8,
    "label": "Croatian",
    "orig": TextRecognitionScript.latin,
    "target": {"code": "hr", "name": "Croatian"},
  },
  {
    "lang": 9,
    "label": "Czech",
    "orig": TextRecognitionScript.latin,
    "target": {"code": "cs", "name": "Czech"},
  },
  {
    "lang": 10,
    "label": "Japanese",
    "orig": TextRecognitionScript.japanese,
    "target": {"code": "ja", "name": "Japanese"},
  },
  {
    "lang": 11,
    "label": "Chinese",
    "orig": TextRecognitionScript.chinese,
    "target": {"code": "zh", "name": "Chinese"},
  },
  {
    "lang": 12,
    "label": "Korean",
    "orig": TextRecognitionScript.korean,
    "target": {"code": "ko", "name": "Korean"},
  },
  {
    "lang": 13,
    "label": "Hindi",
    "orig": TextRecognitionScript.devanagiri,
    "target": {"code": "hi", "name": "Hindi"},
  },
];

// const List<Map<String, dynamic>> targetLanguages = [
//   {"lang": 0, "label": "English", "target": TranslateLanguage.english},
//   {"lang": 1, "label": "Spanish", "target": TranslateLanguage.spanish},
//   {"lang": 2, "label": "French", "target": TranslateLanguage.french},
//   {"lang": 3, "label": "Urdu", "target": TranslateLanguage.urdu},
//   {"lang": 4, "label": "Arabic", "target": TranslateLanguage.arabic},
//   {"lang": 5, "label": "Japanese", "target": TranslateLanguage.japanese},
//   {"lang": 6, "label": "Chinese", "target": TranslateLanguage.chinese},
//   {"lang": 7, "label": "Polish", "target": TranslateLanguage.polish},
//   {"lang": 8, "label": "Croatian", "target": TranslateLanguage.croatian},
//   {"lang": 9, "label": "Czech", "target": TranslateLanguage.czech},
//   {"lang": 10, "label": "Japanese", "target": TranslateLanguage.japanese},
//   {"lang": 11, "label": "Chinese", "target": TranslateLanguage.chinese},
//   {"lang": 12, "label": "Korean", "target": TranslateLanguage.korean},
//   {"lang": 13, "label": "Hindi", "target": TranslateLanguage.hindi},
//   {"lang": 14, "label": "German", "target": TranslateLanguage.german},
// ];

class TextRecognizerView extends StatefulWidget {
  const TextRecognizerView({super.key});

  @override
  State<TextRecognizerView> createState() => _TextRecognizerViewState();
}

class _TextRecognizerViewState extends State<TextRecognizerView> {
  var _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  bool _canProcess = true;
  int _selectedLanguage = 0; // Initialize _selectedLanguage with default value
  // int _selectedTargetLanguage = 1; // Initialize _selectedLanguage with default value
  Map<String, String> toLanguage = {"code": "es", "name": "Spanish"};
  bool isTextEmpty = true;
  TextEditingController fromTextController = TextEditingController();
  TextEditingController toTextController = TextEditingController();
  bool isFromTextEmpty = true;
  bool isToTextEmpty = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.back;

  TextEditingController inputFieldController = TextEditingController();
  Map<String, String> _selectedFromLang = {"code": "auto", "name": "Detect Language"};
  Map<String, String> _selectedToLang = {"code": "es", "name": "Spanish"};
  // String _translatedText = "";

  @override
  void dispose() async {
    _canProcess = false;
    _textRecognizer.close();
    super.dispose();
  }

  // _showFrom(BuildContext ctx) {
  //   showModalBottomSheet(
  //       elevation: 10,
  //       backgroundColor: Colors.amber,
  //       context: ctx,
  //       builder: (ctx) => Container(
  //             width: 300,
  //             height: 250,
  //             color: Colors.white54,
  //             alignment: Alignment.center,
  //             child: const Text('Breathe in... Breathe out...'),
  //           ));
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        DetectorView(
          title: 'Text Detector',
          recognizer: _textRecognizer,
          fromLang: fromLanguages[_selectedLanguage]["target"],
          targetLang: toLanguage,
          customPaint: _customPaint,
          text: _text,
          onImage: _processImage,
          initialCameraLensDirection: _cameraLensDirection,
          onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
        ),
        Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Center(
                child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.87,
                    child: Row(
                      children: [
                        Row(children: [
                          Container(
                              decoration: BoxDecoration(
                                // color: Colors.black54,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child:
                                  // Padding(padding: const EdgeInsets.all(4.0), child: _buildDropdown()
                                  SizedBox(
                                width: MediaQuery.of(context).size.width * 0.4,
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
                                    onPressed: () => _showFromBottom(context),
                                    label: Text(_selectedFromLang["name"]!,
                                        overflow: TextOverflow.ellipsis),
                                    icon: const Icon(Icons.arrow_drop_down)),
                              )),

                          // )

                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.05,
                              child: const Icon(Icons.chevron_right)),
                          Container(
                              // margin: const EdgeInsets.only(left: 8),
                              decoration: BoxDecoration(
                                // color: Colors.black54,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.4,
                                    child: FilledButton.icon(
                                        style: ButtonStyle(
                                            shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10))),
                                            foregroundColor:
                                                const MaterialStatePropertyAll(Colors.black),
                                            backgroundColor:
                                                MaterialStatePropertyAll(Colors.blue.shade200)),
                                        onPressed: () => _showTo(context),
                                        label: Text(_selectedToLang["name"]!,
                                            overflow: TextOverflow.ellipsis),
                                        icon: const Icon(Icons.arrow_drop_down)),
                                  ))),
                        ]),
                      ],
                    )))),
      ]),
    );
  }

  _showFromBottom(BuildContext context) {
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
                          onPressed: () => _onToSelected("auto", 0, ctx),
                          child: const Text("Detect Language"))),
                  ...fromLanguages
                      .where((element) => element["label"]
                          .toLowerCase()
                          .startsWith(fromTextController.text.toLowerCase()))
                      .map((title) => ListTile(
                          title: TextButton(
                              style: const ButtonStyle(alignment: Alignment.centerLeft),
                              onPressed: () => _onFromSelected(title["target"], title["lang"], ctx),
                              child: Text(title["label"]))))
                      .toList()
                ]),
              );
            }));
  }

  void _onFromSelected(lang, int idx, BuildContext ctx) {
    // int idx = fromLanguages.indexWhere((element) => element["target"] == lang);
    setState(() {
      _selectedFromLang = lang;
      _textRecognizer = TextRecognizer(script: fromLanguages[idx]["orig"]);
      _selectedLanguage = idx;
    });

    Navigator.pop(ctx);
  }

  void _onToSelected(lang, int idx, BuildContext ctx) {
    setState(() {
      _selectedToLang = lang;
      // _selectedLanguage = idx;

      toLanguage = lang;
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
                      .toList()
                      .asMap()
                      .entries
                      .map((title) => ListTile(
                          title: TextButton(
                              style: const ButtonStyle(alignment: Alignment.centerLeft),
                              onPressed: () => _onToSelected(title.value, title.key, ctx),
                              child: Text(title.value["name"]))))
                      .toList()
                ]),
              );
            }));
  }

  // Widget _buildDropdown() => DropdownButton<int>(
  //       value: _selectedLanguage,
  //       items: fromLanguages.map((option) {
  //         // Cast the "orig" value to TextRecognitionScript
  //         return DropdownMenuItem<int>(
  //           value: option['lang'], // Use language code as value
  //           child: Text(option['label']),
  //         );
  //       }).toList(),
  //       onChanged: (int? langCode) {
  //         if (langCode != null) {
  //           setState(() {
  //             _textRecognizer = TextRecognizer(script: fromLanguages[langCode]["orig"]);
  //             _selectedLanguage = fromLanguages[langCode]["lang"];
  //           });
  //         }
  //       },
  //     );

  // Widget _buildTargetDropdown() => DropdownButton<int>(
  //       value: _selectedLanguage,
  //       items: targetLanguages.map((option) {
  //         // Cast the "orig" value to TextRecognitionScript
  //         return DropdownMenuItem<int>(
  //           value: option['lang'], // Use language code as value
  //           child: Text(option['label']),
  //         );
  //       }).toList(),
  //       onChanged: (int? langCode) {
  //         if (langCode != null) {
  //           setState(() {
  //             // _selectedTargetLanguage = targetLanguages[langCode]["lang"];

  //             toLanguage = targetLanguages[langCode]["target"];
  //           });
  //         }
  //       },
  //     );

  Future<dynamic> fetchData(String text, String? origin) async {
    origin ??= "translate.plausibility.cloud";

    final response = await http.get(Uri.parse(
        'https://$origin/api/v1/${_selectedFromLang["code"]}/${_selectedToLang["code"]}/${text}'));

    if (response.statusCode == 200 && text.isNotEmpty) {
      return jsonDecode(response.body);
    } else {
      switch (origin) {
        case "translate.plausibility.cloud":
          print("translate.plausibility.cloud not working, trying lingva.ml");

          origin = "lingva.ml";
          break;
        case "translate.plausibility.cloud":
          print("translate.plausibility.cloud not working, trying lingva.lunar.icu");

          origin = "lingva.lunar.icu";
          break;
        case "lingva.lunar.icu":
          print("lingva.lunar.icu not working, trying translate.dr460nf1r3.org");

          origin = "translate.dr460nf1r3.org";
          break;
        case "translate.dr460nf1r3.org":
          print("translate.dr460nf1r3.org not working, trying lingva.garudalinux.org");

          origin = "lingva.garudalinux.org";
          break;
        default:
          throw Exception('Failed to load translation');
      }

      return await fetchData(text, origin);
    }
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });

    final recognizedText = await _textRecognizer.processImage(inputImage);
    if (inputImage.metadata?.size != null && inputImage.metadata?.rotation != null) {
      List<Map<String, dynamic>> lst = [];

      // final onDeviceTranslator =
      //     OnDeviceTranslator(sourceLanguage: sourceLang, targetLanguage: targetLang);

      // for (final textBlock in recognizedText.blocks) {
      //   // final String text = await onDeviceTranslator.translateText(textBlock.text);
      //   var translatedObj = await fetchData(textBlock.text, null);
      //   final String text = translatedObj["translation"];
      //   print("object: $text");

      //   lst.add({
      //     "boundingBox": textBlock.boundingBox,
      //     "cornerPoints": textBlock.cornerPoints,
      //     "lines": textBlock.lines,
      //     "text": text,
      //     "recognizedLanguages": textBlock.recognizedLanguages
      //   });
      // }

      List<Future<Map<String, dynamic>>> futures = [];

      Future<Map<String, dynamic>> fetchAsyncData(String text, TextBlock textBlock) async {
        // var translatedObj = await onDeviceTranslator.translateText(text);
        var translatedObj = await fetchData(text, null);
        if (translatedObj != null && translatedObj["translation"] != null) {
          var translatedText = translatedObj["translation"];

          return {
            "boundingBox": textBlock.boundingBox,
            "cornerPoints": textBlock.cornerPoints,
            "lines": textBlock.lines,
            "text": text,
            "translation": translatedText,
            "recognizedLanguages": textBlock.recognizedLanguages
          };
        } else {
          return {};
        }
      }

      for (final textBlock in recognizedText.blocks) {
        // Add each fetchData call to the futures list
        futures.add(fetchAsyncData(textBlock.text, textBlock));
      }

      // Wait for all the futures to complete
      List<Map<String, dynamic>?> results = await Future.wait(futures);

      // Process the results
      for (var result in results) {
        if (result != null && result["translation"] != null) {
          var translatedText = result["translation"];
          lst.add({
            "boundingBox": result["boundingBox"],
            "cornerPoints": result["cornerPoints"],
            "lines": result["lines"],
            "text": translatedText,
            "recognizedLanguages": result["recognizedLanguages"]
          });
        }
      }

      final painter = TextRecognizerPainter(
        lst,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
      );
      _customPaint = CustomPaint(painter: painter);
    } else {
      _text = 'Recognized text:\n\n${recognizedText.text}';
      // TODO: set _customPaint to draw boundingRect on top of image
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
