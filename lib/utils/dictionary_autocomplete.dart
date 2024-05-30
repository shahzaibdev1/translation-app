import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:translation_app/db/db_helper.dart';
import 'package:translation_app/dictionary/result_screen.dart';

import 'dart:convert';

import 'package:translation_app/utils/utils.dart';

class DictionaryAutocomplete extends StatefulWidget {
  const DictionaryAutocomplete({super.key});

  @override
  DictionaryAutocompleteState createState() => DictionaryAutocompleteState();
}

class DictionaryAutocompleteState extends State<DictionaryAutocomplete> {
  final TextEditingController _controller = TextEditingController();
  final Debouncer _debouncer = Debouncer(milliseconds: 500); // Adjust debounce time here
  List<String> _suggestions = [];

  void _getSuggestions(String input) async {
    final response = await http.get(Uri.parse('https://api.datamuse.com/sug?s=$input&max=4'));

    if (response.statusCode == 200 && _controller.text.isNotEmpty) {
      List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _suggestions = data.map((e) => e['word'] as String).toList();
      });
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final text = _controller.text;
      _debouncer.run(() {
        _getSuggestions(text);
      });

      if (text == "") {
        _suggestions.clear();
        _controller.clear();
        return;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void openResult(String text) async {
    DateTime time = DateTime.now();

    Navigator.push(context, MaterialPageRoute(builder: (context) => ResultScreen(text: text)));
    final dbHelper = DatabaseHelper();

    dbHelper.insertData({
      "text": text,
      'time': DateFormat("dd MMM yyyy, hh:mm a").format(time),
    });

    _controller.clear();
    _suggestions.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(clipBehavior: Clip.none, children: [
      TextField(
        controller: _controller,
        decoration: InputDecoration(
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
          hintText: 'Search...',
          // labelText: 'Autocomplete',
          suffixIcon: _controller.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _controller.clear();
                      _suggestions.clear();
                    });
                  },
                ),
        ),
        onChanged: (value) {
          if (value.isEmpty) {
            setState(() {
              _suggestions.clear();
            });
          }
        },
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
        autocorrect: false,
        enableSuggestions: true,
        // maxLines: 1,
        // maxLength: 200,
      ),
      _suggestions.isNotEmpty
          ?
          // Positioned(
          //     width: MediaQuery.of(context).size.width * 0.9,
          //     height: 300,
          //     child:
          Container(
              margin: const EdgeInsets.only(top: 65),
              width: 200,
              height: 300,
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5.0),
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.grey.withOpacity(0.5),
                //     spreadRadius: 1,
                //     blurRadius: 3,
                //     offset: const Offset(0, 2), // changes position of shadow
                //   ),
                // ],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _suggestions[index];
                  return ListTile(
                    title: Text(suggestion),
                    onTap: () {
                      setState(() {
                        openResult(suggestion);
                      });
                    },
                  );
                },
              ),
            )
          // )
          : const SizedBox.shrink(),
    ]);
  }
}
