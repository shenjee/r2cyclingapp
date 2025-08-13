import 'package:flutter/material.dart';
import 'package:r2cyclingapp/r2controls/r2_flat_button.dart';

class LoginBaseScreen extends StatefulWidget {
  final String? mainButtonTitle;

  const LoginBaseScreen({
    super.key,
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
  String? _mainButtonTitle;

  // setter for button name
  set mainButtonTitle(String v) {
    _mainButtonTitle = v;
  }

  // protected method
  PreferredSizeWidget widgetAppBar(BuildContext context) {
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

  void mainButtonClicked() {
    // TODO: override
  }

  // private method
  Widget _buildTopWidget(BuildContext context) {
    Widget w;
    w = SizedBox(
      height: 160.0, // Fixed height for top area
      child: topWidget(context),
    );
    
    return w;
  }

  Widget _buildCenterWidget(BuildContext context) {
    Widget w;
    //w = Container(color: Colors.yellow, child: centerWidget(context),);
    w = SizedBox(
      height: 250, // Fixed height for center area
      child: centerWidget(context),
    );

    return w;
  }

  Widget _buildMainButton(BuildContext context) {
    return R2FlatButton (
      text: _mainButtonTitle??'',
      onPressed: mainButtonClicked,
    );
  }

  Widget _buildBottomWidget(BuildContext context) {
    Widget w;
    w = bottomWidget(context);

    return w;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:widgetAppBar(context),
        // when text field tapped, keyboard slides up and it resizes
        // the widget, making the fixed-sized child widget exceeds its
        // parent widget and leading to RenderFlex overflow.
        // resizeToAvoidBottomInset-be-false seems to resolve RenderFlex.
        // What's more, there is a listview resolution in stack overflow,
        // which might be tried later.
        resizeToAvoidBottomInset:false,
        body:Column(
          mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              _buildTopWidget(context), // top area - fixed height
              _buildCenterWidget(context), // 2nd area - fixed height
              const SizedBox(height: 100.0),
              _buildMainButton(context), // 3rd area - button position now fixed
              Expanded(
                child: _buildBottomWidget(context)
              ), // bottom area - fills remaining space
            ]
        )
    );
  }
}