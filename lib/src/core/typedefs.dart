import 'package:flutter/widgets.dart';

/// Callback invoked when the user scrolls near the threshold to load more data.
typedef OnLoadMore = Future<void> Function();

/// Builder for a custom loader widget displayed when loading more items.
typedef LoaderBuilder = Widget Function(BuildContext context);

/// Item builder providing the item instance and its position index.
typedef OptimizedItemBuilder<T> =
    Widget Function(BuildContext context, T item, int index);

/// Builder invoked when the list or grid has no items to display and is not loading.
typedef OptimizedEmptyBuilder = Widget Function(BuildContext context);

/// Builder for a custom error widget when loading more items fails.
typedef OptimizedErrorBuilder =
    Widget Function(BuildContext context, Object error, VoidCallback retry);
