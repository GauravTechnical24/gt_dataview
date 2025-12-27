/// GT DataView - High-performance Flutter list and grid view package.
///
/// This package provides:
/// - `OptimizedListView` - Zero-rebuild ListView with pagination
/// - `OptimizedGridView` - Zero-rebuild GridView with pagination
/// - `OptimizedListController` - ChangeNotifier-based state management
/// - `OptimizationConfig` - Performance tuning options
/// - Automatic pagination with load more threshold
/// - Custom loader widgets
library;

// Main Widgets
export 'master_listview.dart'
    show
        OptimizedListView,
        OptimizedGridView,
        OptimizedListController,
        OptimizationConfig,
        OnLoadMore,
        LoaderBuilder,
        OptimizedItemBuilder;
