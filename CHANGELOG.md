# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-10-20

### Added
- **Material and Cupertino UI Separation**:
  - `CupertinoOptimizedListView` - iOS-native list view featuring `CupertinoActivityIndicator` loader and `BouncingScrollPhysics`.
  - `CupertinoOptimizedGridView` - iOS-native grid view with bouncing physics and native styling.
- **Enhanced Controller API**:
  - `addItem(T item)` - Add a single item efficiently.
  - `insert(int index, T item)` - Insert an item at a specific position with boundary safety.
  - `remove(T item)` - Remove a specific item instance.
  - `setError(Object? error)` & `clearError()` - Manage error states during pagination.
  - `operator [](int index)` - Index-based element access.
  - `isEmpty` & `isNotEmpty` convenience getters.
  - `isDisposed` flag ensuring safe no-op on async operations after controller disposal.
- **Empty and Error State Handlers**:
  - Added optional `emptyBuilder` to `OptimizedListView`, `OptimizedGridView`, `CupertinoOptimizedListView`, and `CupertinoOptimizedGridView`.
  - Added optional `errorBuilder` for graceful error rendering and retry handling.
- **Modern Cache Extent Support**:
  - Added support for `ScrollCacheExtent` in `OptimizationConfig` to align with modern Flutter SDKs while preserving backward compatibility for `cacheExtent`.
  - Exported `ScrollCacheExtent` from `package:flutter/rendering.dart` for direct consumer access.

### Changed
- Refactored project architecture into clean modular internal packages:
  - `lib/src/core/` for controllers, configurations, and typedefs.
  - `lib/src/material/` for Material widgets.
  - `lib/src/cupertino/` for Cupertino widgets.
- Upgraded development dependency `flutter_lints` to `^6.0.0`.
- Deprecated `OptimizationConfig.cacheExtent` in favor of `scrollCacheExtent` to eliminate framework deprecation warnings.
- Preserved legacy `lib/master_listview.dart` as a backward-compatible export.

### Fixed
- Resolved deprecated member use warning for `cacheExtent` on modern Flutter SDKs.
- Fixed `addRepaintBoundaries` inversion bug where items inadvertently kept repaint boundaries even when `useRepaintBoundary` was false.
- Fixed scroll listener attachment lifecycle in `didUpdateWidget` when `enablePagination` or `onLoadMore` changed dynamically.
- Fixed scroll controller disposal memory leak when swapping custom scroll controllers.
- Removed non-library demo widgets (`ProductionExample`, `ItemData`) from the root package exports.

### Compatibility
- Flutter SDK: `>=3.44.2`
- Dart SDK: `>=3.12.0 <4.0.0`
- Supported Platforms: Android, iOS, Web (WASM-ready), macOS, Linux, Windows.

## [1.1.0] - 2026-06-19

### Changed
- Updated SDK constraints for Flutter 3.44+ and Dart 3.12+.
- Improved internal list rebuild efficiency.

## [1.0.0] - 2025-12-27

### Added
- `OptimizedListView<T>` - Zero-rebuild ListView with automatic pagination and loader support.
- `OptimizedGridView<T>` - Zero-rebuild GridView with fixed cross-axis count and pagination.
- `OptimizedListController<T>` - ChangeNotifier-based controller for CRUD operations without rebuilding outer widgets.
- `OptimizationConfig` - Performance tuning options (`itemExtent`, `cacheExtent`, `useRepaintBoundary`, `keepAlive`).
