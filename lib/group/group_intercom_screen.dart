import 'package:flutter/material.dart';

class GroupIntercomScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Intercom'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Group Intercom',
              style: TextStyle(fontSize: 24),
            ),
            // Add intercom functionality here
          ],
        ),
      ),
    );
  }
}
