import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'ai_praise/direct_praise.dart';
import 'ai_praise/achievement_praise.dart';
import 'ai_praise/voice_praise.dart';
import 'ai_praise/photo_praise.dart';
import 'ai_praise/star_praise.dart';
import 'ai_praise/leaderboard.dart';
import 'language_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'config.dart'; // 确保导入配置

void main() {
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ],
        child: PraiseMeApp(),
      ),
    );
}

class PraiseMeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp(
          title: 'Praise Me',
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: languageProvider.locale,
          debugShowCheckedModeBanner: false,
          theme: _buildTheme(),
          home: HomePage(),
          routes: {
            '/direct': (context) => DirectPraisePage(),
            '/achievement': (context) => AchievementPraisePage(),
            '/voice': (context) => VoicePraisePage(),
            '/photo': (context) => PhotoPraisePage(),
            '/star': (context) => StarPraisePage(),
            '/leaderboard': (context) => LeaderboardPage(),
          },
        );
      },
    );
  }

  ThemeData _buildTheme() {
    final base = ThemeData.light();
    return base.copyWith(
      primaryColor: Colors.pink,
      colorScheme: base.colorScheme.copyWith(
        secondary: Colors.amber,
      ),
      textTheme: _buildTextTheme(base.textTheme),
    );
  }

  TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
      headlineSmall: base.headlineSmall!.copyWith(
        fontWeight: FontWeight.w500,
      ),
      titleLarge: base.titleLarge!.copyWith(
        fontSize: 18.0,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<NavItem> _navItems; // 延迟初始化

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _navItems = _buildNavItems(); // 在 didChangeDependencies 中初始化
  }

  List<NavItem> _buildNavItems() {
    return [
      NavItem(
        icon: Icons.record_voice_over,
        label: (context) => AppLocalizations.of(context)!.directPraise, // 使用 AppLocalizations
        route: '/direct',
        color: Colors.blue,
      ),
      NavItem(
        icon: Icons.lightbulb,
        label: (context) => AppLocalizations.of(context)!.achievementPraise,
        route: '/achievement',
        color: Colors.green,
      ),
      NavItem(
        icon: Icons.mic,
        label: (context) => AppLocalizations.of(context)!.voicePraise,
        route: '/voice',
        color: Colors.orange,
      ),
      NavItem(
        icon: Icons.camera_alt,
        label: (context) => AppLocalizations.of(context)!.photoPraise,
        route: '/photo',
        color: Colors.red,
      ),
      NavItem(
        icon: Icons.palette,
        label: (context) => AppLocalizations.of(context)!.starPraise,
        route: '/star',
        color: Colors.purple,
      ),
      NavItem(
        icon: Icons.star,
        label: (context) => AppLocalizations.of(context)!.leaderboard,
        route: '/leaderboard',
        color: Colors.amber,
      ),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _changeLanguage(String? languageCode) {
    if (languageCode != null) {
      final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
      languageProvider.changeLanguage(languageCode.toLowerCase());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.title),
        centerTitle: true,
        actions: [
          //下载菜单
          PopupMenuButton<String>(
            icon: Icon(Icons.download),
            onSelected: (platform) async {
              final url = '${AppConfig.BACKEND_API}/static/app/$platform';
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('无法下载应用')),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'PraiseMe.apk',
                child: Row(
                  children: [
                    Icon(Icons.android, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Android')
                  ],
                ),
              ),
              // PopupMenuItem(
              //   value: 'PraiseMe.ipa',
              //   child: Row(
              //     children: [
              //       Icon(Icons.phone_iphone, color: Colors.blue),
              //       SizedBox(width: 8),
              //       Text('iOS')
              //     ],
              //   ),
              // ),
              PopupMenuItem(
                value: 'PraiseMe.dmg',
                child: Row(
                  children: [
                    Icon(Icons.desktop_mac, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('macOS')
                  ],
                ),
              ),
              // PopupMenuItem(
              //   value: 'PraiseMe.exe',
              //   child: Row(
              //     children: [
              //       Icon(Icons.laptop_windows, color: Colors.blue),
              //       SizedBox(width: 8),
              //       Text('Windows')
              //     ],
              //   ),
              // ),
            ],
          ),
          //多语言切换
          PopupMenuButton<String>(
            onSelected: _changeLanguage,
            itemBuilder: (context) => [
              PopupMenuItem(value: 'zh', child: Text('中文')),
              PopupMenuItem(value: 'en', child: Text('English')),
              PopupMenuItem(value: 'ja', child: Text('日本語')),
            ],
            icon: Icon(Icons.language),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.purple.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            ..._buildNavItemsWidgets(),
            _buildCenterWidget(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildNavItemsWidgets() {
    final angleStep = 2 * pi / _navItems.length;
    final radius = 140.0; // Increased radius
    final centerOffsetX = MediaQuery.of(context).size.width / 2;
    final centerOffsetY = MediaQuery.of(context).size.height / 2;

    return List.generate(_navItems.length, (index) {
      final angle = index * angleStep - pi / 2;
      final item = _navItems[index];

      final x = cos(angle) * radius + centerOffsetX;
      final y = sin(angle) * radius + centerOffsetY;

      return Positioned(
        left: x - 30, // Adjusted positioning
        top: y - 50, // Adjusted positioning to accommodate label
        child: Column(
          children: [
            _buildNavButton(item),
            Text(item.label(context), style: TextStyle(color: item.color)), // 使用 context 获取翻译
          ],
        ),
      );
    });
  }

  Widget _buildNavButton(NavItem item) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _navigateTo(item.route),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: item.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                spreadRadius: 2,
              )
            ],
          ),
          child: Icon(item.icon, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildCenterWidget() {
    return Positioned(
      left: MediaQuery.of(context).size.width / 2 - 50, // Increased size
      top: MediaQuery.of(context).size.height / 2 - 50, // Increased size
      child: Container(
        width: 100, // Increased size
        height: 100, // Increased size
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.purple.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 15,
              spreadRadius: 3,
            )
          ],
        ),
        child: Icon(Icons.explore, color: Colors.white, size: 40), // Increased icon size
      ),
    );
  }

  void _navigateTo(String route) {
    Navigator.pushNamed(context, route);
  }
}

class NavItem {
  final IconData icon;
  final String Function(BuildContext context) label; // 修改为函数类型
  final String route;
  final Color color;

  NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.color,
  });
}