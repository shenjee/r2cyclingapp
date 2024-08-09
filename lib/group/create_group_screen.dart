import 'package:flutter/material.dart';
import 'dart:math';

import 'package:r2cyclingapp/connection/http/r2_http_request.dart';
import 'package:r2cyclingapp/connection/http/r2_http_response.dart';

import 'group_intercom_screen.dart';

class CreateGroupScreen extends StatefulWidget {
  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  @override
  Widget build(BuildContext context) {
    String groupCode = _generateGroupCode();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Your Group Code:',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 10),
            Text(
              groupCode,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Save the group to the database and navigate to GroupIntercomScreen
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => GroupIntercomScreen()),
                );
              },
              child: Text('Start Group Intercom'),
            ),
          ],
        ),
      ),
    );
  }

  String _generateGroupCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        4, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }
}
