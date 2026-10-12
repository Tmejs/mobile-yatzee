import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In pl, this message translates to:
  /// **'Generał'**
  String get appTitle;

  /// No description provided for @homeTagline.
  ///
  /// In pl, this message translates to:
  /// **'Kości, strategia i wspólny stół'**
  String get homeTagline;

  /// No description provided for @newGame.
  ///
  /// In pl, this message translates to:
  /// **'Nowa gra'**
  String get newGame;

  /// No description provided for @setupTitle.
  ///
  /// In pl, this message translates to:
  /// **'Ustawienia gry'**
  String get setupTitle;

  /// No description provided for @solo.
  ///
  /// In pl, this message translates to:
  /// **'Gra solo'**
  String get solo;

  /// No description provided for @passAndPlay.
  ///
  /// In pl, this message translates to:
  /// **'Podaj dalej'**
  String get passAndPlay;

  /// No description provided for @ruleset.
  ///
  /// In pl, this message translates to:
  /// **'Zasady'**
  String get ruleset;

  /// No description provided for @polishGeneral.
  ///
  /// In pl, this message translates to:
  /// **'Generał'**
  String get polishGeneral;

  /// No description provided for @classicYahtzee.
  ///
  /// In pl, this message translates to:
  /// **'Klasyczny Yahtzee'**
  String get classicYahtzee;

  /// No description provided for @scandinavianYatzy.
  ///
  /// In pl, this message translates to:
  /// **'Skandynawski Yatzy'**
  String get scandinavianYatzy;

  /// No description provided for @playerName.
  ///
  /// In pl, this message translates to:
  /// **'Imię gracza {number}'**
  String playerName(int number);

  /// No description provided for @defaultPlayerName.
  ///
  /// In pl, this message translates to:
  /// **'Gracz {number}'**
  String defaultPlayerName(int number);

  /// No description provided for @addPlayer.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj gracza'**
  String get addPlayer;

  /// No description provided for @removePlayer.
  ///
  /// In pl, this message translates to:
  /// **'Usuń gracza'**
  String get removePlayer;

  /// No description provided for @startGame.
  ///
  /// In pl, this message translates to:
  /// **'Rozpocznij grę'**
  String get startGame;

  /// No description provided for @rollDice.
  ///
  /// In pl, this message translates to:
  /// **'Rzuć kośćmi'**
  String get rollDice;

  /// No description provided for @rollAgain.
  ///
  /// In pl, this message translates to:
  /// **'Rzuć ponownie'**
  String get rollAgain;

  /// No description provided for @rolls.
  ///
  /// In pl, this message translates to:
  /// **'Rzuty: {count}/3'**
  String rolls(int count);

  /// No description provided for @round.
  ///
  /// In pl, this message translates to:
  /// **'Runda {number}'**
  String round(int number);

  /// No description provided for @activePlayer.
  ///
  /// In pl, this message translates to:
  /// **'aktywny gracz: {name}'**
  String activePlayer(String name);

  /// No description provided for @dieFace.
  ///
  /// In pl, this message translates to:
  /// **'Kość {number}, wynik {face}'**
  String dieFace(int number, int face);

  /// No description provided for @dieNotRolled.
  ///
  /// In pl, this message translates to:
  /// **'Kość {number}, jeszcze nie rzucona'**
  String dieNotRolled(int number);

  /// No description provided for @held.
  ///
  /// In pl, this message translates to:
  /// **'zatrzymana'**
  String get held;

  /// No description provided for @notHeld.
  ///
  /// In pl, this message translates to:
  /// **'niezatrzymana'**
  String get notHeld;

  /// No description provided for @scoreCell.
  ///
  /// In pl, this message translates to:
  /// **'{category}, {player}, {score}'**
  String scoreCell(String category, String player, String score);

  /// No description provided for @notScored.
  ///
  /// In pl, this message translates to:
  /// **'brak wyniku'**
  String get notScored;

  /// No description provided for @total.
  ///
  /// In pl, this message translates to:
  /// **'Suma'**
  String get total;

  /// No description provided for @zeroScoreTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wpisać 0 punktów?'**
  String get zeroScoreTitle;

  /// No description provided for @zeroScoreMessage.
  ///
  /// In pl, this message translates to:
  /// **'Ten wybór zapisze zero w tej kategorii.'**
  String get zeroScoreMessage;

  /// No description provided for @cancel.
  ///
  /// In pl, this message translates to:
  /// **'Anuluj'**
  String get cancel;

  /// No description provided for @confirmZero.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz 0'**
  String get confirmZero;

  /// No description provided for @saveFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zapisać gry.'**
  String get saveFailed;

  /// No description provided for @retry.
  ///
  /// In pl, this message translates to:
  /// **'Spróbuj ponownie'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In pl, this message translates to:
  /// **'Wczytywanie gry'**
  String get loading;

  /// No description provided for @gameComplete.
  ///
  /// In pl, this message translates to:
  /// **'Gra zakończona'**
  String get gameComplete;

  /// No description provided for @categoryOnes.
  ///
  /// In pl, this message translates to:
  /// **'Jedynki'**
  String get categoryOnes;

  /// No description provided for @categoryTwos.
  ///
  /// In pl, this message translates to:
  /// **'Dwójki'**
  String get categoryTwos;

  /// No description provided for @categoryThrees.
  ///
  /// In pl, this message translates to:
  /// **'Trójki'**
  String get categoryThrees;

  /// No description provided for @categoryFours.
  ///
  /// In pl, this message translates to:
  /// **'Czwórki'**
  String get categoryFours;

  /// No description provided for @categoryFives.
  ///
  /// In pl, this message translates to:
  /// **'Piątki'**
  String get categoryFives;

  /// No description provided for @categorySixes.
  ///
  /// In pl, this message translates to:
  /// **'Szóstki'**
  String get categorySixes;

  /// No description provided for @categoryThreeKind.
  ///
  /// In pl, this message translates to:
  /// **'Trzy jednakowe'**
  String get categoryThreeKind;

  /// No description provided for @categoryFourKind.
  ///
  /// In pl, this message translates to:
  /// **'Cztery jednakowe'**
  String get categoryFourKind;

  /// No description provided for @categoryFullHouse.
  ///
  /// In pl, this message translates to:
  /// **'Full'**
  String get categoryFullHouse;

  /// No description provided for @categorySmallStraight.
  ///
  /// In pl, this message translates to:
  /// **'Mały strit'**
  String get categorySmallStraight;

  /// No description provided for @categoryLargeStraight.
  ///
  /// In pl, this message translates to:
  /// **'Duży strit'**
  String get categoryLargeStraight;

  /// No description provided for @categoryGeneral.
  ///
  /// In pl, this message translates to:
  /// **'Generał'**
  String get categoryGeneral;

  /// No description provided for @categoryChance.
  ///
  /// In pl, this message translates to:
  /// **'Szansa'**
  String get categoryChance;

  /// No description provided for @categoryYahtzee.
  ///
  /// In pl, this message translates to:
  /// **'Yahtzee'**
  String get categoryYahtzee;

  /// No description provided for @categoryYatzy.
  ///
  /// In pl, this message translates to:
  /// **'Yatzy'**
  String get categoryYatzy;

  /// No description provided for @categoryOnePair.
  ///
  /// In pl, this message translates to:
  /// **'Jedna para'**
  String get categoryOnePair;

  /// No description provided for @categoryTwoPairs.
  ///
  /// In pl, this message translates to:
  /// **'Dwie pary'**
  String get categoryTwoPairs;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
