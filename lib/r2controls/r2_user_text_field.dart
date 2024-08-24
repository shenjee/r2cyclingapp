import 'package:flutter/material.dart';

class R2UserTextField extends StatefulWidget {
  // Prefix
  final Widget? prefixWidget;
  // TextField
  final TextEditingController? controller;
  final String? text;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool? textVisible;
  // Suffix
  final Widget? suffixWidget;

  const R2UserTextField({
    super.key,
    this.prefixWidget,
    this.controller,
    this.text,
    this.hintText,
    this.keyboardType,
    this.textVisible,
    this.suffixWidget
  });

  @override
  State<R2UserTextField> createState() => _R2UserTextFieldState();
}

class _R2UserTextFieldState extends State<R2UserTextField> {
  final double _prefixWidth = 40.0;
  final double _prefixHeight = 40.0;
  final double _suffixWidth = 100.0;
  final double _suffixHeight = 40.0;
  final double _fontSize = 20.0;

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
        width: _prefixWidth, height: _prefixHeight,
        child: widget.prefixWidget,
      );
    } else {
      p = Container(color: Colors.yellow,width: _prefixWidth, height: _prefixHeight,);
    }
    if (null != widget.suffixWidget) {
      s = Container(
        alignment:Alignment.center,
        width: _suffixWidth, height: _suffixHeight,
        child: widget.suffixWidget,
      );
    } else {
      s = Container(width: _suffixWidth, height: _suffixHeight,);
    }
    return Row (
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: p,
        ),
        Expanded (
          child: TextField(
            controller: widget.controller,
            textAlign: TextAlign.start,
            textAlignVertical: TextAlignVertical.center,
            style: TextStyle(fontSize: _fontSize),
            decoration: InputDecoration.collapsed(hintText:widget.hintText),
            keyboardType: widget.keyboardType,
            obscureText: widget.textVisible ?? true,
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