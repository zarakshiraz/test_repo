import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/list_card.dart';
import '../../../../core/models/grocery_list.dart';

class ListsPage extends StatefulWidget {
  const ListsPage({super.key});

  @override
  State<ListsPage> createState() => _ListsPageState();
}

class _ListsPageState extends State<ListsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<GroceryList> _activeLists = [];
  final List<GroceryList> _savedLists = [];
  final List<GroceryList> _completedLists = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMockData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadMockData() {
    // Mock data for demonstration
    final now = DateTime.now();
    
    setState(() {
      _activeLists.addAll([
        GroceryList(
          id: '1',
          title: 'Weekly Groceries',
          description: 'Items for this week',
          createdByUserId: 'user1',
          createdAt: now.subtract(const Duration(hours: 2)),
          updatedAt: now.subtract(const Duration(minutes: 30)),
          totalItems: 8,
          completedItems: 3,
          sharedWith: [
            SharedUser(
              userId: 'user2',
              permission: ListPermission.canEdit,
              sharedAt: now.subtract(const Duration(hours: 1)),
            ),
          ],
        ),
        GroceryList(
          id: '2',
          title: 'Party Supplies',
          description: 'For Saturday party',
          createdByUserId: 'user1',
          createdAt: now.subtract(const Duration(days: 1)),
          updatedAt: now.subtract(const Duration(hours: 3)),
          totalItems: 12,
          completedItems: 0,
          category: 'Party',
        ),
      ]);

      _savedLists.addAll([
        GroceryList(
          id: '3',
          title: 'Monthly Groceries Template',
          description: 'Reusable monthly list',
          createdByUserId: 'user1',
          createdAt: now.subtract(const Duration(days: 30)),
          updatedAt: now.subtract(const Duration(days: 5)),
          isSaved: true,
          totalItems: 25,
          completedItems: 0,
        ),
      ]);

      _completedLists.addAll([
        GroceryList(
          id: '4',
          title: 'Last Week Shopping',
          description: 'Completed shopping list',
          createdByUserId: 'user1',
          createdAt: now.subtract(const Duration(days: 7)),
          updatedAt: now.subtract(const Duration(days: 6)),
          status: ListStatus.completed,
          completedAt: now.subtract(const Duration(days: 6)),
          totalItems: 15,
          completedItems: 15,
        ),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Lists'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Show menu
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active', icon: Icon(Icons.list_alt)),
            Tab(text: 'Saved', icon: Icon(Icons.bookmark)),
            Tab(text: 'Completed', icon: Icon(Icons.check_circle)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildListView(_activeLists, 'No active lists'),
          _buildListView(_savedLists, 'No saved lists'),
          _buildListView(_completedLists, 'No completed lists'),
        ],
      ),
    );
  }

  Widget _buildListView(List<GroceryList> lists, String emptyMessage) {
    if (lists.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.list_alt_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to create your first list',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // TODO: Implement refresh
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: lists.length,
        itemBuilder: (context, index) {
          final list = lists[index];
          return ListCard(
            list: list,
            onTap: () => context.go('/lists/detail/${list.id}'),
            onShare: () => _shareList(list),
            onDelete: () => _deleteList(list),
            onToggleSave: () => _toggleSaveList(list),
          );
        },
      ),
    );
  }

  void _shareList(GroceryList list) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Share ${list.title}')),
    );
  }

  void _deleteList(GroceryList list) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete List'),
        content: Text('Are you sure you want to delete "${list.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement delete
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${list.title} deleted')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _toggleSaveList(GroceryList list) {
    // TODO: Implement save/unsave functionality
    final action = list.isSaved ? 'unsaved' : 'saved';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${list.title} $action')),
    );
  }
}