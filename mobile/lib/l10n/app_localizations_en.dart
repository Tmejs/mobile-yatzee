// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'General';

  @override
  String get homeTagline => 'Dice, strategy, and a shared table';

  @override
  String get newGame => 'New game';

  @override
  String get setupTitle => 'Game setup';

  @override
  String get solo => 'Solo challenge';

  @override
  String get passAndPlay => 'Pass and play';

  @override
  String get ruleset => 'Rules';

  @override
  String get polishGeneral => 'Polish General';

  @override
  String get classicYahtzee => 'Classic Yahtzee';

  @override
  String get scandinavianYatzy => 'Scandinavian Yatzy';

  @override
  String playerName(int number) {
    return 'Player $number name';
  }

  @override
  String defaultPlayerName(int number) {
    return 'Player $number';
  }

  @override
  String get addPlayer => 'Add player';

  @override
  String get removePlayer => 'Remove player';

  @override
  String get startGame => 'Start game';

  @override
  String get rollDice => 'Roll dice';

  @override
  String get rollAgain => 'Roll again';

  @override
  String rolls(int count) {
    return 'Rolls: $count/3';
  }

  @override
  String round(int number) {
    return 'Round $number';
  }

  @override
  String activePlayer(String name) {
    return 'active player: $name';
  }

  @override
  String dieFace(int number, int face) {
    return 'Die $number, face $face';
  }

  @override
  String dieNotRolled(int number) {
    return 'Die $number, not rolled yet';
  }

  @override
  String get held => 'held';

  @override
  String get notHeld => 'not held';

  @override
  String scoreCell(String category, String player, String score) {
    return '$category, $player, $score';
  }

  @override
  String scoreAvailable(int score) {
    return '$score points available';
  }

  @override
  String scoreUnavailable(int score) {
    return '$score points, unavailable';
  }

  @override
  String scoreRecorded(int score) {
    return '$score points scored';
  }

  @override
  String get activeScoreCell => 'active player';

  @override
  String get inactiveScoreCell => 'player inactive';

  @override
  String get notScored => 'not scored';

  @override
  String get total => 'Total';

  @override
  String get zeroScoreTitle => 'Record 0 points?';

  @override
  String get zeroScoreMessage => 'This choice records zero in the category.';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirmZero => 'Record 0';

  @override
  String get saveFailed => 'The game could not be saved.';

  @override
  String get retry => 'Try again';

  @override
  String get loading => 'Loading game';

  @override
  String get gameComplete => 'Game complete';

  @override
  String get categoryOnes => 'Ones';

  @override
  String get categoryTwos => 'Twos';

  @override
  String get categoryThrees => 'Threes';

  @override
  String get categoryFours => 'Fours';

  @override
  String get categoryFives => 'Fives';

  @override
  String get categorySixes => 'Sixes';

  @override
  String get categoryThreeKind => 'Three of a kind';

  @override
  String get categoryFourKind => 'Four of a kind';

  @override
  String get categoryFullHouse => 'Full house';

  @override
  String get categorySmallStraight => 'Small straight';

  @override
  String get categoryLargeStraight => 'Large straight';

  @override
  String get categoryGeneral => 'General';

  @override
  String get categoryChance => 'Chance';

  @override
  String get categoryYahtzee => 'Yahtzee';

  @override
  String get categoryYatzy => 'Yatzy';

  @override
  String get categoryOnePair => 'One pair';

  @override
  String get categoryTwoPairs => 'Two pairs';
}
