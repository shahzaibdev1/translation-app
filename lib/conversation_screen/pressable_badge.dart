import 'package:flutter/material.dart';

class PressableBadge extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const PressableBadge({
    Key? key,
    required this.text,
    this.color = Colors.red,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Badge(
        label: Text(text),
      ),
    );
  }
}
