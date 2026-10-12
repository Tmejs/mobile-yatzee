// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Generał';

  @override
  String get homeTagline => 'Kości, strategia i wspólny stół';

  @override
  String get newGame => 'Nowa gra';

  @override
  String get setupTitle => 'Ustawienia gry';

  @override
  String get solo => 'Gra solo';

  @override
  String get passAndPlay => 'Podaj dalej';

  @override
  String get ruleset => 'Zasady';

  @override
  String get polishGeneral => 'Generał';

  @override
  String get classicYahtzee => 'Klasyczny Yahtzee';

  @override
  String get scandinavianYatzy => 'Skandynawski Yatzy';

  @override
  String playerName(int number) {
    return 'Imię gracza $number';
  }

  @override
  String defaultPlayerName(int number) {
    return 'Gracz $number';
  }

  @override
  String get addPlayer => 'Dodaj gracza';

  @override
  String get removePlayer => 'Usuń gracza';

  @override
  String get startGame => 'Rozpocznij grę';

  @override
  String get rollDice => 'Rzuć kośćmi';

  @override
  String get rollAgain => 'Rzuć ponownie';

  @override
  String rolls(int count) {
    return 'Rzuty: $count/3';
  }

  @override
  String round(int number) {
    return 'Runda $number';
  }

  @override
  String activePlayer(String name) {
    return 'aktywny gracz: $name';
  }

  @override
  String dieFace(int number, int face) {
    return 'Kość $number, wynik $face';
  }

  @override
  String dieNotRolled(int number) {
    return 'Kość $number, jeszcze nie rzucona';
  }

  @override
  String get held => 'zatrzymana';

  @override
  String get notHeld => 'niezatrzymana';

  @override
  String scoreCell(String category, String player, String score) {
    return '$category, $player, $score';
  }

  @override
  String get notScored => 'brak wyniku';

  @override
  String get total => 'Suma';

  @override
  String get zeroScoreTitle => 'Wpisać 0 punktów?';

  @override
  String get zeroScoreMessage => 'Ten wybór zapisze zero w tej kategorii.';

  @override
  String get cancel => 'Anuluj';

  @override
  String get confirmZero => 'Wpisz 0';

  @override
  String get saveFailed => 'Nie udało się zapisać gry.';

  @override
  String get retry => 'Spróbuj ponownie';

  @override
  String get loading => 'Wczytywanie gry';

  @override
  String get gameComplete => 'Gra zakończona';

  @override
  String get categoryOnes => 'Jedynki';

  @override
  String get categoryTwos => 'Dwójki';

  @override
  String get categoryThrees => 'Trójki';

  @override
  String get categoryFours => 'Czwórki';

  @override
  String get categoryFives => 'Piątki';

  @override
  String get categorySixes => 'Szóstki';

  @override
  String get categoryThreeKind => 'Trzy jednakowe';

  @override
  String get categoryFourKind => 'Cztery jednakowe';

  @override
  String get categoryFullHouse => 'Full';

  @override
  String get categorySmallStraight => 'Mały strit';

  @override
  String get categoryLargeStraight => 'Duży strit';

  @override
  String get categoryGeneral => 'Generał';

  @override
  String get categoryChance => 'Szansa';

  @override
  String get categoryYahtzee => 'Yahtzee';

  @override
  String get categoryYatzy => 'Yatzy';

  @override
  String get categoryOnePair => 'Jedna para';

  @override
  String get categoryTwoPairs => 'Dwie pary';
}
