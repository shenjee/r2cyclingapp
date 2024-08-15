import 'package:flutter/material.dart';
import 'package:r2cyclingapp/group/group_intercom_screen.dart';

import 'create_group_screen.dart';
import 'join_group_screen.dart';

class GroupListScreen extends StatelessWidget {
  const GroupListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group List'),
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
            // 高度为120.0，均匀分布的垂直内边距为60.0，取其半
            contentPadding: const EdgeInsets.symmetric(
                vertical: 30.0,
                horizontal: 16.0
            ),
            title: const Text('  建立一个骑行组', style: TextStyle(fontSize: 20.0),),
            trailing: Icon(Icons.keyboard_arrow_right, color: Colors.grey[500],),
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
                MaterialPageRoute(builder: (context) => JoinGroupScreen()),
              );
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}