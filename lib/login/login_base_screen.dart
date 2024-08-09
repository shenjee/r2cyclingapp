//import 'dart:nativewrappers/_internal/vm/lib/core_patch.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:r2cyclingapp/r2controls/r2_flat_button.dart';

class LoginBaseScreen extends StatefulWidget {
  final String? mainButtonTitle;

  LoginBaseScreen({
    this.mainButtonTitle
  });

  @override
  LoginBaseScreenState createState() => LoginBaseScreenState();
}

class LoginBaseScreenState extends State<LoginBaseScreen> {
  // the screen area divided into 4 part upside down
  // 1. top area for the logo or function title
  // 2. the 2nd one for username/password input
  // 3. the 3rd one is button
  // 4. the bottom area  for notice
  String? _main_button_title;

  // setter for button name
  set mainButtonTitle(String v) {
    _main_button_title = v;
  }

  // protected method
  PreferredSizeWidget wigetAppBar(BuildContext context) {
    return AppBar();
  }

  Widget topWidget(BuildContext context) {
    // TODO: override
    return Container();
  }

  Widget centerWidget(BuildContext context) {
    // TODO: override
    return Container();
  }

  Widget bottomWidget(BuildContext context) {
    // TODO: override
    return Container();
  }

  void main_button_clicked() {
    // TODO: override
  }

  // private method
  Widget _build_top_widget(BuildContext context) {
    Widget w;
    //w = Container(color: Colors.red, child: topWidget(context),);
    w = Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: topWidget(context),
    );
    
    return w;
  }

  Widget _build_center_widget(BuildContext context) {
    Widget w;
    //w = Container(color: Colors.yellow, child: centerWidget(context),);
    w = Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: centerWidget(context),
    );

    return w;
  }

  Widget _build_main_button(BuildContext context) {
    return R2FlatButton (
      text: _main_button_title??'',
      onPressed: main_button_clicked,
    );
  }

  Widget _build_bottom_widget(BuildContext context) {
    Widget w;
    w = Expanded(
      child: bottomWidget(context),
    );

    return w;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:wigetAppBar(context),
        // when text field tapped, keyboard slides up and it resizes
        // the widget, making the fixed-sized child widget exceeds its
        // parent widget and leading to RenderFlex overflow.
        // resizeToAvoidBottomInset-be-false seems to resolve RenderFlex.
        // What's more, there is a listview resolution in stack overflow,
        // which might be tried later.
        resizeToAvoidBottomInset:false,
        body:Column(
          mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _build_top_widget(context), // top area
              _build_center_widget(context), // 2nd area
              _build_main_button(context), // 3rd area
              _build_bottom_widget(context), // bottom area
            ]
        )
    );
  }
}