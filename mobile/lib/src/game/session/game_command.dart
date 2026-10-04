import '../domain/category.dart';

sealed class GameCommand {
  const GameCommand();
}

final class RollDice extends GameCommand {
  const RollDice();
}

final class ToggleHold extends GameCommand {
  const ToggleHold(this.index);
  final int index;
}

final class SelectCategory extends GameCommand {
  const SelectCategory(this.category, {this.confirmZero = false});
  final CategoryId category;
  final bool confirmZero;
}
