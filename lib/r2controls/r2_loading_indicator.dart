import 'package:flutter/material.dart';

class R2LoadingIndicator {
  static Widget _loadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  static show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: _loadingIndicator(),
        );
      },
    );
  }

  static stop(BuildContext context) {
    Navigator.pop(context);
  }
}
