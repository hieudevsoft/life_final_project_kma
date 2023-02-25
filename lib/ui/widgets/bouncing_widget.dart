import 'package:flutter/material.dart';

class BouncingButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onClickListener;
  const BouncingButton({Key? key, required this.child, required this.onClickListener}) : super(key: key);
  @override
  _BouncingButtonState createState() => _BouncingButtonState();
}

class _BouncingButtonState extends State<BouncingButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 500,
      ),
      lowerBound: 0.0,
      upperBound: 0.2,
    )..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _tapDown,
      onTapUp: _tapUp,
      child: Transform.scale(
        scale: 1 - _controller.value,
        child: widget.child,
      ),
    );
  }

  void _tapDown(TapDownDetails details) {
    _controller.forward();
    widget.onClickListener.call();
  }

  void _tapUp(TapUpDetails details) {
    _controller.reverse();
  }
}
