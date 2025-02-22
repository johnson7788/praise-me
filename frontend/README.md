# 在哪里运行当前的flutter项目
flutter run

# 进入项目目录，然后直接使用chrome运行项目
flutter run -d chrome
flutter run -d macOS  # 你想运行在 macOS 设备上


# 注释掉Photo和直接夸，不太重要

# 前端目录结构
lib/
    ai_praise/
        direct_praise.dart       // 直接夸
        achievement_praise.dart  // 成就夸
        animate_praise.dart        //动图夸
        photo_praise.dart        // 拍拍夸
        star_praise.dart         // 明星夸
        leaderboard.dart         // 排行榜
        vote_you.dart            //为你点赞
    l10n/
        intl_en.art         //英语语言
        intl_zh.art         //中文语言
        intl_ja.art         //日语语言
    config.dart //配置文件
    main.dart  //程序入口
    language_provider.dart   //状态文件，存储当前用户切换的语言
