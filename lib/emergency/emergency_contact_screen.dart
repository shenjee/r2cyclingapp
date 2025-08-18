import 'package:flutter/material.dart';
import 'package:r2cyclingapp/database/r2_db_helper.dart';
import 'package:r2cyclingapp/database/r2_storage.dart';
import 'package:r2cyclingapp/connection/http/r2_http_request.dart';

import 'contact_widget.dart';

class EmergencyContactScreen extends StatefulWidget {
  const EmergencyContactScreen({super.key});

  @override
  State<EmergencyContactScreen> createState() => _EmergencyContactScreenState();
}

class _EmergencyContactScreenState extends State<EmergencyContactScreen> {
  bool isEmergencyContactEnabled = false;
  final dbHelper = R2DBHelper();
  List<Map<String, dynamic>> arrayContacts = [];

  @override
  void initState() {
    super.initState();
    _loadEmergencyContactStatus();
  }

  Future<void> _loadEmergencyContactStatus() async {
    final setting = await dbHelper.getSetting();
    final contactList = await dbHelper.getContacts();

    setState(() {
      arrayContacts = contactList;
      isEmergencyContactEnabled = setting != null && setting['emergencyContactEnabled'] == 1;
    });

    // if the emergency contact is enabled and the contact list is empty, 
    // request the emergency contacts from the server
    if (isEmergencyContactEnabled == true && contactList.isEmpty) {
      await _requestAllEmergencyContacts();
      _loadEmergencyContactStatus();
    }
  }

  Future<void> _updateEmergencyContactStatus(bool value) async {
    final setting = {'id': 1, 'emergencyContactEnabled': value ? 1 : 0};
    await dbHelper.saveSetting(setting);
    if (value && arrayContacts.isEmpty) {
      _showAddContactDialog();
    }
    setState(() {
      isEmergencyContactEnabled = value;
    });
  }

  Future<void> _checkContactsAfterClose() async {
    final contactList = await dbHelper.getContacts();
    setState(() {
      arrayContacts = contactList;
      if (arrayContacts.isEmpty) {
        _updateEmergencyContactStatus(false);
      }
    });
  }

  Widget _switchWidget() {
    return Column(
      children: [
        Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Expanded (
                child: Padding(
                  padding:EdgeInsets.fromLTRB(20.0, 20.0, 0.0, 10.0),
                  child:Text('SOS 紧急联络', style: TextStyle(fontSize: 24.0),),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(00.0, 20.0, 20.0, 10.0),
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
          const Padding(
            padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 0.0),
            child:Text(
              '开启SOS紧急联络，您在骑行过程中若摔倒，'
                  '将自动将您的位置信息以短信方式发给您的紧急联系人，并尝试拨打紧急联系人的电话。',
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
          await _addContact(name, phone);
          _loadEmergencyContactStatus();
          _checkContactsAfterClose();
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
          await _updateContact(contact['contactId'], name, phone);
          _loadEmergencyContactStatus();
          Navigator.of(context).pop();
        },
        onDelete: () async {
          await _deleteContact(contact['contactId']);
          _loadEmergencyContactStatus();
          _checkContactsAfterClose();
          Navigator.of(context).pop();
        },
        onClose: () {
        },
      ),
    );
  }

  Widget _buildContactList() {
    List<Widget> contactListItems = [];

    for (int i = 0; i < arrayContacts.length; i++) {
      final contact = arrayContacts[i];
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

    if (arrayContacts.length < 3) {
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

  // the following methods handle the data of contacts
  // fixme: the following methods are should be in a separate class
  
  /*
   * @description: add contact both to server and local database
   * @paramters: name: the name of the contact
   * @paramters: phone: the phone number of the contact
   * @return: void
   */
  Future<void> _addContact(String name, String phone) async {
    // 1. Request contactId and upload name/phone to server
    int contactId = await _requestAddContact(name, phone);

    if (contactId != 0) {
      // 2. Save contact to local database
      await dbHelper.saveContact(contactId, name, phone);
    }
  }

    /*
   * @description: save contact both to server and local database
   * @paramters: name: the name of the contact
   * @paramters: phone: the phone number of the contact
   * @return: void
   */
  Future<void> _updateContact(int contactId, String name, String phone) async {
    // 1. Request contactId and upload name/phone to server
    int errorRet = 0;
    errorRet = await _requestUpdateContact(contactId, name, phone);
    if (0 == errorRet) {
      await dbHelper.saveContact(contactId, name, phone);
    }
  }

  /*
   * @description: delete contact both from server and local database
   * @paramters: contactId: the id of the contact to delete
   * @return: 
   * success: 0
   * fail: the value of error code of http reqeust 
   */
  Future<int> _deleteContact(int contactId) async {
    int errorRet = 0;
    errorRet = await _requestDeleteContact(contactId);
    if (errorRet == 0) {
      await dbHelper.deleteContact(contactId);
    }
    return errorRet;
  }

  /*
   * @description: add a emergency contact remotely
   * @paramters: name: the name of the contact
   * @paramters: phone: the phone number of the contact
   * @return: 
   * success: contact id
   * fail: 0 
   */
  Future<int> _requestAddContact(String name, String phone) async {
    int contactId = 0;
    final token = await R2Storage.read('authtoken');
    final request = R2HttpRequest();
    final response = await request.postRequest(
      api: 'emergencyContact/saveEmergencyContact',
      token: token,
      body: {
        'emergencyContactId': '',
        'contactMan': name,
        'contactManMobile': phone,
      }
    );

    if (response.success == true) {
      contactId = response.result['emergencyContactId'] ?? 0;
    }

    return contactId;
  }

  /*
   * @description: update a emergency contact remotely
   * @paramters: contactId: the id of the contact
   * @paramters: name: the name of the contact
   * @paramters: phone: the phone number of the contact
   * @return: 
   * success: 0
   * fail: the value of error code of http reqeust 
   */
  Future<int> _requestUpdateContact(int contactId, String name, String phone) async {
    int errorRet = 0;
    final token = await R2Storage.read('authtoken');
    final request = R2HttpRequest();
    final response = await request.postRequest(
      api: 'emergencyContact/saveEmergencyContact',
      token: token,
      body: {
        'emergencyContactId': contactId.toString(),
        'contactMan': name,
        'contactManMobile': phone,
      }
    );

    if (response.success != true) {
      errorRet = response.code;
    }

    return errorRet;
  }

  Future<int> _requestDeleteContact(int contactId) async {
    int errorRet = 0;
    final token = await R2Storage.read('authtoken');
    final request = R2HttpRequest();
    final response = await request.postRequest(
      api: 'emergencyContact/deleteEmergencyContact',
      token: token,
      body: {
        'emergencyContactId': contactId.toString(),
      }
    );

    if (response.success == false) {
      errorRet = response.code;
    }

    return errorRet;
  }

  /*
   * @description: request all emergency contacts from remote server
   * and save them to local database
   * @paramters: none
   * @return: void
   */
  Future<void> _requestAllEmergencyContacts() async {
    final token = await R2Storage.read('authtoken');
    final request = R2HttpRequest();
    final response = await request.getRequest(
      api: 'emergencyContact/listEmergencyContact',
      token: token,
    );

    if (response.success == true) {
      // response.result is a JSON array containing contact information
      final List<dynamic> contactList = response.result;
      
      // Save each contact to the database
      for (final contactData in contactList) {
        final String name = contactData['contactMan'] ?? '';
        final String phone = contactData['contactManMobile'] ?? '';
        final int contactId = contactData['emergencyContactId'] ?? 0;
        
        if (name.isNotEmpty && phone.isNotEmpty && contactId != 0) {
          await dbHelper.saveContact(contactId, name, phone);
        }
      }
    }
  }
}
