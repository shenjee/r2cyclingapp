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
import 'package:flash/flash.dart';

class R2Flash {
  /*
   * it works like a toast, but it features more functionalities than toast does.
   * it seems that flash library has a real toast module, but I failed to
   * get toast working. Try it later.
   */
  static void showBasicFlash({
    BuildContext? context,
    String? title,
    String? message,
    Duration? duration,
    flashStyle = FlashBehavior.floating,
  }) {
    showFlash(
      context: context!,
      duration: duration,
      builder: (context, controller) {
        return FlashBar(
          controller: controller,
          forwardAnimationCurve: Curves.easeInCirc,
          reverseAnimationCurve: Curves.bounceIn,
          position: FlashPosition.top,
          behavior: flashStyle,
          contentTextStyle: const TextStyle(fontSize: 20, color:Colors.red),
          content: Center(child:Text(message!)),
        );
      },
    );
  }
}