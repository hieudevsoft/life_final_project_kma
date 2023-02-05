import 'package:flutter/material.dart';

class MyTextButton extends StatelessWidget {
  const MyTextButton({
    super.key,
    required this.child,
    this.defaultColor,
    this.pressedColor,
    this.overlayColor,
    this.shape,
    this.onPressed,
  });

  final Color? defaultColor;
  final Color? pressedColor;
  final Color? overlayColor;
  final OutlinedBorder? shape;
  final Widget child;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
          foregroundColor: MaterialStateProperty.resolveWith(
            (states) {
              if (states.contains(MaterialState.pressed) || states.contains(MaterialState.focused)) {
                return pressedColor;
              } else {
                return defaultColor;
              }
            },
          ),
          overlayColor: MaterialStateProperty.all(overlayColor),
          shape: MaterialStateProperty.all(shape)),
      child: child,
    );
  }
}
