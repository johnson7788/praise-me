import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('zh')
  ];

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Praise Me'**
  String get title;

  /// No description provided for @directPraise.
  ///
  /// In en, this message translates to:
  /// **'Direct Praise'**
  String get directPraise;

  /// No description provided for @achievementPraise.
  ///
  /// In en, this message translates to:
  /// **'Achievement Praise'**
  String get achievementPraise;

  /// No description provided for @voicePraise.
  ///
  /// In en, this message translates to:
  /// **'Voice Praise'**
  String get voicePraise;

  /// No description provided for @photoPraise.
  ///
  /// In en, this message translates to:
  /// **'Photo Praise'**
  String get photoPraise;

  /// No description provided for @starPraise.
  ///
  /// In en, this message translates to:
  /// **'Star Praise'**
  String get starPraise;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// No description provided for @instantPraise.
  ///
  /// In en, this message translates to:
  /// **'Instant Praise'**
  String get instantPraise;

  /// No description provided for @againPraise.
  ///
  /// In en, this message translates to:
  /// **'Praise Again'**
  String get againPraise;

  /// No description provided for @collectingPraiseEnergy.
  ///
  /// In en, this message translates to:
  /// **'Collecting Praise Energy...'**
  String get collectingPraiseEnergy;

  /// No description provided for @receiveTodayHappy.
  ///
  /// In en, this message translates to:
  /// **'Click the button to receive today\'s happiness~'**
  String get receiveTodayHappy;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Oops~ The server is experiencing issues'**
  String get serverError;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network connection failed'**
  String get networkError;

  /// No description provided for @sharePraise.
  ///
  /// In en, this message translates to:
  /// **'Praise her/him'**
  String get sharePraise;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @saveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Save Success!'**
  String get saveSuccess;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Save Failed'**
  String get saveFailed;

  /// No description provided for @copySuccess.
  ///
  /// In en, this message translates to:
  /// **'Copied to Clipboard'**
  String get copySuccess;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @achievementHint.
  ///
  /// In en, this message translates to:
  /// **'Share your achievements/mood/hobbies'**
  String get achievementHint;

  /// No description provided for @achievementExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. Learned make up today!'**
  String get achievementExample;

  /// No description provided for @achievementValidation.
  ///
  /// In en, this message translates to:
  /// **'Please share something first~'**
  String get achievementValidation;

  /// No description provided for @generatePraise.
  ///
  /// In en, this message translates to:
  /// **'Generate Custom Praise'**
  String get generatePraise;

  /// No description provided for @operationFailed.
  ///
  /// In en, this message translates to:
  /// **'The operation failed. The administrator will handle it later.'**
  String get operationFailed;

  /// No description provided for @noDataFound.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataFound;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ja', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ja': return AppLocalizationsJa();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
