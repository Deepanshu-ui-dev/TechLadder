import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:techladder/main.dart';

void main() {
  testWidgets('TechLadder app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: TechLadderApp()));
    await tester.pump(const Duration(milliseconds: 500));
    // App should render without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
