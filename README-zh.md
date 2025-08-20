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

详见 LICENSE 文件。

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
