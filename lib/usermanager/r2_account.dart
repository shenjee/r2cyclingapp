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
import 'dart:io';

class R2Account {
  final int _uid;
  String _account; // User's phone number or email address
  String _nickname;
  String _phoneNumber;
  String _email;
  String _avatarPath; //
  bool isPasswdSet; // Indicates if password is set, not saved to database

  R2Account({
    required int uid,
    String? account,
    String? phoneNumber,
    String? email,
  })  : _uid = uid,
        _account = account ?? '',
        _phoneNumber = phoneNumber ?? '',
        _email = email ?? '',
        _nickname = _generateDefaultNickname(account ?? ''),
        _avatarPath = '',
        isPasswdSet = false;

  // Getter for id
  int get uid => _uid;

  // Getter for account (generally should not be modified except during initialization)
  String get account => _account;
  set account(String value) {
    _account = value;
  }

  // Getter for phone number (generally should not be modified except during initialization)
  String get phoneNumber => _phoneNumber;
  set phoneNumber(String value) {
    _phoneNumber = value;
  }

  // Getter for email (generally should not be modified except during initialization)
  String get email => _email;
  set email(String value) {
    _email = value;
  }

  // Getter and Setter for nickname
  String get nickname => _nickname;
  set nickname(String value) {
    _nickname = value;
  }

  // Getter and Setter for avatarPath
  String get avatarPath => _avatarPath;
  set avatarPath(String value) {
    _avatarPath = value;
  }

  // Getter for icon
  Future<Image> getAvatar() async {
    if (_avatarPath.isEmpty || !await File(_avatarPath).exists()) {
      // Return default image if no custom avatar is found
      return Image.asset('assets/icons/default_avatar.png');
    } else {
      // Load custom avatar from the file
      return Image.file(File(_avatarPath));
    }
  }

  // Save a custom icon and update the path
  Future<void> saveAvatar(File avatarFile) async {
    // Save the avatar to the specified path
    await avatarFile.copy(_avatarPath);
  }

  // Private helper method to generate the default nickname
  static String _generateDefaultNickname(String account) {
    if (_isPhoneNumber(account)) {
      // Last 4 digits of the phone number
      return account.substring(account.length - 4);
    } else if (_isEmailAddress(account)) {
      // The part of the email before "@"
      return account.split('@').first;
    } else {
      return 'User';
    }
  }

  // Private helper method to check if the account is a phone number
  static bool _isPhoneNumber(String account) {
    final phoneNumberPattern =
        RegExp(r'^\d{10,}$'); // A simple pattern for phone numbers
    return phoneNumberPattern.hasMatch(account);
  }

  // Private helper method to check if the account is an email address
  static bool _isEmailAddress(String account) {
    final emailPattern =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailPattern.hasMatch(account);
  }

  // Convert R2Account to Map
  Map<String, dynamic> toMap() {
    return {
      'uid': _uid,
      'account': _account,
      'phoneNumber': _phoneNumber,
      'email': _email,
      'nickname': _nickname,
      'avatarPath': _avatarPath,
      'isPasswdSet': isPasswdSet ? 1 : 0,
    };
  }

  // Create R2Account from Map
  factory R2Account.fromMap(Map<String, dynamic> map) {
    return R2Account(uid: map['uid'], account: map['account'])
      ..phoneNumber = map['phoneNumber']
      ..email = map['email']
      ..nickname = map['nickname']
      ..avatarPath = map['avatarPath']
      ..isPasswdSet = (map['isPasswdSet'] ?? 0) == 1;
  }
}
