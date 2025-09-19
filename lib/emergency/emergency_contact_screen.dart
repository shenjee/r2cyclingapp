// Copyright (c) 2025 RockRoad Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'package:r2cyclingapp/database/r2_db_helper.dart';
import 'package:r2cyclingapp/database/r2_storage.dart';
import 'package:r2cyclingapp/connection/http/r2_http_request.dart';
import 'package:r2cyclingapp/l10n/app_localizations.dart';
import 'package:r2cyclingapp/constants.dart';

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

    // enable / disable its emegency function remotely
    await _requestEnableEmergency(value);
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
              Expanded (
                child: Padding(
                  padding:const EdgeInsets.fromLTRB(20.0, 20.0, 0.0, 10.0),
                  child:Text(
                    AppLocalizations.of(context)!.sosEmergency, 
                    style: const TextStyle(fontSize: 24.0),
                    ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(00.0, 20.0, 20.0, 10.0),
                child:Switch(
                  value: isEmergencyContactEnabled,
                  activeTrackColor: AppConstants.primaryColor200,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 0.0),
            child:Text(
              AppLocalizations.of(context)!.sosDescription,
              style: const TextStyle(
                fontSize: 16.0,
                color: AppConstants.textColor,
              ),
            ),
          ),
        if (isEmergencyContactEnabled) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 10.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppLocalizations.of(context)!.sosEmergencyContact,
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          _buildContactList(),
        ],
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
          SizedBox(
            height: 100.0,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
              leading: Container(
                width: 60.0,
                height: 60.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppConstants.primaryColor200,
                    width: 2.5,
                  ),
                  color: Colors.transparent,
                ),
                child: Center(
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      color: AppConstants.primaryColor200,
                      fontSize: 22.0,
                    ),
                  ),
                ),
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
        SizedBox(
          height: 100.0,
          child:ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
            leading: Container(
              width: 60.0,
              height: 60.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppConstants.primaryColor200,
                  width: 2.5,
                ),
                color: Colors.transparent,
              ),
              child: const Center(
                child: Icon(Icons.add, color: AppConstants.primaryColor200,),
              ),
            ),
            title: Text(
              AppLocalizations.of(context)!.addEmergencyContact,
              style: const TextStyle(fontSize: 22.0),
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
        title: Text(AppLocalizations.of(context)!.sosEmergency),
        centerTitle: true,
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

    // the following methods handle the data of contacts
  // fixme: the following methods are should be in a separate class
  
  Future<int> _requestEnableEmergency(bool enabled) async {
    int errorRet = 0;
    final token = await R2Storage.read('authtoken');
    final request = R2HttpRequest();
    final response = await request.postRequest(
      api: 'member/switchContactEnabled',
      token: token,
      body: {
        'emergencyContactEnabled': enabled? 'true':'false',
      }
    );

    if (false == response.success) {
      errorRet = response.code;
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
