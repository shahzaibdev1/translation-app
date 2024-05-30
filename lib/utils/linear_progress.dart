import 'package:flutter/material.dart';

class LinearProgress extends StatefulWidget {
  const LinearProgress({super.key});

  @override
  _LinearProgressState createState() => _LinearProgressState();
}

class _LinearProgressState extends State<LinearProgress> {
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    // Start the animation after a delay (e.g., 1 second)

    setState(() {
      _progress = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: _progress),
      duration: const Duration(seconds: 4),
      builder: (context, value, child) {
        return LinearProgressIndicator(
          borderRadius: BorderRadius.circular(10.0),
          value: value,
          backgroundColor: Colors.grey,
          color: Colors.blue,
          minHeight: 10.0,
        );
      },
    );
  }
}
