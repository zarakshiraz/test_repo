import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/grocery_item.dart';
import '../widgets/grocery_list_item.dart';
import '../design_system/colors.dart';
import '../design_system/spacing.dart';
import '../utils/haptic_feedback.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<GroceryItem> _items = [];
  final TextEditingController _textController = TextEditingController();
  late AnimationController _fabAnimationController;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadSampleData();
  }

  @override
  void dispose() {
    _textController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _loadSampleData() {
    setState(() {
      _items = [
        GroceryItem(
          id: '1',
          name: 'Organic Apples',
          category: 'Fruits',
          quantity: 6,
        ),
        GroceryItem(
          id: '2',
          name: 'Whole Milk',
          category: 'Dairy',
          quantity: 2,
        ),
        GroceryItem(
          id: '3',
          name: 'Whole Wheat Bread',
          category: 'Bakery',
          quantity: 1,
        ),
      ];
    });
  }

  void _addItem(String name) {
    if (name.trim().isEmpty) return;

    setState(() {
      _items.add(
        GroceryItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name.trim(),
          quantity: 1,
        ),
      );
    });
    _textController.clear();
    GrocliHaptics.success();
  }

  void _toggleItem(String id) {
    setState(() {
      final index = _items.indexWhere((item) => item.id == id);
      if (index != -1) {
        _items[index] = _items[index].copyWith(
          isCompleted: !_items[index].isCompleted,
        );
      }
    });
  }

  void _deleteItem(String id) {
    setState(() {
      _items.removeWhere((item) => item.id == id);
    });
  }

  void _showAddDialog() {
    GrocliHaptics.light();

    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Add Item'),
          content: Padding(
            padding: const EdgeInsets.only(top: GrocliSpacing.md),
            child: CupertinoTextField(
              controller: _textController,
              placeholder: 'Item name',
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (value) {
                _addItem(value);
                Navigator.pop(context);
              },
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                _addItem(_textController.text);
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Add Item'),
          content: TextField(
            controller: _textController,
            decoration: const InputDecoration(
              hintText: 'Item name',
            ),
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (value) {
              _addItem(value);
              Navigator.pop(context);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                _addItem(_textController.text);
                Navigator.pop(context);
              },
              child: const Text('ADD'),
            ),
          ],
        ),
      );
    }
  }

  void _navigateToChat() {
    GrocliHaptics.light();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ChatScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    ).then((result) {
      if (result != null && result is String) {
        _addItem(result);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final completedItems = _items.where((item) => item.isCompleted).length;
    final totalItems = _items.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocli'),
        actions: [
          Semantics(
            button: true,
            label: 'Open chat assistant',
            child: IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: _navigateToChat,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (totalItems > 0)
            Container(
              padding: const EdgeInsets.all(GrocliSpacing.md),
              margin: const EdgeInsets.all(GrocliSpacing.md),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    GrocliColors.primaryGreen.withAlpha(26),
                    GrocliColors.primaryGreenLight.withAlpha(26),
                  ],
                ),
                borderRadius: BorderRadius.circular(GrocliSpacing.borderRadiusMd),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shopping Progress',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: GrocliSpacing.xxs),
                      Text(
                        '$completedItems of $totalItems items',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: GrocliColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(
                            begin: 0.0,
                            end: totalItems > 0
                                ? completedItems / totalItems
                                : 0.0,
                          ),
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          builder: (context, value, child) {
                            return CircularProgressIndicator(
                              value: value,
                              strokeWidth: 6,
                              backgroundColor:
                                  GrocliColors.divider.withAlpha(77),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                GrocliColors.primaryGreen,
                              ),
                            );
                          },
                        ),
                      ),
                      Text(
                        '${(totalItems > 0 ? (completedItems / totalItems * 100) : 0).toInt()}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          Expanded(
            child: _items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 80,
                          color: GrocliColors.textHint,
                        ),
                        const SizedBox(height: GrocliSpacing.md),
                        Text(
                          'Your list is empty',
                          style:
                              Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: GrocliColors.textSecondary,
                                  ),
                        ),
                        const SizedBox(height: GrocliSpacing.xs),
                        Text(
                          'Add items to get started',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: GrocliColors.textHint,
                              ),
                        ),
                      ],
                    ),
                  )
                : AnimatedList(
                    key: GlobalKey<AnimatedListState>(),
                    initialItemCount: _items.length,
                    itemBuilder: (context, index, animation) {
                      if (index >= _items.length) {
                        return const SizedBox.shrink();
                      }
                      final item = _items[index];
                      return SlideTransition(
                        position: animation.drive(
                          Tween<Offset>(
                            begin: const Offset(1, 0),
                            end: Offset.zero,
                          ).chain(CurveTween(curve: Curves.easeOut)),
                        ),
                        child: FadeTransition(
                          opacity: animation,
                          child: GroceryListItemWidget(
                            item: item,
                            onToggle: () => _toggleItem(item.id),
                            onDelete: () => _deleteItem(item.id),
                            onTap: () {},
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Semantics(
        button: true,
        label: 'Add new item',
        child: FloatingActionButton(
          onPressed: _showAddDialog,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
