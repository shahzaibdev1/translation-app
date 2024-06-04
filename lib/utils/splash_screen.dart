import 'package:flutter/material.dart';

class ContinuousSlider extends StatefulWidget {
  const ContinuousSlider({super.key});

  @override
  ContinuousSliderState createState() => ContinuousSliderState();
}

class ContinuousSliderState extends State<ContinuousSlider> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat();

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.0, 0.0), // Slide to the left by 100% of the widget's width
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return SlideTransition(
            position: _slideAnimation,
            child: Row(
              children: [
                Image.asset(
                  "assets/images/map1.png",
                  width: MediaQuery.of(context).size.width *
                      0.5, // Use MediaQuery.of(context).size.width
                ),
                Image.asset(
                  "assets/images/map2.png",
                  width: MediaQuery.of(context).size.width *
                      0.5, // Use MediaQuery.of(context).size.width
                ),
                Image.asset(
                  "assets/images/map1.png",
                  width: MediaQuery.of(context).size.width *
                      0.5, // Use MediaQuery.of(context).size.width
                ),
                Image.asset(
                  "assets/images/map2.png",
                  width: MediaQuery.of(context).size.width *
                      0.5, // Use MediaQuery.of(context).size.width
                ),
              ],
            ));
      },
    );
  }
}
