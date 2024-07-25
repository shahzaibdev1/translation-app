import 'package:flutter/material.dart';
import "package:image/image.dart" as img;
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:translation_app/providers/navigation_status.dart';

class TranslationDetails extends StatefulWidget {
  // final CustomPaint customPaint;
  final List text;
  final CustomPaint customPaint;
  final img.Image image;

  const TranslationDetails(
      {required this.text, required this.customPaint, required this.image, super.key});

  @override
  State<TranslationDetails> createState() => _TranslationDetailsState();
}

class _TranslationDetailsState extends State<TranslationDetails> {
  copyText(String text) {
    Clipboard.setData(ClipboardData(text: text));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Text copied to clipboard'),
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 100),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  share(String text) async {
    await Share.share(text);
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
        elevation: 10,
        // backgroundColor: Colors.amber,
        enableDrag: true,
        showDragHandle: true,
        context: context,
        builder: (ctx) => StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
              return Container(
                  // width: 300,
                  height: MediaQuery.of(context).size.height * 0.2,
                  // color: Colors.white54,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(children: [
                    SelectableText(widget.text.map((e) => e["text"]).join("\n"), maxLines: 4),
                    const Divider(),
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton.filledTonal(
                              onPressed: () =>
                                  copyText(widget.text.map((e) => e["text"]).join("\n")),
                              icon: const Icon(Icons.copy)),
                          IconButton.filledTonal(
                              onPressed: () => share(widget.text.map((e) => e["text"]).join("\n")),
                              icon: const Icon(Icons.share))
                        ])
                  ]));
            }));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // _showOptions(context);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
        appBar: AppBar(
          bottomOpacity: 0,
          title: const Text("Translation"),
        ),
        body: PopScope(
            canPop: true,
            onPopInvoked: (value) {
              Provider.of<NavigationStatus>(context, listen: false).changePageIndex(0);
            },
            child:
                // Positioned(child: widget.customPaint),
                Stack(
              children: [
                Image.memory(
                  Uint8List.fromList(img.encodeJpg(widget.image)), // Use getBytes()
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).height,
                ),
                Positioned(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    top: 0,
                    left: 0,
                    child: widget.customPaint),
                Positioned(
                  bottom: 0,
                  height: 60,
                  width: MediaQuery.sizeOf(context).width,
                  child: Container(
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                          color: theme.colorScheme.surface),
                      child: Center(
                          child: SizedBox(
                              child: IconButton.filledTonal(
                                  onPressed: () => _showOptions(context),
                                  icon: const Icon(Icons.arrow_upward_rounded))))),
                )
              ],
            )));
  }
}
