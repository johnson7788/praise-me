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
  /// **'Directs Praise'**
  String get directPraise;

  /// No description provided for @achievementPraise.
  ///
  /// In en, this message translates to:
  /// **'Achieve Praise'**
  String get achievementPraise;

  /// No description provided for @voicePraise.
  ///
  /// In en, this message translates to:
  /// **'Voices Praise'**
  String get voicePraise;

  /// No description provided for @photoPraise.
  ///
  /// In en, this message translates to:
  /// **'Photos Praise'**
  String get photoPraise;

  /// No description provided for @starPraise.
  ///
  /// In en, this message translates to:
  /// **'Stars Praise'**
  String get starPraise;

  /// No description provided for @animatePraise.
  ///
  /// In en, this message translates to:
  /// **'Animate Praise'**
  String get animatePraise;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leader board'**
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
  /// **'Can\'t Wait'**
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

  /// No description provided for @uploadPrompt.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload photo/video'**
  String get uploadPrompt;

  /// No description provided for @videoSupported.
  ///
  /// In en, this message translates to:
  /// **'Supports MP4 videos'**
  String get videoSupported;

  /// No description provided for @chooseSource.
  ///
  /// In en, this message translates to:
  /// **'Choose Source'**
  String get chooseSource;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @filePickError.
  ///
  /// In en, this message translates to:
  /// **'Error selecting file'**
  String get filePickError;

  /// No description provided for @uploadError.
  ///
  /// In en, this message translates to:
  /// **'Upload failed'**
  String get uploadError;

  /// No description provided for @generateAnimate.
  ///
  /// In en, this message translates to:
  /// **'Generate Animate'**
  String get generateAnimate;

  /// No description provided for @regenerateAnimate.
  ///
  /// In en, this message translates to:
  /// **'Generate Again'**
  String get regenerateAnimate;

  /// No description provided for @generatingAnimate.
  ///
  /// In en, this message translates to:
  /// **'Generating your amazing animate...'**
  String get generatingAnimate;

  /// No description provided for @generateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate animate'**
  String get generateFailed;

  /// No description provided for @noPraiseText.
  ///
  /// In en, this message translates to:
  /// **'Please generate praise text first'**
  String get noPraiseText;

  /// No description provided for @comments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comments;

  /// No description provided for @writeComment.
  ///
  /// In en, this message translates to:
  /// **'Write Comment'**
  String get writeComment;

  /// No description provided for @commentHint.
  ///
  /// In en, this message translates to:
  /// **'Write your comment here...'**
  String get commentHint;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @loadCommentsFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load comments'**
  String get loadCommentsFailed;

  /// No description provided for @commentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Comment submitted!'**
  String get commentSuccess;

  /// No description provided for @commentFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit comment'**
  String get commentFailed;

  /// No description provided for @noComments.
  ///
  /// In en, this message translates to:
  /// **'No comments yet'**
  String get noComments;

  /// No description provided for @praiseDetail.
  ///
  /// In en, this message translates to:
  /// **'Praise Detail'**
  String get praiseDetail;

  /// No description provided for @like.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get like;

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load'**
  String get loadFailed;

  /// No description provided for @likeFailed.
  ///
  /// In en, this message translates to:
  /// **'Like failed'**
  String get likeFailed;

  /// No description provided for @recordNotFound.
  ///
  /// In en, this message translates to:
  /// **'Record not found'**
  String get recordNotFound;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'take Photo'**
  String get takePhoto;

  /// No description provided for @uploadFromGallery.
  ///
  /// In en, this message translates to:
  /// **'From Gallery'**
  String get uploadFromGallery;

  /// No description provided for @appBackgroundTitle.
  ///
  /// In en, this message translates to:
  /// **'About Praise Me App'**
  String get appBackgroundTitle;

  /// No description provided for @appBackgroundText.
  ///
  /// In en, this message translates to:
  /// **'You are one of a kind and the best in the world—thumbs up for you! 👍\n\nEveryone needs praise, and that’s the reason I developed the **Praise Me** app. In modern society, people often face stress, anxiety, and self-doubt. A well-timed compliment can bring warmth and strength. I hope to harness the power of AI to make sure everyone can receive praise anytime, anywhere—boosting confidence, improving mood, and making it your personal \"praise companion\" who understands you best.'**
  String get appBackgroundText;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;
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
