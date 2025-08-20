import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:findeasy/main.dart';


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Display MyPage', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Text('hello world')));
    await tester.pumpAndSettle();
    // Add assertions or interactions here
    // expect(find.text('Some Text on MyPage'), findsOneWidget);

    await Future.delayed(const Duration(days: 1));
  });
}