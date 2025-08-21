// Copyright (c) 2025 RockRoad Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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