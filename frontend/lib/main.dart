import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'ai_praise/direct_praise.dart';
import 'ai_praise/hint_praise.dart';
import 'ai_praise/voice_praise.dart';
import 'ai_praise/photo_praise.dart';
import 'ai_praise/style_praise.dart';
import 'ai_praise/leaderboard.dart';
import 'language_provider.dart';

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
          title: 'Prise Me',
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
            '/hint': (context) => HintPraisePage(),
            '/voice': (context) => VoicePraisePage(),
            '/photo': (context) => PhotoPraisePage(),
            '/style': (context) => StylePraisePage(),
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
  // final List<NavItem> _navItems = [
  //   NavItem(icon: Icons.record_voice_over, label: '直接夸', route: '/direct', color: Colors.blue),
  //   NavItem(icon: Icons.lightbulb, label: '提示夸', route: '/hint', color: Colors.green),
  //   NavItem(icon: Icons.mic, label: '语音夸', route: '/voice', color: Colors.orange),
  //   NavItem(icon: Icons.camera_alt, label: '拍拍夸', route: '/photo', color: Colors.red),
  //   NavItem(icon: Icons.palette, label: '风格夸', route: '/style', color: Colors.purple),
  //   NavItem(icon: Icons.star, label: '挑战', route: '/challenge', color: Colors.amber),
  // ];

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
        label: (context) => AppLocalizations.of(context)!.hintPraise,
        route: '/hint',
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
        label: (context) => AppLocalizations.of(context)!.stylePraise,
        route: '/style',
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