import 'package:flutter/material.dart';
import 'package:translation_app/db/db_helper.dart';
import 'package:translation_app/dictionary/result_screen.dart';

class WordOfTheDay extends StatefulWidget {
  const WordOfTheDay({super.key});

  @override
  State<WordOfTheDay> createState() => _WordOfTheDayState();
}

class _WordOfTheDayState extends State<WordOfTheDay> {
  List<Map<String, dynamic>> _listOfWordsInHistory = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    final dbHelper = DatabaseHelper();
    final List<Map<String, dynamic>> retrievedData = await dbHelper.getData();
    setState(() {
      _listOfWordsInHistory = retrievedData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: const Text("Word of the day",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
          const Divider(),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const ResultScreen(text: "GADFLY")));
              },
              style: ButtonStyle(
                alignment: Alignment.centerLeft,
                foregroundColor: MaterialStateProperty.all(Colors.blue.shade800),
              ),
              child: const Text("GADFLY"),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            width: MediaQuery.of(context).size.width,
            child: const Text(
                "A fly that bites livestock, especially a horsefly, warble fly, or botfly.",
                textAlign: TextAlign.left),
          ),
          Container(
            padding: const EdgeInsets.only(top: 30, bottom: 10),
            width: MediaQuery.of(context).size.width,
            child: const Text("Recent words", style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _listOfWordsInHistory
                      .map((item) => ListTile(
                            leading: const Icon(Icons.history),
                            title: Text(item["text"]),
                          ))
                      .toList()))
        ]));
  }
}
