import 'dart:async';
import 'package:flutter/material.dart';

class SOSWidget extends StatefulWidget {
  final VoidCallback onCancel;
  final VoidCallback onSend;

  const SOSWidget({
    super.key,
    required this.onCancel,
    required this.onSend
  });

  @override
  State<SOSWidget> createState() => _SOSWidgetState();
}

class _SOSWidgetState extends State<SOSWidget> {
  int _counter = 10;
  String _indicator = '';
  Timer? _timer;

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_counter > 0) {
        setState(() {
          _counter--;
          _indicator = '$_counter';
        });
      } else {
        setState(() {
          _indicator = '正在发送';
        });
        _timer?.cancel();
        widget.onSend();
        setState(() {
          _indicator = '发送完成';
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(40.0, 80.0, 40.0, 80.0),
            child: Text(
              'SOS',
              style: TextStyle(
                  fontSize: 66,
                  fontWeight: FontWeight.w900,
                  color: Colors.white
              ),
            ),
          ),
          Expanded(
            child: Text(
              _indicator,
              style: const TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.w900,
                  color: Colors.white
              ),
            ),
          ),
          if (_counter > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 80.0),
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _indicator = '正在发送';
                  });
                  _timer?.cancel();
                  widget.onSend();
                  setState(() {
                    _indicator = '发送完成';
                    _counter = 0;
                  });
                },
                style: TextButton.styleFrom(
                  side: const BorderSide(color: Colors.white),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 52.0),
                ),
                child: const Text(
                  '立即发送',
                  style: TextStyle(fontSize: 24.0, color: Colors.white),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
            child: TextButton(
              onPressed: widget.onCancel,
              child: Text(
                (_counter > 0)? '取消':'完成',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
