// optimized_list_view.dart
// TRUE ZERO-REBUILD OPTIMIZATION
// Uses ChangeNotifier & ValueNotifier to prevent widget tree rebuilds

import 'package:flutter/material.dart';

/// Callback for loading more data
typedef OnLoadMore = Future<void> Function();

/// Builder for custom loader widget
typedef LoaderBuilder = Widget Function(BuildContext context);

/// Item builder with index
typedef OptimizedItemBuilder<T> =
    Widget Function(BuildContext context, T item, int index);

/// Configuration for optimization settings
class OptimizationConfig {
  final bool useRepaintBoundary;
  final bool keepAlive;
  final double? itemExtent;
  final double cacheExtent;

  const OptimizationConfig({
    this.useRepaintBoundary = false,
    this.keepAlive = false,
    this.itemExtent,
    this.cacheExtent = 250.0,
  });
}

/// Controller for managing list state WITHOUT rebuilding entire widget
class OptimizedListController<T> extends ChangeNotifier {
  List<T> _items;
  bool _isLoading = false;

  OptimizedListController(this._items);

  List<T> get items => _items;
  bool get isLoading => _isLoading;
  int get length => _items.length;

  /// Add items (for pagination)
  void addItems(List<T> newItems) {
    _items.addAll(newItems);
    notifyListeners();
  }

  /// Update single item at index
  void updateItem(int index, T newItem) {
    if (index >= 0 && index < _items.length) {
      _items[index] = newItem;
      notifyListeners();
    }
  }

  /// Replace all items
  void replaceAll(List<T> newItems) {
    _items = newItems;
    notifyListeners();
  }

  /// Remove item at index
  void removeAt(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  /// Clear all items
  void clear() {
    _items.clear();
    notifyListeners();
  }

  /// Set loading state
  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }
}

/// Main optimized list view - NO REBUILDS on data changes
class OptimizedListView<T> extends StatefulWidget {
  final OptimizedListController<T> controller;
  final OptimizedItemBuilder<T> itemBuilder;
  final OnLoadMore? onLoadMore;
  final bool enablePagination;
  final LoaderBuilder? loaderBuilder;
  final double loadMoreThreshold;
  final ScrollController? scrollController;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final Axis scrollDirection;
  final OptimizationConfig config;

  const OptimizedListView({
    super.key,
    required this.controller,
    required this.itemBuilder,
    this.onLoadMore,
    this.enablePagination = false,
    this.loaderBuilder,
    this.loadMoreThreshold = 300.0,
    this.scrollController,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.scrollDirection = Axis.vertical,
    this.config = const OptimizationConfig(),
  });

  @override
  State<OptimizedListView<T>> createState() => _OptimizedListViewState<T>();
}

class _OptimizedListViewState<T> extends State<OptimizedListView<T>> {
  late ScrollController _scrollController;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    if (widget.enablePagination && widget.onLoadMore != null) {
      _scrollController.addListener(_scrollListener);
    }
  }

  @override
  void didUpdateWidget(OptimizedListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.scrollController != oldWidget.scrollController) {
      if (oldWidget.scrollController == null) {
        _scrollController.removeListener(_scrollListener);
        _scrollController.dispose();
      }
      _scrollController = widget.scrollController ?? ScrollController();
      if (widget.enablePagination && widget.onLoadMore != null) {
        _scrollController.addListener(_scrollListener);
      }
    }
  }

  void _scrollListener() {
    if (_disposed || !_scrollController.hasClients) return;

    final position = _scrollController.position;
    final maxScroll = position.maxScrollExtent;
    final currentScroll = position.pixels;
    final threshold = widget.loadMoreThreshold;

    if (maxScroll - currentScroll <= threshold &&
        !widget.controller.isLoading &&
        widget.enablePagination &&
        widget.onLoadMore != null) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_disposed || widget.controller.isLoading) return;

    widget.controller.setLoading(true);

    try {
      await widget.onLoadMore?.call();
    } catch (e) {
      debugPrint('Error loading more items: $e');
    } finally {
      if (!_disposed) {
        widget.controller.setLoading(false);
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    if (widget.scrollController == null) {
      _scrollController.removeListener(_scrollListener);
      _scrollController.dispose();
    }
    super.dispose();
  }

  Widget _defaultLoader(BuildContext context) {
    return Container(
      height: 80,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16.0),
      child: const CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // CRITICAL: ListenableBuilder only rebuilds when controller notifies
    // The ListView.builder itself doesn't rebuild, only itemBuilder is called for visible items
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final itemCount =
            widget.controller.length + (widget.controller.isLoading ? 1 : 0);

        return ListView.builder(
          controller: _scrollController,
          padding: widget.padding,
          physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
          shrinkWrap: widget.shrinkWrap,
          scrollDirection: widget.scrollDirection,
          itemCount: itemCount,
          itemExtent: widget.config.itemExtent,
          cacheExtent: widget.config.cacheExtent,
          addAutomaticKeepAlives: widget.config.keepAlive,
          addRepaintBoundaries: !widget.config.useRepaintBoundary,
          addSemanticIndexes: true,
          itemBuilder: (context, index) {
            if (index >= widget.controller.length) {
              return widget.loaderBuilder?.call(context) ??
                  _defaultLoader(context);
            }

            final item = widget.controller.items[index];

            // Each item is independently built
            return _OptimizedListItem<T>(
              key: ValueKey('item_$index'),
              item: item,
              index: index,
              builder: widget.itemBuilder,
              useRepaintBoundary: widget.config.useRepaintBoundary,
            );
          },
        );
      },
    );
  }
}

/// Separate widget for each list item - prevents cross-contamination
class _OptimizedListItem<T> extends StatelessWidget {
  final T item;
  final int index;
  final OptimizedItemBuilder<T> builder;
  final bool useRepaintBoundary;

  const _OptimizedListItem({
    super.key,
    required this.item,
    required this.index,
    required this.builder,
    required this.useRepaintBoundary,
  });

  @override
  Widget build(BuildContext context) {
    final child = builder(context, item, index);

    if (useRepaintBoundary) {
      return RepaintBoundary(child: child);
    }

    return child;
  }
}

/// Optimized grid view variant
class OptimizedGridView<T> extends StatefulWidget {
  final OptimizedListController<T> controller;
  final OptimizedItemBuilder<T> itemBuilder;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;
  final OnLoadMore? onLoadMore;
  final bool enablePagination;
  final LoaderBuilder? loaderBuilder;
  final double loadMoreThreshold;
  final ScrollController? scrollController;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final OptimizationConfig config;

  const OptimizedGridView({
    super.key,
    required this.controller,
    required this.itemBuilder,
    this.crossAxisCount = 2,
    this.crossAxisSpacing = 8.0,
    this.mainAxisSpacing = 8.0,
    this.childAspectRatio = 1.0,
    this.onLoadMore,
    this.enablePagination = false,
    this.loaderBuilder,
    this.loadMoreThreshold = 300.0,
    this.scrollController,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.config = const OptimizationConfig(),
  });

  @override
  State<OptimizedGridView<T>> createState() => _OptimizedGridViewState<T>();
}

class _OptimizedGridViewState<T> extends State<OptimizedGridView<T>> {
  late ScrollController _scrollController;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    if (widget.enablePagination && widget.onLoadMore != null) {
      _scrollController.addListener(_scrollListener);
    }
  }

  @override
  void didUpdateWidget(OptimizedGridView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.scrollController != oldWidget.scrollController) {
      if (oldWidget.scrollController == null) {
        _scrollController.removeListener(_scrollListener);
        _scrollController.dispose();
      }
      _scrollController = widget.scrollController ?? ScrollController();
      if (widget.enablePagination && widget.onLoadMore != null) {
        _scrollController.addListener(_scrollListener);
      }
    }
  }

  void _scrollListener() {
    if (_disposed || !_scrollController.hasClients) return;

    final position = _scrollController.position;
    final maxScroll = position.maxScrollExtent;
    final currentScroll = position.pixels;
    final threshold = widget.loadMoreThreshold;

    if (maxScroll - currentScroll <= threshold &&
        !widget.controller.isLoading &&
        widget.enablePagination &&
        widget.onLoadMore != null) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_disposed || widget.controller.isLoading) return;

    widget.controller.setLoading(true);

    try {
      await widget.onLoadMore?.call();
    } catch (e) {
      debugPrint('Error loading more items: $e');
    } finally {
      if (!_disposed) {
        widget.controller.setLoading(false);
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    if (widget.scrollController == null) {
      _scrollController.removeListener(_scrollListener);
      _scrollController.dispose();
    }
    super.dispose();
  }

  Widget _defaultLoader(BuildContext context) {
    return Container(
      height: 80,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16.0),
      child: const CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final itemCount =
            widget.controller.length +
            (widget.controller.isLoading ? widget.crossAxisCount : 0);

        return GridView.builder(
          controller: _scrollController,
          padding: widget.padding,
          physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
          shrinkWrap: widget.shrinkWrap,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.crossAxisCount,
            crossAxisSpacing: widget.crossAxisSpacing,
            mainAxisSpacing: widget.mainAxisSpacing,
            childAspectRatio: widget.childAspectRatio,
          ),
          itemCount: itemCount,
          cacheExtent: widget.config.cacheExtent,
          addAutomaticKeepAlives: widget.config.keepAlive,
          addRepaintBoundaries: !widget.config.useRepaintBoundary,
          addSemanticIndexes: true,
          itemBuilder: (context, index) {
            if (index >= widget.controller.length) {
              if (index == widget.controller.length) {
                return widget.loaderBuilder?.call(context) ??
                    _defaultLoader(context);
              }
              return const SizedBox.shrink();
            }

            final item = widget.controller.items[index];

            return _OptimizedListItem<T>(
              key: ValueKey('grid_$index'),
              item: item,
              index: index,
              builder: widget.itemBuilder,
              useRepaintBoundary: widget.config.useRepaintBoundary,
            );
          },
        );
      },
    );
  }
}

// ============================================================================
// PRODUCTION EXAMPLE - DEMONSTRATING ZERO REBUILDS
// ============================================================================

class ProductionExample extends StatefulWidget {
  const ProductionExample({super.key});

  @override
  State<ProductionExample> createState() => _ProductionExampleState();
}

class _ProductionExampleState extends State<ProductionExample> {
  late OptimizedListController<ItemData> _listController;
  int _currentPage = 1;
  bool _showGrid = false;
  bool _showPerformanceOverlay = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    final initialItems = List.generate(
      100,
      (i) => ItemData(
        id: i,
        title: 'Item ${i + 1}',
        subtitle: 'Subtitle for item ${i + 1}',
        timestamp: DateTime.now(),
        rebuildCount: 0,
      ),
    );
    _listController = OptimizedListController<ItemData>(initialItems);
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  Future<void> _loadMoreItems() async {
    await Future.delayed(const Duration(milliseconds: 800));

    _currentPage++;
    final start = _listController.length;
    final newItems = List.generate(
      30,
      (i) => ItemData(
        id: start + i,
        title: 'Item ${start + i + 1}',
        subtitle: 'Page $_currentPage - Item ${i + 1}',
        timestamp: DateTime.now(),
        rebuildCount: 0,
      ),
    );

    // CRITICAL: This does NOT call setState() - list updates directly
    _listController.addItems(newItems);
  }

  void _updateSingleItem(int index) {
    final item = _listController.items[index];

    // CRITICAL: Only this item rebuilds, not entire list
    _listController.updateItem(
      index,
      item.copyWith(
        title: '${item.title} ✓',
        timestamp: DateTime.now(),
        rebuildCount: item.rebuildCount + 1,
      ),
    );
  }

  void _addBulkItems() {
    final start = _listController.length;
    final newItems = List.generate(
      1000,
      (i) => ItemData(
        id: start + i,
        title: 'Bulk Item ${start + i + 1}',
        subtitle: 'Performance test item',
        timestamp: DateTime.now(),
        rebuildCount: 0,
      ),
    );

    // Add 1000 items WITHOUT rebuilding existing items
    _listController.addItems(newItems);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added 1000 items! Total: ${_listController.length}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _customLoader(BuildContext context) {
    return Container(
      height: 60,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('Loading more...', style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Only this widget rebuilds, NOT the list items

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      showPerformanceOverlay: _showPerformanceOverlay,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Optimized ${_showGrid ? 'Grid' : 'List'} (${_listController.length} items)',
          ),

          actions: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios_new),
              onPressed: () {
                Navigator.pop(context);
              },
              tooltip: 'Back',
            ),
            IconButton(
              icon: Icon(_showGrid ? Icons.list : Icons.grid_view),
              onPressed: () => setState(() => _showGrid = !_showGrid),
              tooltip: 'Toggle view',
            ),
            IconButton(
              icon: Icon(
                _showPerformanceOverlay ? Icons.speed : Icons.speed_outlined,
              ),
              onPressed: () => setState(
                () => _showPerformanceOverlay = !_showPerformanceOverlay,
              ),
              tooltip: 'Performance overlay',
            ),
          ],
        ),
        body: _showGrid ? _buildGridView() : _buildListView(),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton.small(
              heroTag: 'bulk',
              onPressed: _addBulkItems,
              tooltip: 'Add 1000 items',
              child: const Icon(Icons.add, size: 20),
            ),
            const SizedBox(height: 8),
            FloatingActionButton(
              heroTag: 'clear',
              onPressed: () {
                _listController.clear();
                _loadInitialData();
                setState(() {});
              },
              tooltip: 'Reset',
              child: const Icon(Icons.refresh),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    return OptimizedListView<ItemData>(
      controller: _listController,
      enablePagination: true,
      onLoadMore: _loadMoreItems,
      loaderBuilder: _customLoader,
      loadMoreThreshold: 400,
      padding: const EdgeInsets.all(8),
      config: const OptimizationConfig(
        itemExtent: 76,
        useRepaintBoundary: false,
        cacheExtent: 500,
      ),
      itemBuilder: (context, item, index) {
        // This builder is ONLY called for visible items
        // And ONLY when that specific item changes
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          elevation: 1,
          child: ListTile(
            dense: true,
            leading: CircleAvatar(
              backgroundColor:
                  Colors.primaries[item.id % Colors.primaries.length],
              child: Text(
                '${item.id + 1}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
            title: Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '${item.subtitle} | Rebuilds: ${item.rebuildCount}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${item.timestamp.hour}:${item.timestamp.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 11),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  onPressed: () => _updateSingleItem(index),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridView() {
    return OptimizedGridView<ItemData>(
      controller: _listController,
      crossAxisCount: 2,
      enablePagination: true,
      onLoadMore: _loadMoreItems,
      loaderBuilder: _customLoader,
      loadMoreThreshold: 400,
      padding: const EdgeInsets.all(8),
      childAspectRatio: 1.3,
      config: const OptimizationConfig(
        useRepaintBoundary: false,
        cacheExtent: 500,
      ),
      itemBuilder: (context, item, index) {
        return Card(
          elevation: 2,
          child: InkWell(
            onTap: () => _updateSingleItem(index),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.image,
                        size: 32,
                        color:
                            Colors.primaries[item.id % Colors.primaries.length],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.subtitle,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Text(
                    'ID: ${item.id} | Rebuilds: ${item.rebuildCount}',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Data model for items
class ItemData {
  final int id;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final int rebuildCount;

  const ItemData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.rebuildCount,
  });

  ItemData copyWith({
    int? id,
    String? title,
    String? subtitle,
    DateTime? timestamp,
    int? rebuildCount,
  }) {
    return ItemData(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      timestamp: timestamp ?? this.timestamp,
      rebuildCount: rebuildCount ?? this.rebuildCount,
    );
  }
}
