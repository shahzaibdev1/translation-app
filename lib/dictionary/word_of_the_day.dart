import 'package:flutter/material.dart';

class WordOfTheDay extends StatelessWidget {
  const WordOfTheDay({super.key});

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
            child: Text(
              "Matrimonal",
              textAlign: TextAlign.left,
              style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            width: MediaQuery.of(context).size.width,
            child: const Text("Relating to marriage", textAlign: TextAlign.left),
          ),
          Container(
            padding: const EdgeInsets.only(top: 30, bottom: 10),
            width: MediaQuery.of(context).size.width,
            child: const Text("Recent words", style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          SizedBox(
              width: MediaQuery.of(context).size.width,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Text("data")),
                  Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Text("hippopotamus")),
                  Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Text("box"))
                ],
              ))
        ]));
  }
}
