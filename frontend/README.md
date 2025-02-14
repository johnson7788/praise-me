# 在哪里运行当前的flutter项目
flutter run

# 进入项目目录，然后直接使用chrome运行项目
flutter run -d chrome
flutter run -d macOS  # 你想运行在 macOS 设备上


# 前端目录结构
lib/
    ai_praise/
        direct_praise.dart     // 直接夸
        hint_praise.dart       // 提示夸
        voice_praise.dart      // 语音夸
        photo_praise.dart      // 拍拍夸
        style_praise.dart      // 风格夸
    config.dart //配置文件
    main.dart  //程序入口
    language_provider.dart   //状态文件，存储当前用户切换的语言
