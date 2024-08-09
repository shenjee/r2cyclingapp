import 'package:flutter/material.dart';

import 'group_intercom_screen.dart';

class JoinGroupScreen extends StatelessWidget {
  final TextEditingController _groupCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join Group'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _groupCodeController,
              decoration: InputDecoration(labelText: 'Enter Group Code'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Verify group code and navigate to GroupIntercomScreen
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => GroupIntercomScreen()),
                );
              },
              child: Text('Join Group'),
            ),
          ],
        ),
      ),
    );
  }
}
