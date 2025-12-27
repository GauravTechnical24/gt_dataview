# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2025-12-27

### Added
- `OptimizedListView<T>` - Zero-rebuild ListView
  - Automatic pagination with threshold detection
  - Custom loader widget support
  - Configurable scroll direction and physics
  - Performance optimization config
- `OptimizedGridView<T>` - Zero-rebuild GridView
  - SliverGridDelegateWithFixedCrossAxisCount support
  - Configurable spacing and aspect ratio
  - Pagination support
- `OptimizedListController<T>` - ChangeNotifier-based controller
  - `addItems()` - Append items for pagination
  - `updateItem()` - Update single item without full rebuild
  - `replaceAll()` - Replace all items
  - `removeAt()` - Remove item at index
  - `clear()` - Clear all items
  - `setLoading()` - Manage loading state
- `OptimizationConfig` - Performance tuning
  - `itemExtent` - Fixed item height for best performance
  - `cacheExtent` - Scroll cache size
  - `useRepaintBoundary` - Isolate item repaints
  - `keepAlive` - Keep items alive when scrolled away
- Type definitions
  - `OnLoadMore` - Pagination callback
  - `LoaderBuilder` - Custom loader widget builder
  - `OptimizedItemBuilder<T>` - Item builder with index
