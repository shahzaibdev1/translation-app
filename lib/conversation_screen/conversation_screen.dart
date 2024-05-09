import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class Conversation extends StatefulWidget {
  const Conversation({Key? key});

  @override
  State<Conversation> createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
  final TextEditingController chatTextController = TextEditingController();
  List<Map<String, String>> messages = [];

  void handleChange() async {
    String text = chatTextController.text;

    final onDeviceTranslator = OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.english, targetLanguage: TranslateLanguage.urdu);

    final String translatedText = await onDeviceTranslator.translateText(text);

    setState(() {
      messages.add({"text": text, "translatedText": translatedText});
    });

    chatTextController.clear();

    return;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.all(8.0),
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          messages[index]["text"] != null ? messages[index]["text"]! : "",
                          style: theme.textTheme.bodyLarge!
                              .copyWith(color: theme.colorScheme.onPrimary),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.all(8.0),
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          messages[index]["translatedText"] != null
                              ? messages[index]["translatedText"]!
                              : "",
                          style: theme.textTheme.bodyLarge!
                              .copyWith(color: theme.colorScheme.onPrimary),
                        ),
                      ),
                    )
                  ]);
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.black.withAlpha(100)),
                          borderRadius: BorderRadius.circular(6)),
                      child: SizedBox(
                          width: MediaQuery.of(context).size.width - 90,
                          child: TextField(
                            autofocus: true,
                            controller: chatTextController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              labelText: "Enter your message",
                            ),
                          ))),
                  IconButton(onPressed: handleChange, icon: const Icon(Icons.send))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
