import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remote_racket_score/main.dart';

void main() {
  testWidgets('App starts and shows score screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: RemoteRacketScoreApp()));
    await tester.pumpAndSettle();
    expect(find.text('Desfazer'), findsOne);
  });
}
