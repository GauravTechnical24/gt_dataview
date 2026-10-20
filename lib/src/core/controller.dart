import 'package:flutter/foundation.dart';

/// High-performance controller for managing list and grid items without rebuilding
/// the outer widget tree.
///
/// Uses [ChangeNotifier] to signal fine-grained state updates to listeners such as
/// [ListenableBuilder].
class OptimizedListController<T> extends ChangeNotifier {
  List<T> _items;
  bool _isLoading = false;
  Object? _error;
  bool _isDisposed = false;

  /// Creates a controller initialized with the provided [initialItems].
  OptimizedListController([List<T>? initialItems])
    : _items = initialItems != null ? List<T>.from(initialItems) : <T>[];

  /// The list of items managed by this controller.
  List<T> get items => _items;

  /// Whether a data loading or pagination operation is currently in progress.
  bool get isLoading => _isLoading;

  /// The last recorded error during an operation, if any.
  Object? get error => _error;

  /// Whether an error is currently active.
  bool get hasError => _error != null;

  /// The total number of items currently held in the controller.
  int get length => _items.length;

  /// Whether the controller currently holds no items.
  bool get isEmpty => _items.isEmpty;

  /// Whether the controller currently holds at least one item.
  bool get isNotEmpty => _items.isNotEmpty;

  /// Whether this controller has already been disposed.
  bool get isDisposed => _isDisposed;

  /// Returns the item at the specified [index].
  T operator [](int index) => _items[index];

  /// Appends [newItems] to the end of the collection (e.g. for pagination).
  void addItems(List<T> newItems) {
    if (_isDisposed || newItems.isEmpty) return;
    _items.addAll(newItems);
    _notifySafely();
  }

  /// Appends a single [item] to the end of the collection.
  void addItem(T item) {
    if (_isDisposed) return;
    _items.add(item);
    _notifySafely();
  }

  /// Inserts an [item] at the specified [index].
  void insert(int index, T item) {
    if (_isDisposed) return;
    if (index >= 0 && index <= _items.length) {
      _items.insert(index, item);
      _notifySafely();
    }
  }

  /// Updates a single item at [index].
  ///
  /// Only the widget rendering this item is rebuilt if configured with isolated item keys.
  void updateItem(int index, T newItem) {
    if (_isDisposed) return;
    if (index >= 0 && index < _items.length) {
      _items[index] = newItem;
      _notifySafely();
    }
  }

  /// Replaces all current items with [newItems].
  void replaceAll(List<T> newItems) {
    if (_isDisposed) return;
    _items = List<T>.from(newItems);
    _notifySafely();
  }

  /// Removes the item at [index] from the collection.
  void removeAt(int index) {
    if (_isDisposed) return;
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      _notifySafely();
    }
  }

  /// Removes the first occurrence of [item] from the collection.
  ///
  /// Returns `true` if an item was removed, or `false` otherwise.
  bool remove(T item) {
    if (_isDisposed) return false;
    final removed = _items.remove(item);
    if (removed) {
      _notifySafely();
    }
    return removed;
  }

  /// Clears all items and resets error state.
  void clear() {
    if (_isDisposed) return;
    _items.clear();
    _error = null;
    _notifySafely();
  }

  /// Sets the loading state and notifies listeners if the value changed.
  void setLoading(bool loading) {
    if (_isDisposed || _isLoading == loading) return;
    _isLoading = loading;
    _notifySafely();
  }

  /// Sets an active error state and notifies listeners.
  void setError(Object? error) {
    if (_isDisposed || _error == error) return;
    _error = error;
    _notifySafely();
  }

  /// Clears any active error.
  void clearError() {
    if (_isDisposed || _error == null) return;
    _error = null;
    _notifySafely();
  }

  void _notifySafely() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
