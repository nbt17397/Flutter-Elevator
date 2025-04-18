import 'package:flutter/material.dart';

class BlinkingCircleButton extends StatefulWidget {
  final String title;
  final Color backgroundColor;
  final Color textColor;

  const BlinkingCircleButton(
      {super.key,
      required this.title,
      required this.backgroundColor,
      required this.textColor});
  @override
  _BlinkingCircleButtonState createState() => _BlinkingCircleButtonState();
}

class _BlinkingCircleButtonState extends State<BlinkingCircleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 0.3).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: CircleAvatar(
        radius: 28,
        backgroundColor: widget.backgroundColor,
        child: Text(
          widget.title,
          style: TextStyle(
            color: widget.textColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
