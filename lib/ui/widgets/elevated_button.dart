import 'package:flutter/material.dart';

class MyElevatedButton extends StatelessWidget {
  const MyElevatedButton({
    Key? key,
    required this.child,
    this.shape,
    this.backgroundColor,
    this.foregroundColor,
    this.surfaceTintColor,
    this.minimumSize,
    this.isEnabled = true,
    this.onPressed,
  }) : super(key: key);

  final OutlinedBorder? shape;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? surfaceTintColor;
  final Size? minimumSize;
  final VoidCallback? onPressed;
  final bool isEnabled;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        shape: shape ?? StadiumBorder(),
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        surfaceTintColor: surfaceTintColor,
        minimumSize: minimumSize ?? Size(MediaQuery.of(context).size.width.toInt() - 50, 50),
        disabledBackgroundColor: Colors.grey.shade200.withAlpha(80),
      ),
      child: child,
    );
  }
}
