typedef CategoryId = String;

final class CategoryDefinition {
  const CategoryDefinition({
    required this.id,
    required this.labelKey,
    required this.section,
    required this.order,
  });

  final CategoryId id;
  final String labelKey;
  final String section;
  final int order;
}
