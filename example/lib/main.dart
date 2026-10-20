import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gt_dataview/gt_dataview.dart';

void main() {
  runApp(const GTDataViewExampleApp());
}

/// Data model representing a modern transaction or analytics entry.
class DataItem {
  final int id;
  final String title;
  final String category;
  final double amount;
  final DateTime timestamp;
  final IconData icon;
  final Color color;
  final int rebuildCount;
  final bool isStarred;

  const DataItem({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.timestamp,
    required this.icon,
    required this.color,
    this.rebuildCount = 0,
    this.isStarred = false,
  });

  DataItem copyWith({
    String? title,
    String? category,
    double? amount,
    DateTime? timestamp,
    IconData? icon,
    Color? color,
    int? rebuildCount,
    bool? isStarred,
  }) {
    return DataItem(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      timestamp: timestamp ?? this.timestamp,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      rebuildCount: rebuildCount ?? this.rebuildCount,
      isStarred: isStarred ?? this.isStarred,
    );
  }
}

/// Root widget with dynamic ThemeMode support (Light / Dark).
class GTDataViewExampleApp extends StatefulWidget {
  const GTDataViewExampleApp({super.key});

  @override
  State<GTDataViewExampleApp> createState() => _GTDataViewExampleAppState();
}

class _GTDataViewExampleAppState extends State<GTDataViewExampleApp> {
  ThemeMode _themeMode = ThemeMode.system;
  bool _useCupertino = false;

  void _toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.dark) {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.dark;
      }
    });
  }

  void _togglePlatformStyle() {
    setState(() {
      _useCupertino = !_useCupertino;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_useCupertino) {
      final isDark =
          _themeMode == ThemeMode.dark ||
          (_themeMode == ThemeMode.system &&
              MediaQuery.platformBrightnessOf(context) == Brightness.dark);

      return CupertinoApp(
        title: 'GT DataView Modern UI',
        debugShowCheckedModeBanner: false,
        theme: CupertinoThemeData(
          brightness: isDark ? Brightness.dark : Brightness.light,
          primaryColor: CupertinoColors.activeBlue,
          scaffoldBackgroundColor: isDark
              ? const Color(0xFF0F1117)
              : const Color(0xFFF7F8FA),
        ),
        home: ModernCupertinoScreen(
          isDark: isDark,
          onToggleTheme: _toggleTheme,
          onToggleStyle: _togglePlatformStyle,
        ),
      );
    }

    // Material 3 Custom ColorSchemes
    const seedColor = Color(0xFF6366F1); // Indigo Modern Accent

    return MaterialApp(
      title: 'GT DataView Modern UI',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          color: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Deep Slate
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF1E293B)),
          ),
          color: const Color(0xFF1E293B),
        ),
      ),
      home: ModernMaterialScreen(
        isDark: _themeMode == ThemeMode.dark,
        onToggleTheme: _toggleTheme,
        onToggleStyle: _togglePlatformStyle,
      ),
    );
  }
}

/// Sample data generator.
List<DataItem> _generateSampleItems(int count, {int startIndex = 0}) {
  final categories = ['Cloud', 'Payment', 'Design', 'Server', 'Security'];
  final icons = [
    Icons.cloud_outlined,
    Icons.credit_card_outlined,
    Icons.palette_outlined,
    Icons.storage_outlined,
    Icons.shield_outlined,
  ];
  final colors = [
    const Color(0xFF3B82F6),
    const Color(0xFF10B981),
    const Color(0xFFEC4899),
    const Color(0xFF8B5CF6),
    const Color(0xFFF59E0B),
  ];

  final random = Random(startIndex);
  return List.generate(count, (i) {
    final idx = startIndex + i;
    final catIndex = idx % categories.length;
    return DataItem(
      id: idx + 1,
      title: '${categories[catIndex]} Service #${idx + 1}',
      category: categories[catIndex],
      amount: (random.nextDouble() * 300 + 15).roundToDouble(),
      timestamp: DateTime.now().subtract(Duration(minutes: idx * 14)),
      icon: icons[catIndex],
      color: colors[catIndex],
      rebuildCount: 0,
      isStarred: idx % 4 == 0,
    );
  });
}

// ============================================================================
// MATERIAL 3 MODERN IMPLEMENTATION
// ============================================================================

class ModernMaterialScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;
  final VoidCallback onToggleStyle;

  const ModernMaterialScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
    required this.onToggleStyle,
  });

  @override
  State<ModernMaterialScreen> createState() => _ModernMaterialScreenState();
}

class _ModernMaterialScreenState extends State<ModernMaterialScreen> {
  late OptimizedListController<DataItem> _controller;
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    _controller = OptimizedListController<DataItem>(_generateSampleItems(20));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadMore() async {
    await Future.delayed(const Duration(milliseconds: 700));
    final newItems = _generateSampleItems(12, startIndex: _controller.length);
    _controller.addItems(newItems);
  }

  void _addBulk(int count) {
    final bulk = _generateSampleItems(count, startIndex: _controller.length);
    _controller.addItems(bulk);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $count items with 0 outer rebuilds!'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleStarred(int index) {
    final item = _controller[index];
    _controller.updateItem(
      index,
      item.copyWith(
        isStarred: !item.isStarred,
        rebuildCount: item.rebuildCount + 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'GT DataView',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            ListenableBuilder(
              listenable: _controller,
              builder: (context, _) => Text(
                '${_controller.length} live items • Zero-Rebuild Active',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Switch to Cupertino Theme',
            icon: const Icon(Icons.phone_iphone_outlined),
            onPressed: widget.onToggleStyle,
          ),
          IconButton(
            tooltip: widget.isDark
                ? 'Switch to Light Mode'
                : 'Switch to Dark Mode',
            icon: Icon(
              widget.isDark ? Icons.light_mode : Icons.dark_mode_outlined,
            ),
            onPressed: widget.onToggleTheme,
          ),
          IconButton(
            tooltip: _isGridView ? 'Switch to List' : 'Switch to Grid',
            icon: Icon(
              _isGridView
                  ? Icons.view_agenda_outlined
                  : Icons.grid_view_outlined,
            ),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Action & Stats Quick Bar
          _buildQuickActionBar(colorScheme),
          // Scrollable View
          Expanded(
            child: _isGridView
                ? _buildGridView(colorScheme)
                : _buildListView(colorScheme),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addBulk(100),
        icon: const Icon(Icons.flash_on),
        label: const Text('Add 100 Items'),
      ),
    );
  }

  Widget _buildQuickActionBar(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ActionChip(
              avatar: const Icon(Icons.refresh, size: 16),
              label: const Text('Reset'),
              onPressed: () {
                _controller.replaceAll(_generateSampleItems(20));
              },
            ),
            const SizedBox(width: 8),
            ActionChip(
              avatar: const Icon(Icons.add, size: 16),
              label: const Text('+500 High-Load'),
              onPressed: () => _addBulk(500),
            ),
            const SizedBox(width: 8),
            ActionChip(
              avatar: const Icon(Icons.delete_sweep_outlined, size: 16),
              label: const Text('Clear All'),
              onPressed: () => _controller.clear(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(ColorScheme colorScheme) {
    return OptimizedListView<DataItem>(
      controller: _controller,
      enablePagination: true,
      onLoadMore: _loadMore,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      config: const OptimizationConfig(itemExtent: 96),
      emptyBuilder: (context) => _buildEmptyState(colorScheme),
      loaderBuilder: (context) => _buildLoader(colorScheme),
      itemBuilder: (context, item, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: item.color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.category,
                              style: TextStyle(
                                fontSize: 10,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Rebuilds: ${item.rebuildCount}',
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '\$${item.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _toggleStarred(index),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          item.isStarred ? Icons.star : Icons.star_border,
                          color: item.isStarred
                              ? Colors.amber
                              : colorScheme.outline,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridView(ColorScheme colorScheme) {
    return OptimizedGridView<DataItem>(
      controller: _controller,
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.15,
      padding: const EdgeInsets.all(16),
      enablePagination: true,
      onLoadMore: _loadMore,
      emptyBuilder: (context) => _buildEmptyState(colorScheme),
      loaderBuilder: (context) => _buildLoader(colorScheme),
      itemBuilder: (context, item, index) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon, color: item.color, size: 20),
                    ),
                    IconButton(
                      icon: Icon(
                        item.isStarred ? Icons.star : Icons.star_border,
                        color: item.isStarred
                            ? Colors.amber
                            : colorScheme.outline,
                        size: 20,
                      ),
                      onPressed: () => _toggleStarred(index),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${item.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'R:${item.rebuildCount}',
                      style: TextStyle(
                        fontSize: 10,
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: colorScheme.outline),
            const SizedBox(height: 16),
            const Text(
              'No Data Items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Use the button below to populate fresh zero-rebuild items.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _controller.replaceAll(_generateSampleItems(20)),
              icon: const Icon(Icons.add),
              label: const Text('Generate Demo Data'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoader(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(
            'Fetching more records...',
            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// CUPERTINO MODERN IMPLEMENTATION
// ============================================================================

class ModernCupertinoScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;
  final VoidCallback onToggleStyle;

  const ModernCupertinoScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
    required this.onToggleStyle,
  });

  @override
  State<ModernCupertinoScreen> createState() => _ModernCupertinoScreenState();
}

class _ModernCupertinoScreenState extends State<ModernCupertinoScreen> {
  late OptimizedListController<DataItem> _controller;
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    _controller = OptimizedListController<DataItem>(_generateSampleItems(20));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadMore() async {
    await Future.delayed(const Duration(milliseconds: 700));
    final newItems = _generateSampleItems(12, startIndex: _controller.length);
    _controller.addItems(newItems);
  }

  void _toggleStarred(int index) {
    final item = _controller[index];
    _controller.updateItem(
      index,
      item.copyWith(
        isStarred: !item.isStarred,
        rebuildCount: item.rebuildCount + 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = widget.isDark
        ? const Color(0xFF1E222D)
        : CupertinoColors.white;
    final borderColor = widget.isDark
        ? const Color(0xFF2C3240)
        : const Color(0xFFE5E7EB);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => Text(
            'GT DataView (${_controller.length})',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: widget.onToggleStyle,
              child: const Icon(CupertinoIcons.device_laptop, size: 22),
            ),
            const SizedBox(width: 8),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: widget.onToggleTheme,
              child: Icon(
                widget.isDark ? CupertinoIcons.sun_max : CupertinoIcons.moon,
                size: 22,
              ),
            ),
            const SizedBox(width: 8),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => setState(() => _isGridView = !_isGridView),
              child: Icon(
                _isGridView
                    ? CupertinoIcons.list_bullet
                    : CupertinoIcons.square_grid_2x2,
                size: 22,
              ),
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Controls header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  CupertinoButton.filled(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    onPressed: () {
                      _controller.replaceAll(_generateSampleItems(20));
                    },
                    child: const Text('Reset', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    color: CupertinoColors.activeGreen,
                    onPressed: () {
                      final bulk = _generateSampleItems(
                        100,
                        startIndex: _controller.length,
                      );
                      _controller.addItems(bulk);
                    },
                    child: const Text(
                      '+100 Items',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  const Spacer(),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _controller.clear(),
                    child: const Text(
                      'Clear',
                      style: TextStyle(
                        fontSize: 13,
                        color: CupertinoColors.destructiveRed,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isGridView
                  ? _buildCupertinoGrid(cardColor, borderColor)
                  : _buildCupertinoList(cardColor, borderColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCupertinoList(Color cardColor, Color borderColor) {
    return CupertinoOptimizedListView<DataItem>(
      controller: _controller,
      enablePagination: true,
      onLoadMore: _loadMore,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      config: const OptimizationConfig(itemExtent: 80),
      emptyBuilder: (context) =>
          const Center(child: Text('No Cupertino items available')),
      itemBuilder: (context, item, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Icon(item.icon, color: item.color, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${item.category} • Rebuilds: ${item.rebuildCount}',
                      style: TextStyle(
                        fontSize: 11,
                        color: widget.isDark
                            ? CupertinoColors.systemGrey
                            : CupertinoColors.systemGrey2,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${item.amount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _toggleStarred(index),
                child: Icon(
                  item.isStarred
                      ? CupertinoIcons.star_fill
                      : CupertinoIcons.star,
                  color: item.isStarred
                      ? CupertinoColors.systemYellow
                      : CupertinoColors.systemGrey,
                  size: 20,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCupertinoGrid(Color cardColor, Color borderColor) {
    return CupertinoOptimizedGridView<DataItem>(
      controller: _controller,
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.15,
      padding: const EdgeInsets.all(16),
      enablePagination: true,
      onLoadMore: _loadMore,
      emptyBuilder: (context) => const Center(child: Text('No items in Grid')),
      itemBuilder: (context, item, index) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(item.icon, color: item.color, size: 24),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _toggleStarred(index),
                    child: Icon(
                      item.isStarred
                          ? CupertinoIcons.star_fill
                          : CupertinoIcons.star,
                      color: item.isStarred
                          ? CupertinoColors.systemYellow
                          : CupertinoColors.systemGrey,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                item.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${item.amount.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'R:${item.rebuildCount}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
