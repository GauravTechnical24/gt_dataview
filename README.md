# GT DataView

[![pub package](https://img.shields.io/pub/v/gt_dataview.svg)](https://pub.dev/packages/gt_dataview)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter Platform](https://img.shields.io/badge/platform-flutter%20%7C%20android%20%7C%20ios%20%7C%20web%20%7C%20macos%20%7C%20linux%20%7C%20windows-blue.svg)](https://pub.dev/packages/gt_dataview)

High-performance Flutter list and grid view package with zero-rebuild optimization, pagination support, ChangeNotifier-based state management, and dedicated Material and Cupertino UI implementations.

---

## Features

- 🚀 **Zero-Rebuild Architecture** - Only visible, modified items rebuild on data updates.
- 🎨 **Material & Cupertino Separation** - Native feel across iOS, macOS, Android, and Desktop:
  - Material: `OptimizedListView` and `OptimizedGridView`.
  - Cupertino: `CupertinoOptimizedListView` and `CupertinoOptimizedGridView` with iOS bouncing scroll physics and `CupertinoActivityIndicator`.
- 🎮 **Controller-Based State** - `OptimizedListController` extends `ChangeNotifier` for fine-grained updates without rebuilding the outer widget tree.
- 📄 **Auto Pagination** - Built-in threshold detection (`loadMoreThreshold`) with custom `loaderBuilder` and error recovery (`errorBuilder`).
- 📭 **Empty State Support** - Built-in `emptyBuilder` when the collection has no items and is not loading.
- ⚙️ **Performance Tuning** - Configurable `itemExtent`, `scrollCacheExtent`, `useRepaintBoundary`, and `keepAlive` in `OptimizationConfig`.
- 🔄 **Safe CRUD Operations** - `addItem`, `addItems`, `insert`, `updateItem`, `removeAt`, `remove`, `clear`, and `replaceAll` with boundary protection and safe disposal.
- 🌐 **Cross-Platform & WASM-Ready** - Verified on Android, iOS, Web (WASM), macOS, Linux, and Windows.

---

## Installation

Add `gt_dataview` to your `pubspec.yaml`:

```yaml
dependencies:
  gt_dataview: ^1.2.0
```

Then run:

```bash
flutter pub get
```

Import the package:

```dart
import 'package:gt_dataview/gt_dataview.dart';
```

---

## Quick Start

### 1. Initialize the Controller

```dart
// Create controller with initial data
final controller = OptimizedListController<String>(['Item 1', 'Item 2', 'Item 3']);

// Clean up resources in your State's dispose method
@override
void dispose() {
  controller.dispose();
  super.dispose();
}
```

---

### 2. Material ListView (`OptimizedListView`)

```dart
OptimizedListView<String>(
  controller: controller,
  enablePagination: true,
  loadMoreThreshold: 300.0,
  config: const OptimizationConfig(
    itemExtent: 72.0, // Best layout performance
  ),
  onLoadMore: () async {
    final nextItems = await fetchNextPage();
    controller.addItems(nextItems);
  },
  emptyBuilder: (context) {
    return const Center(child: Text('No items found'));
  },
  loaderBuilder: (context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(child: CircularProgressIndicator()),
    );
  },
  itemBuilder: (context, item, index) {
    return ListTile(
      leading: CircleAvatar(child: Text('${index + 1}')),
      title: Text(item),
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () => controller.updateItem(index, '$item (edited)'),
      ),
    );
  },
)
```

---

### 3. Material GridView (`OptimizedGridView`)

```dart
OptimizedGridView<String>(
  controller: controller,
  crossAxisCount: 2,
  crossAxisSpacing: 8.0,
  mainAxisSpacing: 8.0,
  childAspectRatio: 1.2,
  enablePagination: true,
  onLoadMore: () async {
    final nextItems = await fetchNextPage();
    controller.addItems(nextItems);
  },
  itemBuilder: (context, item, index) {
    return Card(
      child: Center(child: Text(item)),
    );
  },
)
```

---

### 4. Cupertino Implementation (`CupertinoOptimizedListView`)

For iOS/macOS apps requiring native Cupertino design, bouncing scroll physics, and `CupertinoActivityIndicator`:

```dart
CupertinoOptimizedListView<String>(
  controller: controller,
  enablePagination: true,
  onLoadMore: () async {
    final nextItems = await fetchNextPage();
    controller.addItems(nextItems);
  },
  emptyBuilder: (context) => const Center(child: Text('No items')),
  itemBuilder: (context, item, index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.separator.resolveFrom(context),
          ),
        ),
      ),
      child: Text(item),
    );
  },
)
```

---

## Controller Operations

`OptimizedListController` provides complete CRUD operations that trigger scoped widget updates without re-evaluating the parent widget:

```dart
final controller = OptimizedListController<MyModel>(initialItems);

// 1. Add single item
controller.addItem(newItem);

// 2. Add multiple items (pagination)
controller.addItems(newItems);

// 3. Insert item at specific index
controller.insert(0, firstItem);

// 4. Update single item at index (only this item rebuilds)
controller.updateItem(index, updatedItem);

// 5. Remove item at index
controller.removeAt(index);

// 6. Remove specific item
controller.remove(item);

// 7. Replace entire collection
controller.replaceAll(freshItems);

// 8. Clear collection
controller.clear();

// 9. Inspect state
if (controller.isLoading) { ... }
if (controller.hasError) { print(controller.error); }
print('Total items: ${controller.length}');
```

---

## Performance Optimization Config

Fine-tune scroll and rendering performance with `OptimizationConfig`:

```dart
OptimizedListView<String>(
  controller: controller,
  config: const OptimizationConfig(
    itemExtent: 72.0,          // Fixed height avoids measuring children (major performance gain)
    cacheExtent: 500.0,        // Pre-rendering buffer in logical pixels
    useRepaintBoundary: true,  // Isolates item repaints via RepaintBoundary
    keepAlive: false,          // Automatically retain off-screen item state if true
  ),
  itemBuilder: (context, item, index) => Text(item),
)
```

Modern Flutter SDKs with `ScrollCacheExtent` are also supported directly:

```dart
OptimizationConfig(
  scrollCacheExtent: ScrollCacheExtent.viewport(2.0), // 2x viewport height
)
```

---

## Why Zero-Rebuild?

Traditional Flutter lists frequently suffer from unnecessary rebuild cascades:

```dart
// ❌ Traditional approach: Calling setState rebuilds the entire widget tree!
setState(() {
  items[5] = updatedItem;
});
```

With `GT DataView`:

```dart
// ✅ Zero-rebuild: Outer widgets do not rebuild. Only visible items update.
controller.updateItem(5, updatedItem);
```

- When items are added or updated, only the target item or newly visible items rebuild.
- When scrolling, invisible items are recycled efficiently without triggering parent `State.build`.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
