// emergency_contact_screen.dart

import 'package:flutter/material.dart';
import 'package:r2cyclingapp/database/r2_db_helper.dart';

import 'contact_widget.dart';

class EmergencyContactScreen extends StatefulWidget {
  @override
  _EmergencyContactScreenState createState() => _EmergencyContactScreenState();
}

class _EmergencyContactScreenState extends State<EmergencyContactScreen> {
  bool isEmergencyContactEnabled = false;
  final dbHelper = R2DBHelper();
  List<Map<String, dynamic>> contacts = [];

  @override
  void initState() {
    super.initState();
    _loadEmergencyContactStatus();
  }

  Future<void> _loadEmergencyContactStatus() async {
    final setting = await dbHelper.getSetting();
    final contactList = await dbHelper.getContacts();
    setState(() {
      contacts = contactList;
      isEmergencyContactEnabled = setting != null && setting['emergencyContactEnabled'] == 1;
    });
  }

  Future<void> _updateEmergencyContactStatus(bool value) async {
    final setting = {'id': 1, 'emergencyContactEnabled': value ? 1 : 0};
    await dbHelper.saveSetting(setting);
    if (value && contacts.isEmpty) {
      _showAddContactDialog();
    }
    setState(() {
      isEmergencyContactEnabled = value;
    });
  }

  Future<void> _checkContactsAfterClose() async {
    final contactList = await dbHelper.getContacts();
    setState(() {
      contacts = contactList;
      if (contacts.isEmpty) {
        _updateEmergencyContactStatus(false);
      }
    });
  }

  Widget _switchWidget() {
    return Column(
      children: [
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Padding(
                padding:EdgeInsets.fromLTRB(40.0, 20.00, 40.0, 10.0),
                child:Text('SOS 紧急联络', style: TextStyle(fontSize: 24.0),),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(40.0, 20.00, 40.0, 10.0),
                child:Switch(
                  value: isEmergencyContactEnabled,
                  onChanged: (value) {
                    setState(() {
                      isEmergencyContactEnabled = value;
                    });
                    _updateEmergencyContactStatus(value);
                  },
                ),
              ),
            ]
        ),
        if (!isEmergencyContactEnabled)
          const Padding(padding: EdgeInsets.fromLTRB(40.0, 10.0, 40.0, 0.0),
            child:Text(
              '开启SOS紧急联络，您在骑行过程中若摔倒，将自动将您的位置信息以短信方式发给您的紧急联系人，并尝试拨打紧急联系人的电话。',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey,
              ),
            ),
          ),
        if (isEmergencyContactEnabled) _buildContactList(),
      ]);
  }

  void _showAddContactDialog() {
    showDialog(
      context: context,
      builder: (context) => ContactWidget(
        onSave: (name, phone) async {
          await dbHelper.saveContact({'name': name, 'phone': phone});
          _loadEmergencyContactStatus();
          Navigator.of(context).pop();
        },
        onClose: () {
          _checkContactsAfterClose();
        },
      ),
    );
  }

  void _showEditContactDialog(Map<String, dynamic> contact) {
    showDialog(
      context: context,
      builder: (context) => ContactWidget(
        contact: contact,
        onSave: (name, phone) async {
          await dbHelper.saveContact({'id': contact['id'], 'name': name, 'phone': phone});
          _loadEmergencyContactStatus();
          Navigator.of(context).pop();
        },
        onDelete: () async {
          await dbHelper.deleteContact(contact['id']);
          _loadEmergencyContactStatus();
          Navigator.of(context).pop();
        },
        onClose: () {
          _checkContactsAfterClose();
        },
      ),
    );
  }

  Widget _buildContactList() {
    List<Widget> contactListItems = [];
    for (int i = 0; i < contacts.length; i++) {
      final contact = contacts[i];
      contactListItems.add(
          Container(
            height: 80.0,
            child: ListTile(
              leading: CircleAvatar(
                radius: 30.0,
                backgroundColor: Colors.grey[200],
                child: Text('${i + 1}', style: const TextStyle(fontSize: 22.0),),
              ),
              title: Text(contact['name'], style: const TextStyle(fontSize: 22.0),),
              trailing: const Icon(Icons.keyboard_arrow_right),
              onTap: () => _showEditContactDialog(contact),
            ),
          ),
      );
    }

    if (contacts.length < 3) {
      contactListItems.add(
        Container(
          height: 80.0,
          child:ListTile(
            leading: CircleAvatar(
              radius: 30.0,
              backgroundColor: Colors.grey[200],
              child: const Icon(Icons.add),
            ),
            onTap: _showAddContactDialog,
          ),
        ),
      );
    }

    return ListView(
      shrinkWrap: true,
      children: contactListItems,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS 紧急联络'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            _switchWidget(),
          ],
        ),
      ),
    );
  }
}
