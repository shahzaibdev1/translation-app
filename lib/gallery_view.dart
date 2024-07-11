import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;
// import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:image_picker/image_picker.dart';

import 'utils/utils.dart';

class GalleryView extends StatefulWidget {
  const GalleryView(
      {Key? key,
      required this.title,
      required this.recognizer,
      required this.fromLang,
      required this.targetLang,
      this.text,
      required this.onImage,
      required this.onDetectorViewModeChanged})
      : super(key: key);

  final TextRecognizer recognizer;
  final Map<String, String> fromLang;
  final Map<String, String> targetLang;
  final String title;
  final String? text;
  final Function(InputImage inputImage) onImage;
  final Function()? onDetectorViewModeChanged;

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  File? _image;
  ImagePicker? _imagePicker;
  String text = "";

  @override
  void didUpdateWidget(GalleryView oldWidget) {
    super.didUpdateWidget(oldWidget);

    onUpdateWidget() async {
      if ((widget.text != oldWidget.text ||
              widget.fromLang != oldWidget.fromLang ||
              widget.targetLang != oldWidget.targetLang) &&
          widget.text != null) {
        // Run your function here
        if (widget.text != null) {
          final Map<String, String> sourceLang = widget.fromLang;
          final Map<String, String> targetLang = widget.targetLang;

          // final onDeviceTranslator =
          //     OnDeviceTranslator(sourceLanguage: sourceLang, targetLanguage: targetLang);

          // var translatedText = await onDeviceTranslator
          //     .translateText(widget.text!.replaceFirst('Recognized text:', '').trim());
          var translatedObj = await fetchData(sourceLang, targetLang, widget.text!, null);
          if (translatedObj && translatedObj["translation"] != null) {
            var translatedText = translatedObj["translation"];

            setState(() {
              text = translatedText;
            });
          }
        }
      }
    }

    onUpdateWidget();
  }

  Future<dynamic> fetchData(selectedFromLang, selectedToLang, String text, String? origin) async {
    origin ??= "translate.plausibility.cloud";

    final response = await http.get(Uri.parse(
        'https://$origin/api/v1/${selectedFromLang["code"]}/${selectedToLang["code"]}/$text'));

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

      return await fetchData(selectedFromLang, selectedToLang, text, origin);
    }
  }

  @override
  void initState() {
    super.initState();

    _imagePicker = ImagePicker();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          leading: IconButton(
            iconSize: 30,
            icon: Icon(
              Platform.isIOS ? Icons.arrow_back_ios_new_outlined : Icons.arrow_circle_left_outlined,
            ),
            onPressed: widget.onDetectorViewModeChanged,
          ),
        ),
        body: _galleryBody());
  }

  Widget _galleryBody() {
    return ListView(shrinkWrap: true, children: [
      _image != null
          ? Container(
              margin: const EdgeInsets.only(top: 100),
              height: 400,
              width: 400,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.file(_image!),
                ],
              ),
            )
          : Container(
              margin: const EdgeInsets.only(top: 80),
              child: const Icon(
                Icons.image,
                size: 200,
              )),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          child: const Text('From Gallery'),
          onPressed: () => _getImage(ImageSource.gallery),
        ),
      ),
      if (_image != null)
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Translated Text:\n\n$text'),
        ),
    ]);
  }

  Future _getImage(ImageSource source) async {
    setState(() {
      _image = null;
    });

    final pickedFile = await _imagePicker?.pickImage(source: source);
    if (pickedFile != null) {
      _processFile(pickedFile.path);
    }
  }

  Future _getImageAsset() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    final assets = manifestMap.keys
        .where((String key) => key.contains('images/'))
        .where((String key) =>
            key.contains('.jpg') ||
            key.contains('.jpeg') ||
            key.contains('.png') ||
            key.contains('.webp'))
        .toList();

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select image',
                    style: TextStyle(fontSize: 20),
                  ),
                  ConstrainedBox(
                    constraints:
                        BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          for (final path in assets)
                            GestureDetector(
                              onTap: () async {
                                Navigator.of(context).pop();
                                _processFile(await getAssetPath(path));
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(path),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                ],
              ),
            ),
          );
        });
  }

  Future _processFile(String path) async {
    setState(() {
      _image = File(path);
    });
    final inputImage = InputImage.fromFilePath(path);
    widget.onImage(inputImage);
  }
}
