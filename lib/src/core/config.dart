import 'package:flutter/rendering.dart';

export 'package:flutter/rendering.dart' show ScrollCacheExtent;

/// Configuration options for fine-tuning scrollable performance and item caching.
class OptimizationConfig {
  /// Whether each item should be isolated in a [RepaintBoundary].
  ///
  /// When `true`, repainting one item does not force neighboring items to repaint.
  /// When `false`, items share the viewport's paint layer, reducing memory overhead.
  final bool useRepaintBoundary;

  /// Whether items should automatically retain their state via [AutomaticKeepAlive].
  ///
  /// Defaults to `false`. Enable if items contain user input or media playback.
  final bool keepAlive;

  /// An optional fixed extent along the scroll axis for list items.
  ///
  /// Specifying [itemExtent] greatly optimizes layout calculations because
  /// Flutter does not need to measure item heights dynamically.
  final double? itemExtent;

  /// The scroll cache extent in logical pixels.
  ///
  /// Defaults to `250.0`.
  final double cacheExtent;

  /// An optional [ScrollCacheExtent] instance for fine-grained cache extent control.
  final ScrollCacheExtent? scrollCacheExtent;

  /// Creates a performance optimization configuration.
  const OptimizationConfig({
    this.useRepaintBoundary = false,
    this.keepAlive = false,
    this.itemExtent,
    this.cacheExtent = 250.0,
    this.scrollCacheExtent,
  });

  /// Returns the effective [ScrollCacheExtent] used by scroll views.
  ScrollCacheExtent get effectiveScrollCacheExtent =>
      scrollCacheExtent ?? ScrollCacheExtent.pixels(cacheExtent);
}
