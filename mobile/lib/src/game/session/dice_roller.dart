import 'dart:math';

abstract interface class DiceRoller {
  List<int> roll(int count);
}

final class SecureDiceRoller implements DiceRoller {
  SecureDiceRoller() : _random = Random.secure();
  final Random _random;

  @override
  List<int> roll(int count) {
    if (count < 0) throw RangeError.value(count, 'count');
    return List.generate(count, (_) => _random.nextInt(6) + 1);
  }
}
