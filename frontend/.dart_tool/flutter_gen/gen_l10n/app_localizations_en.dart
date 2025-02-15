import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get title => 'Praise Me';

  @override
  String get directPraise => 'Direct Praise';

  @override
  String get achievementPraise => 'Achievement Praise';

  @override
  String get voicePraise => 'Voice Praise';

  @override
  String get photoPraise => 'Photo Praise';

  @override
  String get starPraise => 'Star Praise';

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get instantPraise => 'Instant Praise';

  @override
  String get againPraise => 'Praise Again';

  @override
  String get collectingPraiseEnergy => 'Collecting Praise Energy...';

  @override
  String get receiveTodayHappy => 'Click the button to receive today\'s happiness~';

  @override
  String get serverError => 'Oops~ The server is experiencing issues';

  @override
  String get networkError => 'Network connection failed';

  @override
  String get sharePraise => 'Praise her/him';

  @override
  String get copy => 'Copy';

  @override
  String get saveSuccess => 'Save Success!';

  @override
  String get saveFailed => 'Save Failed';

  @override
  String get copySuccess => 'Copied to Clipboard';

  @override
  String get close => 'Close';

  @override
  String get achievementHint => 'Share your achievements/mood/hobbies';

  @override
  String get achievementExample => 'e.g. Learned make up today!';

  @override
  String get achievementValidation => 'Please share something first~';

  @override
  String get generatePraise => 'Generate Custom Praise';

  @override
  String get operationFailed => 'The operation failed. The administrator will handle it later.';

  @override
  String get noDataFound => 'No data available';
}
