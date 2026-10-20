import 'package:flutter/material.dart';

import '../core/config.dart';
import '../core/controller.dart';
import '../core/typedefs.dart';

/// High-performance Material ListView with zero-rebuild optimization and pagination support.
class OptimizedListView<T> extends StatefulWidget {
  /// The controller holding items and managing loading/error states.
  final OptimizedListController<T> controller;

  /// Builder for rendering individual items.
  final OptimizedItemBuilder<T> itemBuilder;

  /// Callback triggered when scrolling reaches the [loadMoreThreshold].
  final OnLoadMore? onLoadMore;

  /// Whether automatic pagination is enabled. Defaults to `false`.
  final bool enablePagination;

  /// Optional builder for a custom pagination loader widget.
  final LoaderBuilder? loaderBuilder;

  /// Optional builder for empty state when items list is empty and not loading.
  final OptimizedEmptyBuilder? emptyBuilder;

  /// Optional builder when pagination encounters an error.
  final OptimizedErrorBuilder? errorBuilder;

  /// Distance in logical pixels from the bottom of the scroll view to trigger [onLoadMore].
  final double loadMoreThreshold;

  /// Optional external scroll controller.
  final ScrollController? scrollController;

  /// Padding applied around the scroll view.
  final EdgeInsetsGeometry? padding;

  /// Scroll physics determining scroll behavior.
  final ScrollPhysics? physics;

  /// Whether the scroll view should size itself to the extent of its children.
  final bool shrinkWrap;

  /// The axis along which the scroll view scrolls. Defaults to [Axis.vertical].
  final Axis scrollDirection;

  /// Performance tuning options including repaint boundary and cache extent.
  final OptimizationConfig config;

  /// Creates an optimized Material list view.
  const OptimizedListView({
    super.key,
    required this.controller,
    required this.itemBuilder,
    this.onLoadMore,
    this.enablePagination = false,
    this.loaderBuilder,
    this.emptyBuilder,
    this.errorBuilder,
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
  ScrollController? _internalController;
  ScrollController get _effectiveController =>
      widget.scrollController ?? (_internalController ??= ScrollController());
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _attachListener();
  }

  void _attachListener() {
    if (widget.enablePagination && widget.onLoadMore != null) {
      _effectiveController.addListener(_scrollListener);
    }
  }

  void _detachListener([ScrollController? controller]) {
    final target = controller ?? _effectiveController;
    target.removeListener(_scrollListener);
  }

  @override
  void didUpdateWidget(OptimizedListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    final controllerChanged =
        widget.scrollController != oldWidget.scrollController;
    final paginationChanged =
        widget.enablePagination != oldWidget.enablePagination ||
        widget.onLoadMore != oldWidget.onLoadMore;

    if (controllerChanged) {
      if (oldWidget.scrollController != null) {
        _detachListener(oldWidget.scrollController);
      } else {
        _detachListener(_internalController);
        _internalController?.dispose();
        _internalController = null;
      }
      _attachListener();
    } else if (paginationChanged) {
      _detachListener();
      _attachListener();
    }
  }

  void _scrollListener() {
    if (_disposed || !_effectiveController.hasClients) return;

    final position = _effectiveController.position;
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
    widget.controller.clearError();

    try {
      await widget.onLoadMore?.call();
    } catch (e) {
      if (!_disposed) {
        widget.controller.setError(e);
      }
      debugPrint('gt_dataview: Error loading more items: $e');
    } finally {
      if (!_disposed) {
        widget.controller.setLoading(false);
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _detachListener();
    _internalController?.dispose();
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
        if (widget.controller.isEmpty &&
            !widget.controller.isLoading &&
            widget.emptyBuilder != null) {
          return widget.emptyBuilder!(context);
        }

        final showFooter =
            widget.controller.isLoading ||
            (widget.controller.hasError && widget.errorBuilder != null);
        final itemCount = widget.controller.length + (showFooter ? 1 : 0);

        return ListView.builder(
          controller: _effectiveController,
          padding: widget.padding,
          physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
          shrinkWrap: widget.shrinkWrap,
          scrollDirection: widget.scrollDirection,
          itemCount: itemCount,
          itemExtent: widget.config.itemExtent,
          scrollCacheExtent: widget.config.effectiveScrollCacheExtent,
          addAutomaticKeepAlives: widget.config.keepAlive,
          addRepaintBoundaries: widget.config.useRepaintBoundary,
          addSemanticIndexes: true,
          itemBuilder: (context, index) {
            if (index >= widget.controller.length) {
              if (widget.controller.hasError && widget.errorBuilder != null) {
                return widget.errorBuilder!(
                  context,
                  widget.controller.error!,
                  _loadMore,
                );
              }
              return widget.loaderBuilder?.call(context) ??
                  _defaultLoader(context);
            }

            final item = widget.controller.items[index];
            return _OptimizedListItem<T>(
              key: ValueKey<int>(index),
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

/// High-performance Material GridView with zero-rebuild optimization and pagination support.
class OptimizedGridView<T> extends StatefulWidget {
  /// The controller holding items and managing loading/error states.
  final OptimizedListController<T> controller;

  /// Builder for rendering individual items.
  final OptimizedItemBuilder<T> itemBuilder;

  /// Number of grid columns along the cross axis. Defaults to 2.
  final int crossAxisCount;

  /// Spacing between adjacent columns along the cross axis. Defaults to 8.0.
  final double crossAxisSpacing;

  /// Spacing between adjacent rows along the main axis. Defaults to 8.0.
  final double mainAxisSpacing;

  /// Ratio of cross-axis to main-axis extent of each child. Defaults to 1.0.
  final double childAspectRatio;

  /// Callback triggered when scrolling reaches the [loadMoreThreshold].
  final OnLoadMore? onLoadMore;

  /// Whether automatic pagination is enabled. Defaults to `false`.
  final bool enablePagination;

  /// Optional builder for a custom pagination loader widget.
  final LoaderBuilder? loaderBuilder;

  /// Optional builder for empty state when items list is empty and not loading.
  final OptimizedEmptyBuilder? emptyBuilder;

  /// Optional builder when pagination encounters an error.
  final OptimizedErrorBuilder? errorBuilder;

  /// Distance in logical pixels from the bottom of the scroll view to trigger [onLoadMore].
  final double loadMoreThreshold;

  /// Optional external scroll controller.
  final ScrollController? scrollController;

  /// Padding applied around the scroll view.
  final EdgeInsetsGeometry? padding;

  /// Scroll physics determining scroll behavior.
  final ScrollPhysics? physics;

  /// Whether the scroll view should size itself to the extent of its children.
  final bool shrinkWrap;

  /// Performance tuning options including repaint boundary and cache extent.
  final OptimizationConfig config;

  /// Creates an optimized Material grid view.
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
    this.emptyBuilder,
    this.errorBuilder,
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
  ScrollController? _internalController;
  ScrollController get _effectiveController =>
      widget.scrollController ?? (_internalController ??= ScrollController());
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _attachListener();
  }

  void _attachListener() {
    if (widget.enablePagination && widget.onLoadMore != null) {
      _effectiveController.addListener(_scrollListener);
    }
  }

  void _detachListener([ScrollController? controller]) {
    final target = controller ?? _effectiveController;
    target.removeListener(_scrollListener);
  }

  @override
  void didUpdateWidget(OptimizedGridView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    final controllerChanged =
        widget.scrollController != oldWidget.scrollController;
    final paginationChanged =
        widget.enablePagination != oldWidget.enablePagination ||
        widget.onLoadMore != oldWidget.onLoadMore;

    if (controllerChanged) {
      if (oldWidget.scrollController != null) {
        _detachListener(oldWidget.scrollController);
      } else {
        _detachListener(_internalController);
        _internalController?.dispose();
        _internalController = null;
      }
      _attachListener();
    } else if (paginationChanged) {
      _detachListener();
      _attachListener();
    }
  }

  void _scrollListener() {
    if (_disposed || !_effectiveController.hasClients) return;

    final position = _effectiveController.position;
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
    widget.controller.clearError();

    try {
      await widget.onLoadMore?.call();
    } catch (e) {
      if (!_disposed) {
        widget.controller.setError(e);
      }
      debugPrint('gt_dataview: Error loading more grid items: $e');
    } finally {
      if (!_disposed) {
        widget.controller.setLoading(false);
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _detachListener();
    _internalController?.dispose();
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
        if (widget.controller.isEmpty &&
            !widget.controller.isLoading &&
            widget.emptyBuilder != null) {
          return widget.emptyBuilder!(context);
        }

        final showFooter =
            widget.controller.isLoading ||
            (widget.controller.hasError && widget.errorBuilder != null);
        final itemCount =
            widget.controller.length + (showFooter ? widget.crossAxisCount : 0);

        return GridView.builder(
          controller: _effectiveController,
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
          scrollCacheExtent: widget.config.effectiveScrollCacheExtent,
          addAutomaticKeepAlives: widget.config.keepAlive,
          addRepaintBoundaries: widget.config.useRepaintBoundary,
          addSemanticIndexes: true,
          itemBuilder: (context, index) {
            if (index >= widget.controller.length) {
              if (index == widget.controller.length) {
                if (widget.controller.hasError && widget.errorBuilder != null) {
                  return widget.errorBuilder!(
                    context,
                    widget.controller.error!,
                    _loadMore,
                  );
                }
                return widget.loaderBuilder?.call(context) ??
                    _defaultLoader(context);
              }
              return const SizedBox.shrink();
            }

            final item = widget.controller.items[index];
            return _OptimizedListItem<T>(
              key: ValueKey<int>(index),
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

/// Internal wrapper widget ensuring independent rebuilding of list/grid items.
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
