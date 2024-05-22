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
