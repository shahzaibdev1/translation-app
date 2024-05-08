import 'dart:io';

import 'package:flutter/material.dart';

class TranslationDetails extends StatefulWidget {
  // final CustomPaint customPaint;
  final List text;
  final File image;
  const TranslationDetails({required this.text, required this.image, super.key});

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
        body:

            // Positioned(child: widget.customPaint),
            Stack(
          children: [
            Positioned(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                top: 0,
                left: 0,
                child: Image.file(
                  widget.image,
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).height,
                )),
            Positioned(
                bottom: 0,
                height: MediaQuery.sizeOf(context).height - 500,
                width: MediaQuery.sizeOf(context).width,
                child: Container(
                  color: const Color(0xFF201F40),
                  padding: const EdgeInsets.all(10),
                  height: MediaQuery.sizeOf(context).height - 500,
                  child: ListView.separated(
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 30, child: Divider()),
                    itemCount: widget.text.length,
                    itemBuilder: (context, index) => SelectableText(
                      widget.text[index],
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                )),
          ],
        ));
  }
}
