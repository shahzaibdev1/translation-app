import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import 'detector_view.dart';
import 'painters/text_detector_painter.dart';

const List<Map<String, dynamic>> fromLanguages = [
  {
    "lang": 0,
    "label": "English",
    "orig": TextRecognitionScript.latin,
    "target": TranslateLanguage.english
  },
  {
    "lang": 1,
    "label": "Spanish",
    "orig": TextRecognitionScript.latin,
    "target": TranslateLanguage.spanish
  },
  {
    "lang": 2,
    "label": "French",
    "orig": TextRecognitionScript.latin,
    "target": TranslateLanguage.french
  },
  {
    "lang": 3,
    "label": "Portuguese",
    "orig": TextRecognitionScript.latin,
    "target": TranslateLanguage.portuguese
  },
  {
    "lang": 4,
    "label": "Italian",
    "orig": TextRecognitionScript.latin,
    "target": TranslateLanguage.italian
  },
  {
    "lang": 5,
    "label": "Romanian",
    "orig": TextRecognitionScript.latin,
    "target": TranslateLanguage.romanian
  },
  {
    "lang": 6,
    "label": "German",
    "orig": TextRecognitionScript.latin,
    "target": TranslateLanguage.german
  },
  {
    "lang": 7,
    "label": "Polish",
    "orig": TextRecognitionScript.latin,
    "target": TranslateLanguage.polish
  },
  {
    "lang": 8,
    "label": "Croatian",
    "orig": TextRecognitionScript.latin,
    "target": TranslateLanguage.croatian
  },
  {
    "lang": 9,
    "label": "Czech",
    "orig": TextRecognitionScript.latin,
    "target": TranslateLanguage.czech
  },
  {
    "lang": 10,
    "label": "Japanese",
    "orig": TextRecognitionScript.japanese,
    "target": TranslateLanguage.japanese
  },
  {
    "lang": 11,
    "label": "Chinese",
    "orig": TextRecognitionScript.chinese,
    "target": TranslateLanguage.chinese
  },
  {
    "lang": 12,
    "label": "Korean",
    "orig": TextRecognitionScript.korean,
    "target": TranslateLanguage.korean
  },
  {
    "lang": 13,
    "label": "Hindi",
    "orig": TextRecognitionScript.devanagiri,
    "target": TranslateLanguage.hindi
  },
];

const List<Map<String, dynamic>> targetLanguages = [
  {"lang": 0, "label": "English", "target": TranslateLanguage.english},
  {"lang": 1, "label": "Spanish", "target": TranslateLanguage.spanish},
  {"lang": 2, "label": "French", "target": TranslateLanguage.french},
  {"lang": 3, "label": "Urdu", "target": TranslateLanguage.urdu},
  {"lang": 4, "label": "Arabic", "target": TranslateLanguage.arabic},
  {"lang": 5, "label": "Japanese", "target": TranslateLanguage.japanese},
  {"lang": 6, "label": "Chinese", "target": TranslateLanguage.chinese},
  {"lang": 7, "label": "Polish", "target": TranslateLanguage.polish},
  {"lang": 8, "label": "Croatian", "target": TranslateLanguage.croatian},
  {"lang": 9, "label": "Czech", "target": TranslateLanguage.czech},
  {"lang": 10, "label": "Japanese", "target": TranslateLanguage.japanese},
  {"lang": 11, "label": "Chinese", "target": TranslateLanguage.chinese},
  {"lang": 12, "label": "Korean", "target": TranslateLanguage.korean},
  {"lang": 13, "label": "Hindi", "target": TranslateLanguage.hindi},
  {"lang": 14, "label": "German", "target": TranslateLanguage.german},
];

class TextRecognizerView extends StatefulWidget {
  const TextRecognizerView({super.key});

  @override
  State<TextRecognizerView> createState() => _TextRecognizerViewState();
}

class _TextRecognizerViewState extends State<TextRecognizerView> {
  var _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  bool _canProcess = true;
  int _selectedLanguage = 0; // Initialize _selectedLanguage with default value
  int _selectedTargetLanguage = 0; // Initialize _selectedLanguage with default value
  TranslateLanguage toLanguage = TranslateLanguage.english;

  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.back;

  @override
  void dispose() async {
    _canProcess = false;
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Camera"),
      ),
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
            top: 20,
            left: 80,
            child: Row(
              children: [
                Row(children: [
                  Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: _buildDropdown(),
                      )),
                  const Icon(Icons.chevron_right),
                  Container(
                      // margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: _buildTargetDropdown(),
                      )),
                ]),
              ],
            )),
      ]),
    );
  }

  Widget _buildDropdown() => DropdownButton<int>(
        value: _selectedLanguage,
        items: fromLanguages.map((option) {
          // Cast the "orig" value to TextRecognitionScript
          return DropdownMenuItem<int>(
            value: option['lang'], // Use language code as value
            child: Text(option['label']),
          );
        }).toList(),
        onChanged: (int? langCode) {
          if (langCode != null) {
            print("$langCode Lang Code");
            setState(() {
              _textRecognizer = TextRecognizer(script: fromLanguages[langCode]["orig"]);
              _selectedLanguage = fromLanguages[langCode]["lang"];
            });
          }
        },
      );

  Widget _buildTargetDropdown() => DropdownButton<int>(
        value: _selectedTargetLanguage,
        items: targetLanguages.map((option) {
          // Cast the "orig" value to TextRecognitionScript
          return DropdownMenuItem<int>(
            value: option['lang'], // Use language code as value
            child: Text(option['label']),
          );
        }).toList(),
        onChanged: (int? langCode) {
          if (langCode != null) {
            print("$langCode Lang Code");
            setState(() {
              _selectedTargetLanguage = targetLanguages[langCode]["lang"];

              toLanguage = targetLanguages[langCode]["target"];
            });
          }
        },
      );

// Function to get TextRecognitionScript based on language code (modify as needed)
  TextRecognitionScript getScriptFromLanguage(int langCode) {
    switch (langCode) {
      case 'en':
        return TextRecognitionScript.latin;
      case 'sp':
        return TextRecognitionScript.latin;
      case 'fr': // Add French case if present in "fromLanguages"
        return TextRecognitionScript.latin; // Assuming French also uses latin script
      default:
        return TextRecognitionScript.latin; // Handle unknown languages (optional)
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

      final TranslateLanguage sourceLang = fromLanguages[_selectedLanguage]["target"];
      final TranslateLanguage targetLang = toLanguage;

      final onDeviceTranslator =
          OnDeviceTranslator(sourceLanguage: sourceLang, targetLanguage: targetLang);

      for (final textBlock in recognizedText.blocks) {
        final String text = await onDeviceTranslator.translateText(textBlock.text);
        lst.add({
          "boundingBox": textBlock.boundingBox,
          "cornerPoints": textBlock.cornerPoints,
          "lines": textBlock.lines,
          "text": text,
          "recognizedLanguages": textBlock.recognizedLanguages
        });
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
