import 'package:flutter/material.dart';

InputDecoration myDecorationDropdown() {
  return InputDecoration(
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blue.shade50, width: 2),
      borderRadius: BorderRadius.circular(15),
    ),
    focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white, width: 2),
        borderRadius: BorderRadius.circular(15)),
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blue.shade50, width: 2),
      borderRadius: BorderRadius.circular(15),
    ),
    filled: true,
    fillColor: Colors.blue.shade50,
  );
}

InputDecoration myDecorationTextFormField([String? labelText, String? hintText, String? prefix]) {
  return InputDecoration(
      filled: true,
      fillColor: WidgetStateColor.fromMap(<WidgetStatesConstraint, Color>{
        WidgetState.focused: Colors.white,
        WidgetState.any: Colors.blue.shade50,
      }),
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(15)),
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2),
          borderRadius: BorderRadius.circular(15)),
      errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 1),
          borderRadius: BorderRadius.circular(15)),
      labelText: labelText,
      labelStyle: TextStyle(fontStyle: FontStyle.italic),
      hintText: hintText,
      prefix: prefix != null ? Text(prefix) : null);
}
