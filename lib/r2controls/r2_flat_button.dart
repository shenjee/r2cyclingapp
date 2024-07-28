import 'package:flutter/material.dart';


class R2FlatButton extends FlatButton {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onPressed;

  const R2FlatButton({
    Key key,
    this.label,
    this.color,
    this.textColor,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Text(label, style: TextStyle(fontSize: 20),),
      color: Color(0x539765),
      textColor: textColor,
      onPressed: onPressed,
    );
  }
}