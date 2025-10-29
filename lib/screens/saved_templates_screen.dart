import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/list_template.dart';
import '../services/firestore_service.dart';
import 'template_detail_screen.dart';

class SavedTemplatesScreen extends StatefulWidget {
  final String userId;

  const SavedTemplatesScreen({super.key, required this.userId});

  @override
  State<SavedTemplatesScreen> createState() => _SavedTemplatesScreenState();
}

class _SavedTemplatesScreenState extends State<SavedTemplatesScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _uuid = const Uuid();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _duplicateTemplate(ListTemplate template) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Duplicate Template'),
          content: Text(
            'Create a new list from "${template.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _firestoreService.duplicateTemplateToList(
        newListId: _uuid.v4(),
        userId: widget.userId,
        template: template,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('List created successfully!'),
          ),
        );
      }
    }
  }

  Future<void> _deleteTemplate(ListTemplate template) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Template'),
          content: const Text('Are you sure you want to delete this template?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _firestoreService.deleteTemplate(template.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Template deleted'),
          ),
        );
      }
    }
  }

  List<ListTemplate> _filterTemplates(List<ListTemplate> templates) {
    if (_searchQuery.isEmpty) {
      return templates;
    }

    return templates.where((template) {
      return template.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Templates'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search templates...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<ListTemplate>>(
        stream: _firestoreService.getTemplates(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final allTemplates = snapshot.data!;
          final filteredTemplates = _filterTemplates(allTemplates);

          if (allTemplates.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'No saved templates yet.\nSave a list as a template to see it here!',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (filteredTemplates.isEmpty) {
            return Center(
              child: Text('No templates found for "$_searchQuery"'),
            );
          }

          return ListView.builder(
            itemCount: filteredTemplates.length,
            itemBuilder: (context, index) {
              final template = filteredTemplates[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                child: ListTile(
                  title: Text(
                    template.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('${template.itemCount} items'),
                      const SizedBox(height: 2),
                      Text(
                        'Created ${_formatDate(template.createdAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.copy),
                        tooltip: 'Duplicate to new list',
                        onPressed: () => _duplicateTemplate(template),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Delete template',
                        onPressed: () => _deleteTemplate(template),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TemplateDetailScreen(
                          template: template,
                          userId: widget.userId,
                          onDuplicate: () => _duplicateTemplate(template),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
