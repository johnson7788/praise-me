import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get title => 'ほめて';

  @override
  String get directPraise => '直接賞賛';

  @override
  String get achievementPraise => '達成の称賛';

  @override
  String get voicePraise => '声での賞賛';

  @override
  String get photoPraise => '写真での賞賛';

  @override
  String get starPraise => 'スターパライズ';

  @override
  String get leaderboard => 'リーダーボード';

  @override
  String get instantPraise => 'インスタント プライズ';

  @override
  String get againPraise => 'もう一度褒める';

  @override
  String get collectingPraiseEnergy => '賞賛エネルギーを集めています...';

  @override
  String get receiveTodayHappy => 'ボタンをクリックして今日の幸せを受けてください~';

  @override
  String get serverError => 'サーバーに一時的な問題が発生しました';

  @override
  String get networkError => 'ネットワーク接続に失敗しました';

  @override
  String get sharePraise => '彼女/彼氏を褒める';

  @override
  String get copy => 'コピー';

  @override
  String get saveSuccess => '保存に成功しました!';

  @override
  String get saveFailed => '保存に失敗しました';

  @override
  String get copySuccess => 'クリップボードにコピーしました';

  @override
  String get close => '閉じる';

  @override
  String get achievementHint => 'あなたの達成/気分/趣味を共有してください';

  @override
  String get achievementExample => '例: 今日、メイクの仕方を学びました。';

  @override
  String get achievementValidation => 'まず何かを共有してください~';

  @override
  String get generatePraise => 'カスタム称賛を生成';

  @override
  String get operationFailed => '操作に失敗しました。管理者が後で処理します。';

  @override
  String get noDataFound => 'データがありません';
}
