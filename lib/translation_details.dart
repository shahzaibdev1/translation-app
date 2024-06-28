import 'package:flutter/material.dart';
import "package:image/image.dart" as img;
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
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
  void _showOptions(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    showModalBottomSheet(
        elevation: 10,
        // backgroundColor: Colors.amber,
        enableDrag: true,
        showDragHandle: true,
        context: context,
        builder: (ctx) => StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
              return Container(
                  // width: 300,
                  height: MediaQuery.of(context).size.height * 0.6,
                  // color: Colors.white54,
                  alignment: Alignment.center,
                  child: Row(children: [IconButton(onPressed: () {}, icon: Icon(Icons.copy))]));
            }));
  }

  @override
  void initState() {
    super.initState();
    _showOptions(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
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
              ],
            )));
  }
}
