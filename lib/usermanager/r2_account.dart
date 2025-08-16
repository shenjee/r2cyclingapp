import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

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
  }) : _uid = uid,
        _account = account ?? '',
        _phoneNumber = phoneNumber ?? '',
        _email = email ?? '',
        _nickname = _generateDefaultNickname(account ?? ''),
        _avatarPath = '',
        isPasswdSet = false;

  // Getter for id
  int get uid => _uid;

  // Getter for account (cannot be modified)
  String get account => _account;
  set account(String value) {
    _account = value;
  }

  // Getter for phone number (cannot be modified)
  String get phoneNumber => _phoneNumber;
  set phoneNumber(String value) {
    _phoneNumber = value;
  }

  // Getter for email (cannot be modified)
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
    final directory = await getTemporaryDirectory();
    _avatarPath = '${directory.path}/avatar_${_account.hashCode}.png';

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
      return account
          .split('@')
          .first;
    } else {
      return 'User';
    }
  }

  // Private helper method to check if the account is a phone number
  static bool _isPhoneNumber(String account) {
    final phoneNumberPattern = RegExp(
        r'^\d{10,}$'); // A simple pattern for phone numbers
    return phoneNumberPattern.hasMatch(account);
  }

  // Private helper method to check if the account is an email address
  static bool _isEmailAddress(String account) {
    final emailPattern = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
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