import 'package:flutter/material.dart';

class BlinkingGridItem extends StatefulWidget {
  final Map<String, dynamic> item;
  final int currentValue;

  BlinkingGridItem({required this.item, required this.currentValue});

  @override
  _BlinkingGridItemState createState() => _BlinkingGridItemState();
}

class _BlinkingGridItemState extends State<BlinkingGridItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  bool get isActive => widget.currentValue == widget.item['id'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 0.9).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final opacity = isActive ? _animation.value : 0.3;

          return Container(
            margin: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: widget.item["color"].withOpacity(opacity),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.item["icon"], color: Colors.white, size: 30),
                SizedBox(height: 5),
                Text(
                  widget.item["label"],
                  style: TextStyle(color: Colors.white, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
