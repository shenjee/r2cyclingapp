import 'package:flutter/material.dart';
import 'package:r2cyclingapp/constants.dart';

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
      p = null;
    }
    if (null != widget.suffixWidget) {
      s = widget.suffixWidget;
    } else {
      s = null;
    }

    return Row (
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (null != p)
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
            decoration: InputDecoration.collapsed(
              hintText: widget.hintText,
              hintStyle: const TextStyle(color: AppConstants.textColor200),
            ),
            keyboardType: widget.keyboardType,
            obscureText: widget.textVisible ?? false,
          ),
        ),
        if (null != s)
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
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
        color: Colors.white,
      ),
      child: _buildContent(context),
    );
  }
}