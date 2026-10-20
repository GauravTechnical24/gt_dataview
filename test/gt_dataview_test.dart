import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gt_dataview/gt_dataview.dart';

void main() {
  group('OptimizedListController Unit Tests', () {
    test('initializes with items or empty', () {
      final controller = OptimizedListController<String>(['a', 'b', 'c']);
      expect(controller.items, ['a', 'b', 'c']);
      expect(controller.length, 3);
      expect(controller.isEmpty, isFalse);
      expect(controller.isNotEmpty, isTrue);
      expect(controller[0], 'a');
      expect(controller[2], 'c');

      final emptyController = OptimizedListController<String>();
      expect(emptyController.items, isEmpty);
      expect(emptyController.isEmpty, isTrue);
      expect(emptyController.isNotEmpty, isFalse);
    });

    test('addItems appends items', () {
      final controller = OptimizedListController<String>(['a']);
      controller.addItems(['b', 'c']);

      expect(controller.items, ['a', 'b', 'c']);
      expect(controller.length, 3);
    });

    test('addItem appends a single item', () {
      final controller = OptimizedListController<String>(['a']);
      controller.addItem('b');

      expect(controller.items, ['a', 'b']);
      expect(controller.length, 2);
    });

    test('insert adds item at index', () {
      final controller = OptimizedListController<String>(['a', 'c']);
      controller.insert(1, 'b');

      expect(controller.items, ['a', 'b', 'c']);
      expect(controller[1], 'b');

      // Invalid index does not crash
      controller.insert(99, 'z');
      expect(controller.length, 3);
    });

    test('updateItem updates at index with boundary safety', () {
      final controller = OptimizedListController<String>(['a', 'b', 'c']);
      controller.updateItem(1, 'x');

      expect(controller.items[1], 'x');

      // Invalid indices do not throw
      controller.updateItem(-1, 'bad');
      controller.updateItem(10, 'bad');
      expect(controller.length, 3);
    });

    test('removeAt removes item at index with boundary safety', () {
      final controller = OptimizedListController<String>(['a', 'b', 'c']);
      controller.removeAt(1);

      expect(controller.items, ['a', 'c']);
      expect(controller.length, 2);

      // Out of bounds removeAt does nothing
      controller.removeAt(5);
      expect(controller.length, 2);
    });

    test('remove removes matching element', () {
      final controller = OptimizedListController<String>(['a', 'b', 'c']);
      final result = controller.remove('b');

      expect(result, isTrue);
      expect(controller.items, ['a', 'c']);

      final notFound = controller.remove('z');
      expect(notFound, isFalse);
    });

    test('clear removes all items', () {
      final controller = OptimizedListController<String>(['a', 'b', 'c']);
      controller.setError('previous error');
      controller.clear();

      expect(controller.items, isEmpty);
      expect(controller.length, 0);
      expect(controller.hasError, isFalse);
      expect(controller.error, isNull);
    });

    test('replaceAll replaces all items', () {
      final controller = OptimizedListController<String>(['a', 'b']);
      controller.replaceAll(['x', 'y', 'z']);

      expect(controller.items, ['x', 'y', 'z']);
      expect(controller.length, 3);
    });

    test('setLoading updates loading state', () {
      final controller = OptimizedListController<String>([]);

      expect(controller.isLoading, isFalse);

      controller.setLoading(true);
      expect(controller.isLoading, isTrue);

      controller.setLoading(false);
      expect(controller.isLoading, isFalse);
    });

    test('setError and clearError handle error state', () {
      final controller = OptimizedListController<String>([]);
      expect(controller.hasError, isFalse);
      expect(controller.error, isNull);

      controller.setError('network timeout');
      expect(controller.hasError, isTrue);
      expect(controller.error, 'network timeout');

      controller.clearError();
      expect(controller.hasError, isFalse);
      expect(controller.error, isNull);
    });

    test('disposal safety prevents exceptions', () {
      final controller = OptimizedListController<String>(['a']);
      expect(controller.isDisposed, isFalse);

      controller.dispose();
      expect(controller.isDisposed, isTrue);

      // Subsequent calls on disposed controller should safely no-op
      controller.addItem('b');
      controller.addItems(['c']);
      controller.updateItem(0, 'z');
      controller.setLoading(true);
      controller.setError('err');
      controller.clear();
      expect(controller.length, 1);
    });
  });

  group('OptimizationConfig Unit Tests', () {
    test('default values are set correctly', () {
      const config = OptimizationConfig();

      expect(config.useRepaintBoundary, isFalse);
      expect(config.keepAlive, isFalse);
      expect(config.itemExtent, isNull);
      expect(config.effectiveScrollCacheExtent.value, 250.0);
      // Deprecated getter compatibility check
      // ignore: deprecated_member_use_from_same_package
      expect(config.cacheExtent, 250.0);
    });

    test(
      'custom values are applied with modern and deprecated cache extent',
      () {
        const config = OptimizationConfig(
          useRepaintBoundary: true,
          keepAlive: true,
          itemExtent: 72.0,
          // ignore: deprecated_member_use_from_same_package
          cacheExtent: 500.0,
        );

        expect(config.useRepaintBoundary, isTrue);
        expect(config.keepAlive, isTrue);
        expect(config.itemExtent, 72.0);
        expect(config.effectiveScrollCacheExtent.value, 500.0);
        // ignore: deprecated_member_use_from_same_package
        expect(config.cacheExtent, 500.0);
      },
    );

    test('ScrollCacheExtent directly passed', () {
      const config = OptimizationConfig(
        scrollCacheExtent: ScrollCacheExtent.pixels(400.0),
      );

      expect(config.effectiveScrollCacheExtent.value, 400.0);
    });
  });

  group('OptimizedListView Widget Tests', () {
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

    testWidgets('displays emptyBuilder when items are empty', (tester) async {
      final controller = OptimizedListController<String>([]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedListView<String>(
              controller: controller,
              emptyBuilder: (context) => const Text('No items found'),
              itemBuilder: (context, item, index) => Text(item),
            ),
          ),
        ),
      );

      expect(find.text('No items found'), findsOneWidget);
    });

    testWidgets('displays loaderBuilder when loading more', (tester) async {
      final controller = OptimizedListController<String>(['Item 1']);
      controller.setLoading(true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedListView<String>(
              controller: controller,
              loaderBuilder: (context) => const Text('Loading page...'),
              itemBuilder: (context, item, index) => Text(item),
            ),
          ),
        ),
      );

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Loading page...'), findsOneWidget);
    });

    testWidgets('triggers onLoadMore during scroll pagination', (tester) async {
      int loadMoreCalls = 0;
      final controller = OptimizedListController<String>(
        List.generate(30, (i) => 'Item $i'),
      );
      final scrollController = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 300,
              child: OptimizedListView<String>(
                controller: controller,
                scrollController: scrollController,
                enablePagination: true,
                loadMoreThreshold: 500,
                config: const OptimizationConfig(itemExtent: 50),
                onLoadMore: () async {
                  loadMoreCalls++;
                  controller.addItems(['Extra 1', 'Extra 2']);
                },
                itemBuilder: (context, item, index) => Text(item),
              ),
            ),
          ),
        ),
      );

      // Scroll near the bottom
      scrollController.jumpTo(900);
      await tester.pump();
      await tester.pumpAndSettle();

      expect(loadMoreCalls, greaterThanOrEqualTo(1));
      expect(controller.length, 32);
      expect(controller.items.contains('Extra 1'), isTrue);

      scrollController.dispose();
    });

    testWidgets('displays errorBuilder when error occurs', (tester) async {
      final controller = OptimizedListController<String>(['Item 1']);
      controller.setError('Server unavailable');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedListView<String>(
              controller: controller,
              errorBuilder: (context, error, retry) => Text('Error: $error'),
              itemBuilder: (context, item, index) => Text(item),
            ),
          ),
        ),
      );

      expect(find.text('Error: Server unavailable'), findsOneWidget);
    });

    testWidgets('updates scrollController dynamically in didUpdateWidget', (
      tester,
    ) async {
      final controller = OptimizedListController<String>(['A', 'B']);
      final scroll1 = ScrollController();
      final scroll2 = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedListView<String>(
              controller: controller,
              scrollController: scroll1,
              itemBuilder: (context, item, index) => Text(item),
            ),
          ),
        ),
      );

      // Rebuild with new scrollController
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedListView<String>(
              controller: controller,
              scrollController: scroll2,
              itemBuilder: (context, item, index) => Text(item),
            ),
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
      scroll1.dispose();
      scroll2.dispose();
    });
  });

  group('OptimizedGridView Widget Tests', () {
    testWidgets('renders items correctly in grid layout', (tester) async {
      final controller = OptimizedListController<String>(['A', 'B', 'C', 'D']);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedGridView<String>(
              controller: controller,
              crossAxisCount: 2,
              itemBuilder: (context, item, index) => Text(item),
            ),
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
      expect(find.text('D'), findsOneWidget);
    });

    testWidgets('renders emptyBuilder in grid when empty', (tester) async {
      final controller = OptimizedListController<String>([]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedGridView<String>(
              controller: controller,
              emptyBuilder: (context) => const Text('Grid is empty'),
              itemBuilder: (context, item, index) => Text(item),
            ),
          ),
        ),
      );

      expect(find.text('Grid is empty'), findsOneWidget);
    });
  });

  group('CupertinoOptimizedListView Widget Tests', () {
    testWidgets('renders items with Cupertino design', (tester) async {
      final controller = OptimizedListController<String>(['iOS 1', 'iOS 2']);

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: CupertinoOptimizedListView<String>(
              controller: controller,
              itemBuilder: (context, item, index) => Text(item),
            ),
          ),
        ),
      );

      expect(find.text('iOS 1'), findsOneWidget);
      expect(find.text('iOS 2'), findsOneWidget);
    });

    testWidgets(
      'shows CupertinoActivityIndicator default loader when loading',
      (tester) async {
        final controller = OptimizedListController<String>(['iOS 1']);
        controller.setLoading(true);

        await tester.pumpWidget(
          CupertinoApp(
            home: CupertinoPageScaffold(
              child: CupertinoOptimizedListView<String>(
                controller: controller,
                itemBuilder: (context, item, index) => Text(item),
              ),
            ),
          ),
        );

        expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
      },
    );

    testWidgets('renders emptyBuilder in Cupertino when empty', (tester) async {
      final controller = OptimizedListController<String>([]);

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: CupertinoOptimizedListView<String>(
              controller: controller,
              emptyBuilder: (context) => const Text('No Cupertino items'),
              itemBuilder: (context, item, index) => Text(item),
            ),
          ),
        ),
      );

      expect(find.text('No Cupertino items'), findsOneWidget);
    });
  });

  group('CupertinoOptimizedGridView Widget Tests', () {
    testWidgets('renders grid items with Cupertino theme', (tester) async {
      final controller = OptimizedListController<String>(['C1', 'C2', 'C3']);

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: CupertinoOptimizedGridView<String>(
              controller: controller,
              crossAxisCount: 3,
              itemBuilder: (context, item, index) => Text(item),
            ),
          ),
        ),
      );

      expect(find.text('C1'), findsOneWidget);
      expect(find.text('C2'), findsOneWidget);
      expect(find.text('C3'), findsOneWidget);
    });

    testWidgets('shows CupertinoActivityIndicator in grid during loading', (
      tester,
    ) async {
      final controller = OptimizedListController<String>(['C1']);
      controller.setLoading(true);

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: CupertinoOptimizedGridView<String>(
              controller: controller,
              crossAxisCount: 2,
              itemBuilder: (context, item, index) => Text(item),
            ),
          ),
        ),
      );

      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    });
  });
}
