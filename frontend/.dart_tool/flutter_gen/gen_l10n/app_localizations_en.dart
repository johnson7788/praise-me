import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get title => 'AI Praise';

  @override
  String get directPraise => 'Direct Praise';

  @override
  String get hintPraise => 'Hint Praise';

  @override
  String get voicePraise => 'Voice Praise';

  @override
  String get photoPraise => 'Photo Praise';

  @override
  String get stylePraise => 'Style Praise';

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get instantPraise => 'Instant Praise';

  @override
  String get collectingPraiseEnergy => 'Collecting Praise Energy...';

  @override
  String get receiveTodayHappy => 'Click the button to receive today\'s happiness~';

  @override
  String get serverError => 'Oops~ The server is experiencing issues';

  @override
  String get networkError => 'Network connection failed';
}
