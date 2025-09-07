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

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('zh', 'CN'),
  ];

  // Authentication & Registration
  String get registerLogin => _localizedValues[locale.languageCode]!['register_login']!;
  String get phoneNumberFormatError => _localizedValues[locale.languageCode]!['phone_number_format_error']!;
  String get phoneOrCodeFormatError => _localizedValues[locale.languageCode]!['phone_or_code_format_error']!;
  String get codeFormatError => _localizedValues[locale.languageCode]!['code_format_error']!;
  String get phoneFormatError => _localizedValues[locale.languageCode]!['phone_format_error']!;
  String get getVerificationCode => _localizedValues[locale.languageCode]!['get_verification_code']!;
  String get enterPhoneNumber => _localizedValues[locale.languageCode]!['enter_phone_number']!;
  String get enterVerificationCode => _localizedValues[locale.languageCode]!['enter_verification_code']!;
  String get nextStep => _localizedValues[locale.languageCode]!['next_step']!;
  String get resetPassword => _localizedValues[locale.languageCode]!['reset_password']!;
  String get passwordLogin => _localizedValues[locale.languageCode]!['password_login']!;
  String get unregisteredPhoneAutoCreate => _localizedValues[locale.languageCode]!['unregistered_phone_auto_create']!;
  String get setPassword => _localizedValues[locale.languageCode]!['set_password']!;
  String get login => _localizedValues[locale.languageCode]!['login']!;
  String get phonePasswordFormatError => _localizedValues[locale.languageCode]!['phone_password_format_error']!;
  String get passwordFormatError => _localizedValues[locale.languageCode]!['password_format_error']!;
  String get enterPassword => _localizedValues[locale.languageCode]!['enter_password']!;
  String get verificationCodeLogin => _localizedValues[locale.languageCode]!['verification_code_login']!;
  String get forgotPassword => _localizedValues[locale.languageCode]!['forgot_password']!;
  String get save => _localizedValues[locale.languageCode]!['save']!;
  String get passwordMismatch => _localizedValues[locale.languageCode]!['password_mismatch']!;
  String get passwordRequirement => _localizedValues[locale.languageCode]!['password_requirement']!;
  String get passwordHint => _localizedValues[locale.languageCode]!['password_hint']!;
  String get enterNewPassword => _localizedValues[locale.languageCode]!['enter_new_password']!;
  String get confirmAgain => _localizedValues[locale.languageCode]!['confirm_again']!;
  String get agreeTermsAndPrivacy => _localizedValues[locale.languageCode]!['agree_terms_and_privacy']!;

  String get termsOfService => _localizedValues[locale.languageCode]!['terms_of_service']!;

  String get privacyPolicy => _localizedValues[locale.languageCode]!['privacy_policy']!;

  String get needFollowingPermissions => _localizedValues[locale.languageCode]!['need_following_permissions']!;
  String get bluetooth => _localizedValues[locale.languageCode]!['bluetooth']!;
  String get bluetoothDesc => _localizedValues[locale.languageCode]!['bluetooth_desc']!;
  String get microphone => _localizedValues[locale.languageCode]!['microphone']!;
  String get microphoneDesc => _localizedValues[locale.languageCode]!['microphone_desc']!;
  String get locationInfo => _localizedValues[locale.languageCode]!['location_info']!;
  String get locationDesc => _localizedValues[locale.languageCode]!['location_desc']!;
  String get confirm => _localizedValues[locale.languageCode]!['confirm']!;

  // Group & Intercom
  String get exitGroupMessage => _localizedValues[locale.languageCode]!['exit_group_message']!;
  String get letNearbyRiders => _localizedValues[locale.languageCode]!['let_nearby_riders']!;
  String get joinSameGroup => _localizedValues[locale.languageCode]!['join_same_group']!;
  String get groupNumber => _localizedValues[locale.languageCode]!['group_number']!;
  String get intercomActive => _localizedValues[locale.languageCode]!['intercom_active']!;
  String get cyclingIntercom => _localizedValues[locale.languageCode]!['cycling_intercom']!;
  String get exitCyclingGroup => _localizedValues[locale.languageCode]!['exit_cycling_group']!;
  String get createCyclingGroup => _localizedValues[locale.languageCode]!['create_cycling_group']!;
  String get joinCyclingGroup => _localizedValues[locale.languageCode]!['join_cycling_group']!;
  String get enterCyclingGroup => _localizedValues[locale.languageCode]!['enter_cycling_group']!;
  String get enterFourDigitCode => _localizedValues[locale.languageCode]!['enter_four_digit_code']!;

  // Emergency Contact
  String get addEmergencyContact => _localizedValues[locale.languageCode]!['add_emergency_contact']!;
  String get emergencyContact => _localizedValues[locale.languageCode]!['emergency_contact']!;
  String get sosEmergencyContactDesc => _localizedValues[locale.languageCode]!['sos_emergency_contact_desc']!;
  String get name => _localizedValues[locale.languageCode]!['name']!;
  String get phone => _localizedValues[locale.languageCode]!['phone']!;
  String get delete => _localizedValues[locale.languageCode]!['delete']!;
  String get sosEmergency => _localizedValues[locale.languageCode]!['sos_emergency']!;
  String get sosEmergencyContact => _localizedValues[locale.languageCode]!['sos_emergency_contact']!;
  String get sosDescription => _localizedValues[locale.languageCode]!['sos_description']!;
  String get emergencyContactTitle => _localizedValues[locale.languageCode]!['emergency_contact_title']!;
  String get emergencyContactStatus => _localizedValues[locale.languageCode]!['emergency_contact_status']!;
  String get enabled => _localizedValues[locale.languageCode]!['enabled']!;
  String get disabled => _localizedValues[locale.languageCode]!['disabled']!;

  // Settings
  String get aboutR2Cycling => _localizedValues[locale.languageCode]!['about_r2_cycling']!;
  String get appDescription => _localizedValues[locale.languageCode]!['app_description']!;
  String get version => _localizedValues[locale.languageCode]!['version']!;
  String get companyInfo => _localizedValues[locale.languageCode]!['company_info']!;
  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get personalCenter => _localizedValues[locale.languageCode]!['personal_center']!;
  String get avatar => _localizedValues[locale.languageCode]!['avatar']!;
  String get logout => _localizedValues[locale.languageCode]!['logout']!;
  String get crop => _localizedValues[locale.languageCode]!['crop']!;
  String get cancel => _localizedValues[locale.languageCode]!['cancel']!;
  String get takePhoto => _localizedValues[locale.languageCode]!['take_photo']!;
  String get selectFromAlbum => _localizedValues[locale.languageCode]!['select_from_album']!;
  String get cyclingCard => _localizedValues[locale.languageCode]!['cycling_card']!;
  String get changeAvatar => _localizedValues[locale.languageCode]!['change_avatar']!;
  String get nickname => _localizedValues[locale.languageCode]!['nickname']!;
  String get modifyNickname => _localizedValues[locale.languageCode]!['modify_nickname']!;
  String get enterNewNickname => _localizedValues[locale.languageCode]!['enter_new_nickname']!;
  String get accountManagement => _localizedValues[locale.languageCode]!['account_management']!;

  // Bluetooth & Helmet
  String get startConnectHelmet => _localizedValues[locale.languageCode]!['start_connect_helmet']!;
  String get selectYourHelmet => _localizedValues[locale.languageCode]!['select_your_helmet']!;
  String get connectingHelmet => _localizedValues[locale.languageCode]!['connecting_helmet']!;
  String get ensureBluetoothOn => _localizedValues[locale.languageCode]!['ensure_bluetooth_on']!;
  String get longPressHelmetButton => _localizedValues[locale.languageCode]!['long_press_helmet_button']!;
  String get bringPhoneClose => _localizedValues[locale.languageCode]!['bring_phone_close']!;
  String get startConnect => _localizedValues[locale.languageCode]!['start_connect']!;
  String get clickAddHelmet => _localizedValues[locale.languageCode]!['click_add_helmet']!;
  String get unbind => _localizedValues[locale.languageCode]!['unbind']!;
  String get volume => _localizedValues[locale.languageCode]!['volume']!;
  String get lighting => _localizedValues[locale.languageCode]!['lighting']!;

  // SOS
  String get sending => _localizedValues[locale.languageCode]!['sending']!;
  String get sendComplete => _localizedValues[locale.languageCode]!['send_complete']!;
  String get sendImmediately => _localizedValues[locale.languageCode]!['send_immediately']!;
  String get complete => _localizedValues[locale.languageCode]!['complete']!;
  String get sosMessageTemplate => _localizedValues[locale.languageCode]!['sos_message_template']!;

  // Home Screen
  String get emergencyContactHome => _localizedValues[locale.languageCode]!['emergency_contact_home']!;
  String get confirmExitGroup => _localizedValues[locale.languageCode]!['confirm_exit_group']!;
  String get exit => _localizedValues[locale.languageCode]!['exit']!;
  String get holdToTalk => _localizedValues[locale.languageCode]!['hold_to_talk']!;
  String get talking => _localizedValues[locale.languageCode]!['talking']!;
  String get notJoinedGroup => _localizedValues[locale.languageCode]!['not_joined_group']!;

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'register_login': 'Register / Login',
      'phone_number_format_error': 'Phone number format error',
      'phone_or_code_format_error': 'Phone number or verification code format error',
      'code_format_error': 'Verification code format error',
      'phone_format_error': 'Phone number format error',
      'get_verification_code': 'Get Code',
      'enter_phone_number': 'Phone number',
      'enter_verification_code': '6-digit code',
      'next_step': 'Next',
      'reset_password': 'Reset Password',
      'password_login': 'Password Login',
      'unregistered_phone_auto_create': 'Verfication with an unregistered phone number \nwill automatically create an R2 account\n',
      'set_password': 'Set Password',
      'login': 'Login',
      'phone_password_format_error': 'Phone number and password format error',
      'password_format_error': 'Password must be at least 6 characters with numbers and letters',
      'enter_password': 'Password',
      'verification_code_login': 'Verification Code Login',
      'forgot_password': 'Forgot Password?',
      'save': 'Save',
      'password_mismatch': 'Passwords do not match',
      'password_requirement': 'Password must be at least 8 characters with numbers and letters',
      'password_hint': 'Password must be at least 8 characters, including numbers and letters\n',
      'enter_new_password': 'New password',
      'confirm_again': 'Confirm again',
      'agree_terms_and_privacy': 'I agree to the Terms of Service & Privacy Policy',      'terms_of_service': 'Terms of Service',
      'privacy_policy': 'Privacy Policy',
      'need_following_permissions': 'Need the following permissions',
      'bluetooth': 'Bluetooth',
      'bluetooth_desc': 'Connect to your smart helmet',
      'microphone': 'Microphone',
      'microphone_desc': 'Turn on microphone for network intercom',
      'location_info': 'Location Information',
      'location_desc': 'Send location information to your emergency contacts',
      'confirm': 'Confirm',
      'exit_group_message': 'You have exited the cycling group',
      'let_nearby_riders': 'Let nearby riders enter the 4-digit code below,',
      'join_same_group': 'to join the same cycling group,',
      'group_number': 'Group Number:',
      'intercom_active': 'Intercom Active',
      'cycling_intercom': 'Intercom',
      'exit_cycling_group': 'Exit Cycling Group',
      'create_cycling_group': 'Create Group',
      'join_cycling_group': 'Join Group',
      'enter_cycling_group': 'Enter Cycling Group',
      'enter_four_digit_code': 'Enter four-digit group code',
      'add_emergency_contact': 'Add Emergency Contact',
      'emergency_contact': 'Emergency Contact',
      'sos_emergency_contact_desc': 'To enable SOS emergency contact, you need to add at least one emergency contact.',
      'name': 'Name',
      'phone': 'Phone',
      'delete': 'Delete',
      'sos_emergency': 'Emergency SOS',
      'sos_emergency_contact': 'Emergency Contact',
      'sos_description': 'Your emergency contacts will receive a message saying that you have experienced an unexpected fall during your ride when you use Emergency SOS. Your current location will be included in these messages.',
      'emergency_contact_title': 'Emergency SOS',
      'emergency_contact_status': 'Emergency Contact',
      'enabled': 'On',
      'disabled': 'Off',
      'about_r2_cycling': 'About R2 Cycling App',
      'app_description': 'R2 Cycling App is an open-source flutter-based mobile application, providing smart helmet integration and intercom features for both Android and iOS platforms.\n\nR2 Cycling App is released under the Apache License 2.0, and the source code is available on GitHub.',
      'version': 'Version',
      'company_info': 'Designed & developed by RockRoad Tech.',
      'settings': 'Settings',
      'personal_center': 'Personal Center',
      'avatar': 'Avatar',
      'logout': 'Logout',
      'crop': 'Crop',
      'cancel': 'Cancel',
      'take_photo': 'Take Photo',
      'select_from_album': 'Select from Album',
      'cycling_card': 'Cycling Card',
      'change_avatar': 'Change Avatar',
      'nickname': 'Nickname',
      'modify_nickname': 'Modify Nickname',
      'enter_new_nickname': 'Enter new nickname',
      'account_management': 'Account',
      'start_connect_helmet': 'Connect to smart helmet',
      'select_your_helmet': 'Select your smart helmet',
      'connecting_helmet': 'Connecting your smart helmet',
      'ensure_bluetooth_on': 'Make sure your phone\'s bluetooth is turned on',
      'long_press_helmet_button': 'Long press the power button on your smart helmet, until \nyou hear the "pairing" prompt',
      'bring_phone_close': 'Bring your phone close to your smart helmet',
      'start_connect': 'Connect',
      'click_add_helmet': 'Tap to add your smart helmet',
      'unbind': 'Unbind',
      'volume': 'Volume:',
      'lighting': 'Lighting:',
      'sending': 'Sending',
      'send_complete': 'Send Complete',
      'send_immediately': 'Send Immediately',
      'complete': 'Complete',
      'sos_message_template': '[R2 Cycling] Your friend fell while cycling, click to view location:',
      'emergency_contact_home': 'Emergency SOS',
      'confirm_exit_group': 'Are you sure you want to exit the cycling group?',
      'exit': 'Exit',
      'hold_to_talk': 'Hold to Talk',
      'talking': 'Talking',
      'not_joined_group': 'No groups',
    },
    'zh': {
      'register_login': '注册/登录',
      'phone_number_format_error': '手机号码格式错误',
      'phone_or_code_format_error': '手机号或验证码输入格式有误',
      'code_format_error': '验证码输入格式有误',
      'phone_format_error': '手机号输入格式有误',
      'get_verification_code': '获取验证码',
      'enter_phone_number': '请输入手机号',
      'enter_verification_code': '请输入验证码',
      'next_step': '下一步',
      'reset_password': '重置密码',
      'password_login': '密码登录',
      'unregistered_phone_auto_create': '未注册的手机号验证后自动创建R2账户\n\n',
      'set_password': '设置密码',
      'login': '登录',
      'phone_password_format_error': '手机号和密码输入格式有误',
      'password_format_error': '密码为不少于8位的数字和字符组合',
      'enter_password': '请输入密码',
      'verification_code_login': '验证码登录',
      'forgot_password': '忘记密码？',
      'save': '保存',
      'password_mismatch': '两次密码输入不一致',
      'password_requirement': '密码为不少于6位的数字和字符组合',
      'password_hint': '密码至少8位，包含数字和字母\n',
      'enter_new_password': '输入新密码',
      'confirm_again': '再次确认',
      'agree_terms_and_privacy': '我已同意《用户协议》和《隐私策略》',
      'terms_of_service': '用户协议',
      'privacy_policy': '隐私策略',
      'need_following_permissions': '需要获取以下权限',
      'bluetooth': '蓝牙',
      'bluetooth_desc': '连接您的智能头盔',
      'microphone': '麦克风',
      'microphone_desc': '打开麦克风进行网络对讲',
      'location_info': '位置信息',
      'location_desc': '位置信息发送给你的紧急联系人',
      'confirm': '确定',
      'exit_group_message': '您已退出该骑行组',
      'let_nearby_riders': '让身边的骑友输入下方四位编号，',
      'join_same_group': '加入同一个骑行组，',
      'group_number': '组编号：',
      'intercom_active': '正在对讲',
      'cycling_intercom': '骑行对讲',
      'exit_cycling_group': '退出骑行组',
      'create_cycling_group': '创建骑行组',
      'join_cycling_group': '加入骑行组',
      'enter_cycling_group': '进入骑行组',
      'enter_four_digit_code': '输入四位组编号',
      'add_emergency_contact': '添加紧急联系人',
      'emergency_contact': '紧急联系人',
      'sos_emergency_contact_desc': '开启SOS紧急联络，需要添加至少一名紧急联系人。',
      'name': '姓名',
      'phone': '电话',
      'delete': '删除',
      'sos_emergency': 'SOS紧急联络',
      'sos_emergency_contact': '紧急联系人',
      'sos_description': '开启SOS紧急联络，您在骑行过程中若摔倒，将自动将您的位置信息以短信方式发给您的紧急联系人，并尝试拨打紧急联系人的电话。',
      'emergency_contact_title': 'SOS 紧急联络',
      'emergency_contact_status': '紧急联络',
      'enabled': '已开启',
      'disabled': '已关闭',
      'about_r2_cycling': '关于R2骑行助手',
      'app_description': 'R2骑行助手是基于Flutter技术的代码开源的移动App，提供智能头盔绑定和对讲功能，适配Android和iOS平台。\n\nR2骑行助手基于Apache License 2.0许可证发布，源代码可在GitHub上获取。',
      'version': '版本',
      'company_info': '洛克之路（深圳）科技有限责任公司 设计开发',
      'settings': '设置',
      'personal_center': '个人中心',
      'avatar': '头像',
      'logout': '退出登录',
      'crop': '裁剪',
      'cancel': '取消',
      'take_photo': '拍照',
      'select_from_album': '从手机相册选择',
      'cycling_card': '骑行名片',
      'change_avatar': '更换头像',
      'nickname': '昵称',
      'modify_nickname': '修改昵称',
      'enter_new_nickname': '请输入新的昵称',
      'account_management': '账号管理',
      'start_connect_helmet': '开始连接您的智能头盔',
      'select_your_helmet': '请选择您的智能头盔',
      'connecting_helmet': '正在连接您的智能头盔',
      'ensure_bluetooth_on': '确保手机蓝牙已开启',
      'long_press_helmet_button': '长按智能头盔的开机键，\n直至听到"配对"提示音',
      'bring_phone_close': '将手机紧靠您的智能头盔',
      'start_connect': '开始连接',
      'click_add_helmet': '点击添加您的智能头盔',
      'unbind': '解除绑定',
      'volume': '音量：',
      'lighting': '灯光：',
      'sending': '正在发送',
      'send_complete': '发送完成',
      'send_immediately': '立即发送',
      'complete': '完成',
      'sos_message_template': '【R2 Cycling】您的好友骑行时摔倒了，点击查看位置：',
      'emergency_contact_home': '紧急联络',
      'confirm_exit_group': '确定要退出骑行组吗？',
      'exit': '退出',
      'hold_to_talk': '按住说话',
      'talking': '正在对讲',
      'not_joined_group': '未加入组',
    },
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'zh'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}