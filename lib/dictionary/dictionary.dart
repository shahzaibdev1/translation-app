import 'package:flutter/material.dart';
import 'package:translation_app/dictionary/word_of_the_day.dart';
import 'package:translation_app/drawer/drawer.dart';
import 'package:translation_app/utils/dictionary_autocomplete.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const DrawerWidget(),
        appBar: AppBar(
          title: const Text("Translator"),
        ),
        body: SafeArea(
            child: Center(
                child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
                    child: ListView(children: const [
                      DictionaryAutocomplete(),
                      WordOfTheDay(),
                    ])))));
  }
}
