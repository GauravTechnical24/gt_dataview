import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gt_dataview_example/main.dart';

void main() {
  testWidgets(
    'GTDataViewExampleApp renders and handles view & theme toggling',
    (WidgetTester tester) async {
      await tester.pumpWidget(const GTDataViewExampleApp());
      await tester.pumpAndSettle();

      // Verify title and item count header
      expect(find.text('GT DataView'), findsOneWidget);
      expect(find.textContaining('live items'), findsOneWidget);

      // Verify presence of modern action buttons
      expect(find.byIcon(Icons.grid_view_outlined), findsOneWidget);
      expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);

      // Toggle grid view
      await tester.tap(find.byIcon(Icons.grid_view_outlined));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.view_agenda_outlined), findsOneWidget);

      // Toggle theme to dark mode
      await tester.tap(find.byIcon(Icons.dark_mode_outlined));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.light_mode), findsOneWidget);

      // Switch to Cupertino view
      await tester.tap(find.byIcon(Icons.phone_iphone_outlined));
      await tester.pumpAndSettle();

      expect(find.textContaining('GT DataView (20)'), findsOneWidget);
    },
  );
}
