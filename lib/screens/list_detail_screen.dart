import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/firestore_providers.dart';
import '../widgets/connection_status_indicator.dart';
import '../widgets/list_item_tile.dart';
import '../widgets/activity_feed.dart';
import '../widgets/chat_widget.dart';
import '../widgets/participants_list.dart';

class ListDetailScreen extends ConsumerStatefulWidget {
  const ListDetailScreen({super.key});

  @override
  ConsumerState<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends ConsumerState<ListDetailScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _itemController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _updateParticipantStatus(true);
  }

  @override
  void dispose() {
    _updateParticipantStatus(false);
    _itemController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _updateParticipantStatus(bool isOnline) {
    final listId = ref.read(currentListIdProvider);
    if (listId == null) return;

    final auth = ref.read(authProvider);
    final service = ref.read(firestoreServiceProvider);

    service.updateParticipantStatus(
      listId: listId,
      userId: auth.userId,
      isOnline: isOnline,
    );
  }

  Future<void> _addItem() async {
    if (_itemController.text.trim().isEmpty) return;

    final listId = ref.read(currentListIdProvider);
    if (listId == null) return;

    final auth = ref.read(authProvider);
    final service = ref.read(firestoreServiceProvider);

    try {
      await service.addItem(
        listId: listId,
        title: _itemController.text.trim(),
        userId: auth.userId,
        userName: auth.userName,
      );
      _itemController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add item: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(currentListProvider);
    final itemsAsync = ref.watch(listItemsProvider);
    final listId = ref.watch(currentListIdProvider);

    return listAsync.when(
      data: (list) {
        if (list == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('List not found')),
            body: const Center(child: Text('List not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(list.title),
            actions: const [
              ConnectionStatusIndicator(),
              SizedBox(width: 8),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.list), text: 'Items'),
                Tab(icon: Icon(Icons.chat), text: 'Chat'),
                Tab(icon: Icon(Icons.people), text: 'Participants'),
                Tab(icon: Icon(Icons.history), text: 'Activity'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _itemController,
                            decoration: const InputDecoration(
                              hintText: 'Add new item...',
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: (_) => _addItem(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addItem,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: itemsAsync.when(
                      data: (items) {
                        if (items.isEmpty) {
                          return const Center(
                            child: Text('No items yet. Add one above!'),
                          );
                        }

                        return ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            return ListItemTile(
                              item: items[index],
                              listId: listId!,
                            );
                          },
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (error, stack) => Center(
                        child: Text('Error loading items: $error'),
                      ),
                    ),
                  ),
                ],
              ),
              ChatWidget(listId: listId!),
              const ParticipantsList(),
              const ActivityFeed(),
            ],
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Error loading list: $error')),
      ),
    );
  }
}
