import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';


class ShowFlushbar{

  static void showMessage(message,context) {
    Flushbar(
      // title: 'This action is prohibited',
      message: message,
      icon: Icon(
        Icons.info_outline,
        size: 28,
        color: Colors.orange,
      ),
      leftBarIndicatorColor: Colors.orange,
      duration: Duration(seconds: 4),
    )..show(context);

  }
}