final class DiceRoll {
  DiceRoll(List<int> values) : values = List.unmodifiable(values) {
    if (values.length != 5 || values.any((face) => face < 1 || face > 6)) {
      throw ArgumentError.value(
        values,
        'values',
        'Expected five faces from 1 to 6',
      );
    }
  }

  final List<int> values;

  Map<int, int> get counts {
    final result = <int, int>{};
    for (final face in values) {
      result[face] = (result[face] ?? 0) + 1;
    }
    return Map.unmodifiable(result);
  }

  int get sum => values.fold(0, (total, face) => total + face);
}
