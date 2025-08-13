import 'package:flutter/material.dart';

import 'create_group_screen.dart';
import 'join_group_screen.dart';

class GroupListScreen extends StatelessWidget {
  const GroupListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
            },
        ),
      ),
      body: ListView(
        children: [
          const Divider(),
          ListTile(
            // Height is 120.0, evenly distributed vertical padding is 60.0, take half of it
            contentPadding: const EdgeInsets.symmetric(
                vertical: 30.0,
                horizontal: 16.0
            ),
            title: const Text('  建立一个骑行组', style: TextStyle(fontSize: 20.0),),
            trailing: Icon(Icons.chevron_right, color: Colors.grey[500],),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => CreateGroupScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
                vertical: 30.0,
                horizontal: 16.0
            ),
            title: const Text('  加入一个骑行组', style: TextStyle(fontSize: 20.0),),
            trailing: Icon(Icons.keyboard_arrow_right, color: Colors.grey[500],),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const JoinGroupScreen()),
              );
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}