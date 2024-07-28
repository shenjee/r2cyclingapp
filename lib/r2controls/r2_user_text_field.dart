import 'package:flutter/material.dart';

class R2UserTextField extends StatefulWidget {
  final TextEditingController? controller;
  final Text? text;
  final Text? hintText;

  R2UserTextField({this.controller, this.text, this.hintText});
  
  @override
  _R2UserTextFieldState createState() => _R2UserTextFieldState();
}

class _R2UserTextFieldState extends State<R2UserTextField> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}