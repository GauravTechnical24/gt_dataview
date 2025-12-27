import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gt_dataview/gt_dataview.dart';

void main() {
  group('OptimizedListController', () {
    test('initializes with items', () {
      final controller = OptimizedListController<String>(['a', 'b', 'c']);

      expect(controller.items, ['a', 'b', 'c']);
      expect(controller.length, 3);
    });

    test('addItems appends items', () {
      final controller = OptimizedListController<String>(['a']);
      controller.addItems(['b', 'c']);

      expect(controller.items, ['a', 'b', 'c']);
      expect(controller.length, 3);
    });

    test('updateItem updates at index', () {
      final controller = OptimizedListController<String>(['a', 'b', 'c']);
      controller.updateItem(1, 'x');

      expect(controller.items[1], 'x');
    });

    test('removeAt removes item at index', () {
      final controller = OptimizedListController<String>(['a', 'b', 'c']);
      controller.removeAt(1);

      expect(controller.items, ['a', 'c']);
      expect(controller.length, 2);
    });

    test('clear removes all items', () {
      final controller = OptimizedListController<String>(['a', 'b', 'c']);
      controller.clear();

      expect(controller.items, isEmpty);
      expect(controller.length, 0);
    });

    test('replaceAll replaces all items', () {
      final controller = OptimizedListController<String>(['a', 'b']);
      controller.replaceAll(['x', 'y', 'z']);

      expect(controller.items, ['x', 'y', 'z']);
    });

    test('setLoading updates loading state', () {
      final controller = OptimizedListController<String>([]);

      expect(controller.isLoading, isFalse);

      controller.setLoading(true);
      expect(controller.isLoading, isTrue);

      controller.setLoading(false);
      expect(controller.isLoading, isFalse);
    });
  });

  group('OptimizationConfig', () {
    test('default values are set correctly', () {
      const config = OptimizationConfig();

      expect(config.useRepaintBoundary, isFalse);
      expect(config.keepAlive, isFalse);
      expect(config.itemExtent, isNull);
      expect(config.cacheExtent, 250.0);
    });

    test('custom values are applied', () {
      const config = OptimizationConfig(
        useRepaintBoundary: true,
        keepAlive: true,
        itemExtent: 72.0,
        cacheExtent: 500.0,
      );

      expect(config.useRepaintBoundary, isTrue);
      expect(config.keepAlive, isTrue);
      expect(config.itemExtent, 72.0);
      expect(config.cacheExtent, 500.0);
    });
  });

  group('OptimizedListView Widget', () {
    testWidgets('renders items correctly', (tester) async {
      final controller = OptimizedListController<String>(['Item 1', 'Item 2']);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedListView<String>(
              controller: controller,
              itemBuilder: (context, item, index) {
                return Text(item);
              },
            ),
          ),
        ),
      );

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
    });
  });

  group('OptimizedGridView Widget', () {
    testWidgets('renders items correctly', (tester) async {
      final controller = OptimizedListController<String>(['A', 'B', 'C', 'D']);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedGridView<String>(
              controller: controller,
              crossAxisCount: 2,
              itemBuilder: (context, item, index) {
                return Text(item);
              },
            ),
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
    });
  });
}
