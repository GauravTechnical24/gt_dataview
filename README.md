# GT DataView

[![pub package](https://img.shields.io/pub/v/gt_dataview.svg)](https://pub.dev/packages/gt_dataview)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

High-performance Flutter list and grid view package with zero-rebuild optimization, pagination support, and ChangeNotifier-based state management.

## Features

- 🚀 **Zero-Rebuild Architecture** - Only visible items rebuild on data changes
- 📜 **OptimizedListView** - High-performance ListView with pagination
- 📊 **OptimizedGridView** - High-performance GridView with pagination
- 🎮 **Controller-Based** - ChangeNotifier for efficient state management
- 📄 **Auto Pagination** - Built-in load more with configurable threshold
- ⚙️ **Performance Config** - RepaintBoundary, itemExtent, cacheExtent tuning
- 🔄 **CRUD Operations** - Add, update, remove items without full rebuilds

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  gt_dataview: ^1.0.0
```

Then run:
```bash
flutter pub get
```

## Quick Start

### 1. Create Controller

```dart
import 'package:gt_dataview/gt_dataview.dart';

// Initialize with data
final controller = OptimizedListController<MyItem>(initialItems);

// Don't forget to dispose
@override
void dispose() {
  controller.dispose();
  super.dispose();
}
```

### 2. OptimizedListView

```dart
OptimizedListView<MyItem>(
  controller: controller,
  enablePagination: true,
  onLoadMore: () async {
    final newItems = await fetchMoreData();
    controller.addItems(newItems);
  },
  itemBuilder: (context, item, index) {
    return ListTile(
      title: Text(item.title),
      subtitle: Text(item.subtitle),
    );
  },
)
```

### 3. OptimizedGridView

```dart
OptimizedGridView<MyItem>(
  controller: controller,
  crossAxisCount: 2,
  enablePagination: true,
  onLoadMore: loadMoreItems,
  itemBuilder: (context, item, index) {
    return Card(
      child: Center(child: Text(item.title)),
    );
  },
)
```

## Controller Operations

```dart
final controller = OptimizedListController<MyItem>(items);

// Add items (pagination)
controller.addItems(newItems);

// Update single item (only that item rebuilds)
controller.updateItem(index, updatedItem);

// Replace all items
controller.replaceAll(newItems);

// Remove item
controller.removeAt(index);

// Clear all
controller.clear();

// Check loading state
if (controller.isLoading) { ... }
```

## OptimizationConfig Options

```dart
OptimizedListView<MyItem>(
  controller: controller,
  config: OptimizationConfig(
    itemExtent: 72.0,          // Fixed item height (best performance)
    cacheExtent: 500.0,        // Cache extent in pixels
    useRepaintBoundary: true,  // Wrap items in RepaintBoundary
    keepAlive: false,          // Keep items alive when scrolled away
  ),
  // ...
)
```

## Pagination Configuration

```dart
OptimizedListView<MyItem>(
  controller: controller,
  enablePagination: true,
  loadMoreThreshold: 300.0,  // Pixels from bottom to trigger load
  onLoadMore: () async {
    // Fetch and add more items
    final items = await api.fetchPage(page++);
    controller.addItems(items);
  },
  loaderBuilder: (context) {
    return Center(child: CircularProgressIndicator());
  },
)
```

## Why Zero-Rebuild?

Traditional approach:
```dart
setState(() => items.add(newItem)); // Rebuilds ENTIRE list
```

With GT DataView:
```dart
controller.addItems(newItems); // Only NEW items build
controller.updateItem(5, item); // Only item at index 5 rebuilds
```

## License

MIT License - see [LICENSE](LICENSE) for details.
