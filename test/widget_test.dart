import 'package:flutter_test/flutter_test.dart';
import 'package:math_music_game/app.dart';

void main() {
  testWidgets('App renders welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MathMusicApp());
    expect(find.text('数律华章'), findsOneWidget);
  });
}
