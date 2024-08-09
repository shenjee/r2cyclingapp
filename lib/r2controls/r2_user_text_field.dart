import 'package:flutter/material.dart';

class R2UserTextField extends StatefulWidget {
  // Prefix
  final Widget? prefixWidget;
  // TextField
  final TextEditingController? controller;
  final String? text;
  final String? hintText;
  final TextInputType? keyboardType;
  // Suffix
  final Widget? suffixWidget;

  R2UserTextField({
    this.prefixWidget,
    this.controller,
    this.text,
    this.hintText,
    this.keyboardType,
    this.suffixWidget
  });

  @override
  _R2UserTextFieldState createState() => _R2UserTextFieldState();
}

class _R2UserTextFieldState extends State<R2UserTextField> {
  final double _prefix_width = 40.0;
  final double _prefix_height = 40.0;
  final double _suffix_width = 100.0;
  final double _suffix_height = 40.0;
  final double _font_size = 20.0;

  // build the top ui , it has the format like follows:
  // | prefix | text field | suffix |
  // prefix are icon(e.g. phone), or text(e.g. area code)
  // text field receives the input by user
  // suffix are button(e.g. verification code, show passwd), or info(e.g. countdown)
  Widget _buildContent(BuildContext context) {
    Widget? p; // prefix
    Widget? s; // suffix
    if (null != widget.prefixWidget) {
      p = Container(
        alignment:Alignment.center,
        width: _prefix_width, height: _prefix_height,
        child: widget.prefixWidget,
      );
    } else {
      p = Container(color: Colors.yellow,width: _prefix_width, height: _prefix_height,);
    }
    if (null != widget.suffixWidget) {
      s = Container(
        alignment:Alignment.center,
        width: _suffix_width, height: _suffix_height,
        child: widget.suffixWidget,
      );
    } else {
      s = Container(width: _suffix_width, height: _suffix_height,);
    }
    return Row (
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: p,
        ),
        Expanded (
          child: TextField(
            controller: widget.controller,
            textAlign: TextAlign.start,
            textAlignVertical: TextAlignVertical.center,
            style: TextStyle(fontSize: _font_size),
            decoration: InputDecoration.collapsed(hintText:widget.hintText),
            keyboardType: widget.keyboardType,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
          child: s,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      height: 57,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(20.0)),
        border: Border.all(color: Colors.grey, width: 1.0),
      ),
      child: _buildContent(context),
    );
  }
}