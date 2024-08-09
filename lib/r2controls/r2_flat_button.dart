import 'package:flutter/material.dart';

class R2FlatButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  R2FlatButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: const ButtonStyle(
        minimumSize: WidgetStatePropertyAll(Size(340, 57)),
        textStyle: WidgetStatePropertyAll(
          TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: WidgetStatePropertyAll(Color(0xFF539765)),
        foregroundColor: WidgetStatePropertyAll(Colors.white),
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}