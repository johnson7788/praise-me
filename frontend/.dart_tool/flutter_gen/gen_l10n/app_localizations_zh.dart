import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get title => 'AI 夸夸';

  @override
  String get directPraise => '直接夸';

  @override
  String get hintPraise => '提示夸';

  @override
  String get voicePraise => '语音夸';

  @override
  String get photoPraise => '拍拍夸';

  @override
  String get stylePraise => '风格夸';

  @override
  String get leaderboard => '排行榜';

  @override
  String get instantPraise => '立刻被夸';

  @override
  String get collectingPraiseEnergy => '夸夸能量收集中...';

  @override
  String get receiveTodayHappy => '点击按钮接收今日份的快乐~';

  @override
  String get serverError => '哎呀~ 服务器开小差了';

  @override
  String get networkError => '网络连接失败';
}
