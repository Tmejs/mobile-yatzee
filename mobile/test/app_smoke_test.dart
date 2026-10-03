import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_yatzee/src/app.dart';

void main() {
  testWidgets('starts in Polish and shows the home title', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MobileYatzeeApp()));
    expect(find.text('Generał'), findsOneWidget);
  });
}
