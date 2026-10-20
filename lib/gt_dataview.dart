/// GT DataView - High-performance Flutter list and grid view package with
/// zero-rebuild architecture, automatic pagination, and separated Material and Cupertino implementations.
///
/// This package provides:
/// - [OptimizedListView] - Material zero-rebuild ListView with pagination and custom loaders.
/// - [OptimizedGridView] - Material zero-rebuild GridView with pagination and configurable columns.
/// - [CupertinoOptimizedListView] - Cupertino-native ListView with iOS bouncing physics and activity indicators.
/// - [CupertinoOptimizedGridView] - Cupertino-native GridView with iOS bouncing physics and activity indicators.
/// - [OptimizedListController] - ChangeNotifier-based fine-grained state management without outer widget rebuilds.
/// - [OptimizationConfig] - Performance tuning for repaint boundaries, keep-alives, item extent, and cache buffers.
library;

export 'src/core/config.dart';
export 'src/core/controller.dart';
export 'src/core/typedefs.dart';
export 'src/cupertino/cupertino_list_view.dart';
export 'src/material/material_list_view.dart';
