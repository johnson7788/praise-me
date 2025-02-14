import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get title => 'AI 賞賛';

  @override
  String get directPraise => '直接賞賛';

  @override
  String get hintPraise => 'ヒント賞賛';

  @override
  String get voicePraise => '音声賞賛';

  @override
  String get photoPraise => '写真賞賛';

  @override
  String get stylePraise => 'スタイル賞賛';

  @override
  String get leaderboard => 'リーダーボード';

  @override
  String get instantPraise => 'インスタント プライズ';

  @override
  String get collectingPraiseEnergy => '賞賛エネルギーを集めています...';

  @override
  String get receiveTodayHappy => 'ボタンをクリックして今日の幸せを受けてください~';

  @override
  String get serverError => 'サーバーに一時的な問題が発生しました';

  @override
  String get networkError => 'ネットワーク接続に失敗しました';
}
