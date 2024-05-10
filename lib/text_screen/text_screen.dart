import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class TextScreen extends StatefulWidget {
  const TextScreen({super.key});

  @override
  State<TextScreen> createState() => _TextScreenState();
}

class _TextScreenState extends State<TextScreen> {
  TextEditingController inputFieldController = TextEditingController();
  TranslateLanguage _selectedFromLang = TranslateLanguage.english;
  TranslateLanguage _selectedToLang = TranslateLanguage.spanish;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Container(
          child: Placeholder(),
        ),
      ),
      appBar: AppBar(
        title: const Text("Translator"),
      ),
      body: SafeArea(
          child: Column(
        children: [
          Card(
              margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(children: [
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
              ]))
        ],
      )),
    );
  }

  Widget _buildDropdown() => DropdownButton<TranslateLanguage>(
        value: _selectedFromLang,
        items: ()
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
}
