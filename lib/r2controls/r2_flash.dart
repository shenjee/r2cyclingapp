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