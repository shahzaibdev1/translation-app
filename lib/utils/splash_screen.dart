import 'dart:async';

import 'package:flutter/material.dart';

class ContinuousSlider extends StatefulWidget {
  const ContinuousSlider({super.key});

  @override
  _ContinuousSliderState createState() => _ContinuousSliderState();
}

class _ContinuousSliderState extends State<ContinuousSlider> {
  final ScrollController _scrollController = ScrollController();
  double _scrollPosition = 0;
  final double _widgetWidth = 800; // Set this to the width of your widget

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Timer.periodic(const Duration(milliseconds: 20), (Timer timer) {
      if (_scrollController.hasClients) {
        _scrollPosition += 1;
        if (_scrollPosition >= _scrollController.position.maxScrollExtent) {
          _scrollPosition = 0;
          _scrollController.jumpTo(_scrollPosition);
        } else {
          _scrollController.animateTo(_scrollPosition,
              duration: const Duration(milliseconds: 20), curve: Curves.linear);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return SizedBox(
          width: MediaQuery.sizeOf(context).width,
          child: Row(
            children: [
              Image.asset(
                "assets/images/map1.png",
                width: MediaQuery.sizeOf(context).width * 0.5,
              ),
              Image.asset(
                "assets/images/map2.png",
                width: MediaQuery.sizeOf(context).width * 0.5,
              )
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
