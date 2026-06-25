import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastService {
  static void _show(String msg, Color bgColor) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: bgColor,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  static void showSuccess(String msg) =>
      _show(msg, const Color(0xFF34D399)); // green
  static void showError(String msg) =>
      _show(msg, const Color(0xFFEF4444)); // red
  static void showInfo(String msg) =>
      _show(msg, const Color(0xFF0FB39E)); // teal
  static void showWarning(String msg) =>
      _show(msg, const Color(0xFFF59E0B)); // amber
}
