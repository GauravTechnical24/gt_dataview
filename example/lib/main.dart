import 'package:flutter/material.dart';
import 'package:gt_dataview/gt_dataview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GT DataView Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const DataViewExampleScreen(),
    );
  }
}

class DataViewExampleScreen extends StatefulWidget {
  const DataViewExampleScreen({super.key});

  @override
  State<DataViewExampleScreen> createState() => _DataViewExampleScreenState();
}

class _DataViewExampleScreenState extends State<DataViewExampleScreen> {
  late OptimizedListController<String> _controller;
  bool _showGrid = false;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _controller = OptimizedListController<String>(
      List.generate(20, (i) => 'Item ${i + 1}'),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadMore() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));

    _page++;
    final start = _controller.length;
    final newItems = List.generate(
      10,
      (i) => 'Item ${start + i + 1} (Page $_page)',
    );
    _controller.addItems(newItems);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GT DataView (${_controller.length} items)'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(_showGrid ? Icons.list : Icons.grid_view),
            onPressed: () => setState(() => _showGrid = !_showGrid),
          ),
        ],
      ),
      body: _showGrid ? _buildGridView() : _buildListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _controller.clear();
          _page = 1;
          _controller.addItems(List.generate(20, (i) => 'Item ${i + 1}'));
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildListView() {
    return OptimizedListView<String>(
      controller: _controller,
      enablePagination: true,
      onLoadMore: _loadMore,
      padding: const EdgeInsets.all(8),
      config: const OptimizationConfig(itemExtent: 72, cacheExtent: 500),
      itemBuilder: (context, item, index) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: CircleAvatar(child: Text('${index + 1}')),
            title: Text(item),
            subtitle: Text('Index: $index'),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                _controller.updateItem(index, '$item ✓');
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridView() {
    return OptimizedGridView<String>(
      controller: _controller,
      crossAxisCount: 2,
      enablePagination: true,
      onLoadMore: _loadMore,
      padding: const EdgeInsets.all(8),
      childAspectRatio: 1.5,
      itemBuilder: (context, item, index) {
        return Card(
          child: InkWell(
            onTap: () => _controller.updateItem(index, '$item ✓'),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(item, textAlign: TextAlign.center),
              ),
            ),
          ),
        );
      },
    );
  }
}
