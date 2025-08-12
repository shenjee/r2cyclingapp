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

  // Permissions
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

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'register_login': 'Register/Login',
      'phone_number_format_error': 'Phone number format error',
      'phone_or_code_format_error': 'Phone number or verification code format error',
      'code_format_error': 'Verification code format error',
      'phone_format_error': 'Phone number format error',
      'get_verification_code': 'Get Verification Code',
      'enter_phone_number': 'Enter phone number',
      'enter_verification_code': 'Enter verification code',
      'next_step': 'Next',
      'reset_password': 'Reset Password',
      'password_login': 'Password Login',
      'unregistered_phone_auto_create': 'Unregistered phone numbers will automatically create an R2 account after verification\n\n',
      'set_password': 'Set Password',
      'login': 'Login',
      'phone_password_format_error': 'Phone number and password format error',
      'password_format_error': 'Password must be at least 6 characters with numbers and letters',
      'enter_password': 'Enter password',
      'verification_code_login': 'Verification Code Login',
      'forgot_password': 'Forgot Password?',
      'save': 'Save',
      'password_mismatch': 'Passwords do not match',
      'password_requirement': 'Password must be at least 6 characters with numbers and letters',
      'password_hint': 'Password must be at least 6 characters, including numbers and letters\n',
      'enter_new_password': 'Enter new password',
      'confirm_again': 'Confirm again',
      'need_following_permissions': 'Need the following permissions',
      'bluetooth': 'Bluetooth',
      'bluetooth_desc': 'Connect to your smart helmet',
      'microphone': 'Microphone',
      'microphone_desc': 'Turn on microphone for network intercom',
      'location_info': 'Location Information',
      'location_desc': 'Send location information to your emergency contacts',
      'confirm': 'Confirm',
      'exit_group_message': 'You have exited the cycling group',
      'let_nearby_riders': 'Let nearby riders enter the four-digit code below,',
      'join_same_group': 'to join the same cycling group,',
      'group_number': 'Group Number:',
      'intercom_active': 'Intercom Active',
      'cycling_intercom': 'Cycling Intercom',
      'exit_cycling_group': 'Exit Cycling Group',
      'create_cycling_group': '  Create a Cycling Group',
      'join_cycling_group': '  Join a Cycling Group',
      'enter_cycling_group': 'Enter Cycling Group',
      'enter_four_digit_code': 'Enter four-digit group code',
      'add_emergency_contact': 'Add Emergency Contact',
      'emergency_contact': 'Emergency Contact',
      'sos_emergency_contact_desc': 'To enable SOS emergency contact, you need to add at least one emergency contact.',
      'name': 'Name',
      'phone': 'Phone',
      'delete': 'Delete',
      'sos_emergency_contact': 'SOS Emergency Contact',
      'sos_description': 'When SOS emergency contact is enabled, if you fall while cycling, your location information will be automatically sent to your emergency contacts via SMS, and we will attempt to call your emergency contacts.',
      'emergency_contact_title': 'SOS Emergency Contact',
      'emergency_contact_status': 'Emergency Contact',
      'enabled': 'Enabled',
      'disabled': 'Disabled',
      'about_r2_cycling': 'About R2 Cycling',
      'app_description': 'A smart companion designed for cycling enthusiasts, personalize your cycling equipment and make every ride full of fun.\nOur mission is to connect the cycling world, make communication more convenient, and make safety more secure.',
      'version': 'Version',
      'company_info': 'Designed and developed by Rock Road (Shenzhen) Technology Co., Ltd.',
      'settings': 'Settings',
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
      'start_connect_helmet': 'Start connecting your smart helmet',
      'select_your_helmet': 'Please select your smart helmet',
      'connecting_helmet': 'Connecting your smart helmet',
      'ensure_bluetooth_on': 'Make sure your phone\'s Bluetooth is turned on',
      'long_press_helmet_button': 'Long press the power button on your smart helmet,\nuntil you hear the "pairing" prompt',
      'bring_phone_close': 'Bring your phone close to your smart helmet',
      'start_connect': 'Start Connection',
      'click_add_helmet': 'Click to add your smart helmet',
      'unbind': 'Unbind',
      'volume': 'Volume:',
      'lighting': 'Lighting:',
      'sending': 'Sending',
      'send_complete': 'Send Complete',
      'send_immediately': 'Send Immediately',
      'complete': 'Complete',
      'sos_message_template': '[R2 Cycling] Your friend fell while cycling, click to view location:',
      'emergency_contact_home': 'Emergency Contact',
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
      'password_format_error': '密码为不少于6位的数字和字符组合',
      'enter_password': '请输入密码',
      'verification_code_login': '验证码登录',
      'forgot_password': '忘记密码？',
      'save': '保存',
      'password_mismatch': '两次密码输入不一致',
      'password_requirement': '密码为不少于6位的数字和字符组合',
      'password_hint': '密码至少6位，包含数字和字母\n',
      'enter_new_password': '输入新密码',
      'confirm_again': '再次确认',
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
      'create_cycling_group': '  建立一个骑行组',
      'join_cycling_group': '  加入一个骑行组',
      'enter_cycling_group': '进入骑行组',
      'enter_four_digit_code': '输入四位组编号',
      'add_emergency_contact': '添加紧急联系人',
      'emergency_contact': '紧急联系人',
      'sos_emergency_contact_desc': '开启SOS紧急联络，需要添加至少一名紧急联系人。',
      'name': '姓名',
      'phone': '电话',
      'delete': '删除',
      'sos_emergency_contact': 'SOS 紧急联络',
      'sos_description': '开启SOS紧急联络，您在骑行过程中若摔倒，将自动将您的位置信息以短信方式发给您的紧急联系人，并尝试拨打紧急联系人的电话。',
      'emergency_contact_title': 'SOS 紧急联络',
      'emergency_contact_status': '紧急联络',
      'enabled': '已开启',
      'disabled': '已关闭',
      'about_r2_cycling': '关于 R2 Cycling',
      'app_description': '专为骑行爱好者设计的智能伙伴，个性化您的骑行装备，让每次出行都充满乐趣。\n我们的使命是连接骑行世界，让沟通更便捷，让安全更有保障。',
      'version': '版本',
      'company_info': '洛克之路（深圳）科技有限责任公司 设计开发',
      'settings': '设置',
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