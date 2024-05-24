import 'package:flutter/material.dart';

class DictionaryResult extends StatefulWidget {
  final String word;

  const DictionaryResult({super.key, required this.word});

  @override
  State<DictionaryResult> createState() => _DictionaryResultState();
}

class _DictionaryResultState extends State<DictionaryResult> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
