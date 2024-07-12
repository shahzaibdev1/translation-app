import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:translation_app/ads/native_ad.dart';

class ResultScreen extends StatefulWidget {
  final String text;
  const ResultScreen({required this.text, super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  List<dynamic> _result = [];
  bool _isLoading = true;
  bool _isError = false;
  String? _errorMessage = '';

  @override
  void initState() {
    super.initState();

    _getDictionary();
  }

  void _getDictionary() async {
    final response =
        await http.get(Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/${widget.text}'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);

      setState(() {
        _result = data;
        _isLoading = false;
      });
    } else if (response.statusCode == 404) {
      Map<String, dynamic> data = jsonDecode(response.body);

      setState(() {
        _isError = true;
        _isLoading = false;

        _errorMessage = data["title"];
      });
    } else {
      setState(() {
        _isError = true;
        _isLoading = false;
      });
      // throw Exception('Failed to load suggestions');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Result'),
        ),
        body: SafeArea(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _isError
                    ? Center(
                        child: Text(_errorMessage ?? "No data found"),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListView(
                            children: _result
                                .map((res) => Column(children: [
                                      ...res["meanings"].map<Widget>((meaning) {
                                        return SizedBox(
                                            width: MediaQuery.of(context).size.width,
                                            child: Card(
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                    side: BorderSide(
                                                        color: theme
                                                            .colorScheme.onSecondaryContainer
                                                            .withAlpha(40))),
                                                child: Padding(
                                                    padding: const EdgeInsets.all(16),
                                                    child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                              "${meaning['partOfSpeech']}: ${res['word']}",
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight: FontWeight.w600,
                                                                  color:
                                                                      theme.colorScheme.primary)),
                                                          const Divider(),

                                                          // Definitions along with their examples
                                                          Text("(${res['phonetic']})",
                                                              style: const TextStyle(
                                                                  fontStyle: FontStyle.italic,
                                                                  fontFamily: "Roboto")),
                                                          ...meaning["definitions"]
                                                              .asMap()
                                                              .entries
                                                              .map((entry) {
                                                            int index = entry.key;
                                                            var definition = entry.value;
                                                            return Padding(
                                                              padding:
                                                                  const EdgeInsets.only(top: 16),
                                                              child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment.start,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment.start,
                                                                  children: [
                                                                    Row(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment.start,
                                                                      children: [
                                                                        Text(
                                                                            '${index + 1}. '), // Index
                                                                        Expanded(
                                                                            child: Text(
                                                                                definition[
                                                                                    'definition'],
                                                                                style: const TextStyle(
                                                                                    fontWeight:
                                                                                        FontWeight
                                                                                            .w500))), // Definition
                                                                      ],
                                                                    ),
                                                                    definition['example'] != null
                                                                        ? Text(
                                                                            definition['example'],
                                                                            style: TextStyle(
                                                                                fontStyle: FontStyle
                                                                                    .italic,
                                                                                color: Colors
                                                                                    .cyan[700]))
                                                                        : const SizedBox.shrink(),
                                                                  ]),
                                                            );
                                                          }).toList()
                                                        ]))));
                                      }).toList(),
                                      NativeAdWidget(
                                          width: 320,
                                          height: 320,
                                          maxW: MediaQuery.of(context).size.width,
                                          maxH: 400,
                                          type: TemplateType.medium,
                                          adId: "ca-app-pub-3940256099942544/2247696110")
                                    ]))
                                .toList()))));
  }
}
