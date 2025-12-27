import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gt_dataview_example/main.dart';

void main() {
  testWidgets('DataViewExampleScreen displays correctly', (
    WidgetTester tester,
  ) async {
    // Build the app
    await tester.pumpWidget(const MyApp());

    // Verify that the app title contains GT DataView
    expect(find.textContaining('GT DataView'), findsOneWidget);

    // Verify toggle button is present
    expect(find.byIcon(Icons.grid_view), findsOneWidget);

    // Verify refresh button is present
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });
}
