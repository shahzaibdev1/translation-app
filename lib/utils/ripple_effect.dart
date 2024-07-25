import 'package:flutter/material.dart';

class RippleEffectContainer extends StatefulWidget {
  final double width;
  final double height;
  final VoidCallback onTap;
  final Color color;
  final Duration duration;
  final Widget icon;
  final bool isEnabled;

  const RippleEffectContainer({
    Key? key,
    required this.width,
    required this.height,
    required this.onTap,
    required this.icon,
    required this.isEnabled,
    this.color = Colors.blue,
    this.duration = const Duration(seconds: 2),
  }) : super(key: key);

  @override
  RippleEffectContainerState createState() => RippleEffectContainerState();
}

class RippleEffectContainerState extends State<RippleEffectContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // void _toggleRipple() {
  //   setState(() {
  //     if (widget.isEnabled) {
  //       _animationController.repeat(reverse: true);
  //     } else {
  //       _animationController.stop();
  //     }
  //   });
  // }

  @override
  void didUpdateWidget(covariant RippleEffectContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if any relevant properties have changed
    // if (widget.color != oldWidget.color || widget.duration != oldWidget.duration) {
    if (oldWidget.isEnabled != widget.isEnabled && widget.isEnabled) {
      _restartAnimation();
    }

    if (!widget.isEnabled) {
      _animationController.stop();
    }
  }

  void _restartAnimation() {
    if (widget.isEnabled) {
      _animationController.stop();
      _animationController.repeat(reverse: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          widget.onTap();
        },
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(widget.isEnabled ? 0.5 : 0),
                    spreadRadius: 5,
                    blurRadius: 10 * _animationController.value,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: widget.icon,
            );
          },
        ));
  }
}
