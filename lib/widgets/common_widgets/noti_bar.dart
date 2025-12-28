import 'package:flutter/material.dart';

SnackBar notiBar(String message, bool isError, {int miliseconds = 500}) {
  return SnackBar(
    content: Text("$message"),
    backgroundColor: isError ? Colors.red : Colors.blue,
    duration: Duration(milliseconds: miliseconds),
  );
}
