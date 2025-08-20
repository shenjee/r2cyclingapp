[English](README.md) | [中文](README-zh.md)

# R2 Cycling App

R2 Cycling App 是一个专为骑行爱好者设计的开源综合性 Flutter 移动应用程序，为 Android 和 iOS 平台提供智能头盔集成和安全功能。

## 主要功能
🚴‍♂️ 智能头盔集成
- 与智能头盔的蓝牙配对（EH201 系列）
- 设备管理和控制（音量、照明）
- 蓝牙电话和音乐功能

📞 群组通信
- 使用 4 位数字代码创建和加入骑行群组
- 使用 Agora RTC 技术进行实时群组语音对讲

🆘 紧急安全系统
- SOS 紧急联系人管理
- 自动跌倒检测和位置分享
- 向紧急联系人发送带位置信息的短信警报

👤 用户管理
- 用户注册和身份验证系统

🌐 多语言支持
- 完整的国际化支持（英文和中文）
- 本地化用户界面和内容

## 开源声明
本项目 R2 Cycling App 采用 Apache License 2.0 开源协议。
服务器端的实现代码不在开源范围，仅公开 API 文档，供开发者与厂商集成使用。

✅ 你可以自由地：
	•	将本App源代码用于个人或商业产品；
	•	修改、分发、再发布本代码；
	•	在产品中集成R2Cycling的API，需遵循文档规范。

⚠️ 你需要遵守：
	•	在分发本代码或衍生作品时，保留原始的版权与许可证声明；
	•	如果修改了代码，需要在 NOTICE 文件中标明；
	•	使用本项目的过程中，不自动获得“R2Cycling”及其 Logo 的商标使用权；
	•	若对项目提交代码贡献，则视为同意授予相应的专利授权（见 Apache-2.0 协议条款）。

❌ 不包括：
	•	本仓库不包含服务器端实现代码；
	•	本开源协议不授予任何商标使用权；
	•	与本项目API交互所需的生产环境服务由各厂商自行部署或使用官方服务。

详见 [LICENSE](LICENSE) 文件。

## 快速开始指南

### 前置要求

开始之前，请确保您已安装以下软件：
- **Flutter SDK** (>=3.4.3)：[安装 Flutter](https://docs.flutter.dev/get-started/install)
- **Dart SDK**（Flutter 自带）
- **Android Studio** 或 **Xcode**（用于 iOS 开发）
- **Git** 版本控制工具

### 1. 下载源代码

```bash
# 克隆仓库
git clone https://github.com/your-username/r2cyclingapp.git
cd r2cyclingapp
```

### 2. 设置开发环境

#### Android 开发：
- 安装 [Android Studio](https://developer.android.com/studio)
- 安装 Android SDK（API 级别 21 或更高）
- 设置 Android 设备或模拟器

#### iOS 开发（仅限 macOS）：
- 从 App Store 安装 [Xcode](https://developer.apple.com/xcode/)
- 安装 Xcode 命令行工具：`xcode-select --install`
- 设置 iOS 设备或模拟器

### 3. 安装所需包

```bash
# 获取 Flutter 依赖
flutter pub get

# 验证 Flutter 安装
flutter doctor
```

### 4. 预编译设置

#### 配置权限（重要！）：
此应用需要多项权限才能正常运行：

**Android**：权限通过 `android/app/src/main/AndroidManifest.xml` 自动处理

**iOS**：更新 `ios/Runner/Info.plist` 添加所需权限：
- 蓝牙使用权限
- 位置访问权限
- 麦克风访问权限
- 短信发送权限

#### API 配置：
更新 `lib/constants.dart` 中的 API 端点，指向您的后端服务。

### 5. 构建和编译

#### Android：
```bash
# 调试构建
flutter run

# 发布 APK
flutter build apk --release

# 发布 App Bundle（推荐用于 Play Store）
flutter build appbundle --release
```

#### iOS：
```bash
# 调试构建
flutter run

# 发布构建
flutter build ios --release
```

### 6. 部署到设备

#### Android 设备：
1. 在 Android 设备上启用开发者选项和 USB 调试
2. 通过 USB 连接设备
3. 运行：`flutter run` 或从 `build/app/outputs/flutter-apk/` 安装 APK

#### iPhone：
1. 通过 USB 连接 iPhone
2. 在设备上信任此计算机
3. 在 Xcode 中打开 `ios/Runner.xcworkspace`
4. 选择您的设备并点击"运行"
5. 您可能需要在 Xcode 中配置代码签名

### 7. 故障排除

**常见问题：**
- **Flutter Doctor 问题**：运行 `flutter doctor` 并按照建议操作
- **依赖冲突**：尝试 `flutter clean && flutter pub get`
- **iOS 代码签名**：确保您有有效的 Apple 开发者账户
- **Android 构建问题**：检查 Android SDK 和构建工具版本

**关键依赖：**
- Agora RTC Engine（用于语音通信）
- Flutter Reactive BLE（用于蓝牙连接）
- Geolocator（用于位置服务）
- Permission Handler（用于运行时权限）

### 8. 开发提示

- 使用 `flutter run --hot-reload` 进行快速开发
- 使用 `flutter logs` 进行调试
- 在 Android 和 iOS 设备上测试以确保最佳兼容性
- 确保授予所有必需权限以实现完整功能
更多 Flutter 开发资源，请访问[官方文档](https://docs.flutter.dev/)。

## 仓库目录树

```
r2cyclingapp/                    # 项目根目录
├── android/                     # Android 平台配置
│   ├── app/                     # Android 应用模块
│   │   ├── build.gradle         # Android 应用构建配置
│   │   └── src/                 # Android 源代码
│   ├── build.gradle             # Android 项目构建配置
│   ├── gradle/                  # Gradle 包装器
│   ├── gradle.properties        # Gradle 属性
│   └── settings.gradle          # Gradle 设置
├── ios/                         # iOS 平台配置
│   ├── Flutter/                 # Flutter iOS 配置
│   ├── Runner/                  # iOS 应用目标
│   │   ├── AppDelegate.swift    # iOS 应用委托
│   │   ├── Assets.xcassets/     # iOS 应用资源
│   │   ├── Base.lproj/          # iOS 本地化
│   │   └── Info.plist           # iOS 应用信息
│   ├── Runner.xcodeproj/        # Xcode 项目
│   └── RunnerTests/             # iOS 单元测试
├── lib/                         # Flutter Dart 源代码
│   ├── connection/              # 网络和蓝牙连接
│   │   ├── bt/                  # 蓝牙连接模块
│   │   └── http/                # HTTP API 连接模块
│   ├── database/                # 本地数据库管理
│   │   ├── r2_db_helper.dart    # SQLite 数据库助手
│   │   └── r2_storage.dart      # 本地存储工具
│   ├── devicemanager/           # 智能头盔设备管理
│   │   ├── r2_device.dart       # 设备模型
│   │   └── r2_device_manager.dart # 设备连接管理器
│   ├── emergency/               # 紧急和 SOS 功能
│   │   ├── contact_widget.dart  # 紧急联系人 UI
│   │   ├── emergency_contact_screen.dart # 紧急联系人屏幕
│   │   ├── r2_sms.dart          # 短信发送功能
│   │   ├── r2_sos_sender.dart   # SOS 消息发送器
│   │   └── sos_widget.dart      # SOS 按钮 UI
│   ├── group/                   # 群组通信功能
│   │   ├── create_group_screen.dart # 创建群组屏幕
│   │   ├── group_intercom_screen.dart # 群组对讲屏幕
│   │   ├── group_list_screen.dart # 群组列表屏幕
│   │   └── join_group_screen.dart # 加入群组屏幕
│   ├── intercom/                # 实时语音通信
│   │   └── r2_intercom_engine.dart # Agora RTC 引擎包装器
│   ├── l10n/                    # 国际化
│   │   └── app_localizations.dart # 应用本地化字符串
│   ├── login/                   # 用户认证
│   │   ├── login_base_screen.dart # 基础登录屏幕
│   │   ├── password_recover_screen.dart # 密码恢复
│   │   ├── password_setting_screen.dart # 密码设置
│   │   ├── user_login_screen.dart # 用户登录屏幕
│   │   ├── user_register_screen.dart # 用户注册屏幕
│   │   └── verification_screen.dart # 验证码屏幕
│   ├── permission/              # 应用权限管理
│   │   ├── permission_dialog.dart # 权限请求对话框
│   │   ├── r2_permission_manager.dart # 权限管理器
│   │   └── r2_permission_model.dart # 权限模型
│   ├── r2controls/              # 自定义 UI 组件
│   │   ├── r2_flash.dart        # 闪现消息组件
│   │   ├── r2_flat_button.dart  # 自定义按钮组件
│   │   ├── r2_loading_indicator.dart # 加载指示器
│   │   └── r2_user_text_field.dart # 自定义文本字段
│   ├── screens/                 # 主要应用屏幕
│   │   ├── device_pairing_screen.dart # 设备配对屏幕
│   │   ├── helmet_screen.dart   # 头盔管理屏幕
│   │   ├── home_screen.dart     # 主页屏幕
│   │   └── splash_screen.dart   # 应用启动屏幕
│   ├── service/                 # 后台服务
│   │   └── r2_background_service.dart # 后台任务服务
│   ├── settings/                # 应用设置和用户资料
│   │   ├── image_cut_screen.dart # 图像裁剪屏幕
│   │   ├── settings_screen.dart # 应用设置屏幕
│   │   └── user_profile_screen.dart # 用户资料屏幕
│   ├── usermanager/             # 用户管理
│   │   ├── r2_account.dart      # 用户账户模型
│   │   ├── r2_group.dart        # 群组模型
│   │   ├── r2_user_manager.dart # 用户管理服务
│   │   └── r2_user_profile.dart # 用户资料模型
│   ├── constants.dart           # 应用常量
│   └── main.dart                # 应用入口点
├── assets/                      # 静态资源
│   ├── icons/                   # 应用图标
│   └── images/                  # 应用图片
├── test/                        # 单元测试
│   └── widget_test.dart         # 组件测试
├── .gitignore                   # Git 忽略规则
├── .metadata                    # Flutter 元数据
├── analysis_options.yaml        # Dart 分析选项
├── pubspec.yaml                 # Flutter 依赖
├── pubspec.lock                 # 依赖锁定文件
├── LICENSE                      # Apache License 2.0
├── README.md                    # 英文文档
└── README-zh.md                 # 中文文档
```

## R2 Cycling App 中的蓝牙配对工作流程是怎样的？
蓝牙配对遵循两阶段流程：首先进行 BLE 发现，然后进行经典蓝牙配对以支持音频配置文件。

### 1. 蓝牙配对相关文件

**核心实现文件：**
- `lib/connection/bt/r2_bluetooth_model.dart` - 处理 BLE 和经典蓝牙的主要蓝牙模型
- `lib/devicemanager/r2_device_manager.dart` - 设备管理和配对编排
- `lib/screens/device_pairing_screen.dart` - 设备扫描和选择的用户界面
- `android/app/src/main/kotlin/com/rockroad/r2cyclingapp/MainActivity.kt` - Android 原生蓝牙配置文件
- `lib/permission/r2_permission_manager.dart` - 蓝牙权限处理

### 2. 库和文档

**主要蓝牙库：**
- **flutter_reactive_ble**：用于 BLE 操作（扫描、连接、数据传输）
  - 文档：https://pub.dev/packages/flutter_reactive_ble
- **flutter_blue_classic**：用于经典蓝牙操作（配对、音频配置文件）
  - 文档：https://pub.dev/packages/flutter_blue_classic
- **permission_handler**：用于运行时蓝牙权限
  - 文档：https://pub.dev/packages/permission_handler

### 3. 配对工作流程

**步骤 1：BLE 发现**
```
1. 请求蓝牙权限
2. 开始 BLE 扫描，使用品牌过滤器（例如 'EH201'）
3. 用户选择发现的 BLE 设备
4. 停止 BLE 扫描
```

**步骤 2：经典蓝牙配对**
```
1. 从 BLE 名称中提取设备标识符（最后 6 个字符）
2. 开始经典蓝牙扫描
3. 查找名称模式为 'Helmet-{标识符}' 的设备
4. 与经典蓝牙设备绑定
5. 启用 A2DP 和耳机音频配置文件
6. 将设备信息保存到本地数据库
```

### 4. 代码示例：更改产品型号

**将产品型号从 'EH201' 更改为其他型号：**

在 `lib/screens/device_pairing_screen.dart` 第 89 行：
```dart
// 当前代码：
_scannedDevices = _btManager.scanDevices(brand: 'EH201');

// 更改为新型号（例如 'EH202'）：
_scannedDevices = _btManager.scanDevices(brand: 'EH202');
```

在 `lib/connection/bt/r2_bluetooth_model.dart` 第 169 行（经典蓝牙配对逻辑）：
```dart
// 当前代码查找：
if (device.name!.startsWith('Helmet-$lastPart')) {

// 如果头盔命名约定发生变化，修改模式：
if (device.name!.startsWith('NewHelmet-$lastPart')) {
```

**关键要点：**
- EH201 是智能头盔的开发板型号
- 设备名称可由客户自定义（无严格格式要求）
