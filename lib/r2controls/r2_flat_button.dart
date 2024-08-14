import 'package:flutter/material.dart';

class R2FlatButton extends StatelessWidget {
  final String _text;
  final VoidCallback _onPressed;
  final Color _backgroundColor;
  final double _width;
  final double _height;

  const R2FlatButton({
    super.key,  // Include the Key parameter here
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
    double? width,
    double? height,})
      : _text = text,
        _onPressed = onPressed,
        _backgroundColor = backgroundColor?? const Color(0xFF539765),
        _width = width?? 340.0,
        _height = height?? 57.0;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        minimumSize: WidgetStatePropertyAll(Size(_width, _height)),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: WidgetStatePropertyAll(_backgroundColor),
        foregroundColor: const WidgetStatePropertyAll(Colors.white),
      ),
      onPressed: _onPressed,
      child: Text(_text),
    );
  }
}