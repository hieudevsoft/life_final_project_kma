import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Utils {
  Utils._();
  static final _internal = Utils._();
  factory Utils() {
    return _internal;
  }

  showToast(
    String msg, {
    ToastGravity gravity = ToastGravity.BOTTOM,
    Color? backgroundColor = Colors.white70,
    Color? textColor = Colors.black87,
  }) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: gravity,
      timeInSecForIosWeb: 1,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: 16.0,
    );
  }
}
